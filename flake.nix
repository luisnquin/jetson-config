{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/77ef7a29d276c6d8303aece3444d61118ef71ac2";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jetpack = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    black-terminal.url = "github:luisnquin/black-terminal";
  };

  outputs = {
    black-terminal,
    disko,
    home-manager,
    jetpack,
    nixpkgs,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs ["aarch64-linux"] (
        system: function nixpkgs.legacyPackages.${system}
      );
  in {
    nixosConfigurations.jyx = nixpkgs.lib.nixosSystem {
      modules = [
        black-terminal.nixosModules.default
        ./configuration.nix
        jetpack.nixosModules.default
        disko.nixosModules.default
        home-manager.nixosModules.default
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.luisnquin = {
            imports = [
              black-terminal.homeModules.default
              ./home.nix
            ];
          };
        }
      ];
    };

    packages = forAllSystems (pkgs: rec {
      default = pkgs.callPackage ./installer {};
      infection = default;
    });
  };
}

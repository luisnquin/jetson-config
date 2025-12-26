{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    jetpack.url = "github:anduril/jetpack-nixos/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    black-terminal.url = "github:luisnquin/black-terminal";
  };

  outputs = {
    black-terminal,
    nixpkgs,
    jetpack,
    disko,
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
      ];
    };

    packages = forAllSystems (pkgs: rec {
      default = pkgs.callPackage ./installer {};
      infection = default;
    });
  };
}

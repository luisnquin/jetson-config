{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/77ef7a29d276c6d8303aece3444d61118ef71ac2";
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

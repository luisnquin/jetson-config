{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jetpack = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
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

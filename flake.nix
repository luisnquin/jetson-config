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
  }: {
    nixosConfigurations.jyx = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        jetpack.nixosModules.default
        disko.nixosModules.default
      ];
    };
  };
}

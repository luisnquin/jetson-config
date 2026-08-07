{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    self,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs ["aarch64-linux"] (
        system: function nixpkgs.legacyPackages.${system}
      );
  in {
    # aarch64 installer image, cross-compiled from x86_64 so it does not go
    # through qemu. Carries the jetpack kernel, unlike the generic NixOS
    # aarch64 ISO.
    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      modules = [
        jetpack.nixosModules.default
        ./installer/iso.nix
      ];
    };

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

    packages =
      forAllSystems (pkgs: let
        infection = pkgs.callPackage ./installer {};
      in {
        inherit infection;
        default = infection;
        # exposed so infection partitions with the locked disko, not master
        inherit (disko.packages.${pkgs.stdenv.hostPlatform.system}) disko;
      })
      // {
        # flashing tooling ships x86_64-only binaries, so the host does this half
        x86_64-linux = rec {
          default = installer-iso;
          installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
          inherit (jetpack.packages.x86_64-linux) flash-orin-nano-super-devkit;
        };
      };
  };
}

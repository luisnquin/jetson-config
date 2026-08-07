{
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  nixpkgs = {
    buildPlatform.system = "x86_64-linux";
    hostPlatform.system = "aarch64-linux";
    config.allowUnfree = true;
  };

  hardware.nvidia-jetpack = {
    enable = true;
    som = "orin-nano";
    super = true;
    carrierBoard = "devkit";
    # cuda has no cross-compilation support upstream and dominates evaluation
    # time; the installer only needs the vendor kernel and its drivers
    configureCuda = false;
  };

  # tegra_defconfig does not carry the modules this pulls in, e.g. ata_piix
  hardware.enableAllHardware = lib.mkForce false;

  boot.zfs.forceImportRoot = false;

  environment.systemPackages = [(pkgs.callPackage ./. {})];
}

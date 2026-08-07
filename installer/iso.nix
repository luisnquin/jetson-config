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

  # the installer's nixos user already has passwordless wheel
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIXW6vsDRgI/AiOdGnQOTyiz1uLFL0o66u0Ahcw9VWyd luis@quinones.pro"
  ];

  # reachable as nixos.local, since a headless installer cannot report its lease
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  environment.systemPackages = [(pkgs.callPackage ./. {})];
}

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;

  hardware.nvidia-jetpack.enable = true;
  hardware.nvidia-jetpack.som = "orin-nano";
  hardware.nvidia-jetpack.carrierBoard = "devkit";

  hardware.graphics.enable = true;

  networking.hostName = "jyx";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Lima";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
    useXkbConfig = true;
  };

  users.users.ori = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        email = "luis@quinones.pro";
        name = "Luis Quiñones";
      };
      init.defaultBranch = "main";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      rebase.autoStash = true;
      pull.rebase = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "25.05"; # Did you read the comment?
}

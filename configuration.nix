{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    # reduces build times, produces smaller closures, and provides the CUDA compiler more opportunities for optimization
    cudaCapabilities = ["8.7"];
  };

  boot = {
    loader = {
      timeout = 5;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Suppress audio errors - not needed and causes boot noise
    kernelParams = ["snd_soc_tegra210_admaif.disable=1"];
    blacklistedKernelModules = ["tegra-audio-graph-card"];
    plymouth.enable = false;
  };

  hardware = {
    nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      super = true;
      carrierBoard = "devkit";
      firmware.autoUpdate = true;
      modesetting.enable = false; # X11 - more stable on Jetson
    };

    graphics.enable = true;
  };

  networking = {
    hostName = "jyx";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users = {
    luisnquin = {
      isNormalUser = true;
      extraGroups = ["wheel" "video"];
      shell = pkgs.zsh;
      initialHashedPassword = "$6$w7DRQhmRQYAWrNLA$bfPYYbuJjVO80Del1dRKa.8vfE1ceHUDRvfXpOHy3XbyeJouBe2ZXJA6wUhw8BYaJ0ZPbtnFo1pI9r84tk2481";
    };
  };

  environment.pathsToLink = ["/libexec"];

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    displayManager.lightdm.enable = true;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };

  programs.i3lock.enable = true;

  security.pam.services.i3lock.enable = true;

  services.getty.autologinUser = "luisnquin";

  environment = {
    systemPackages = with pkgs; [
      xclip
      alacritty
      xorg.xinit
    ];
    shellAliases = {
      copy = "xclip -selection clipboard";
    };
  };

  services.fstrim.enable = true;

  shared = {
    aliases.enable = true;
    zsh.enable = true;
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

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

  boot.loader = {
    timeout = 5;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      super = true;
      carrierBoard = "devkit";
      firmware.autoUpdate = true;
      modesetting.enable = false; # X11
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
      extraGroups = ["wheel" "video" "wheel"];
      shell = pkgs.zsh;
      initialHashedPassword = "$6$w7DRQhmRQYAWrNLA$bfPYYbuJjVO80Del1dRKa.8vfE1ceHUDRvfXpOHy3XbyeJouBe2ZXJA6wUhw8BYaJ0ZPbtnFo1pI9r84tk2481";
    };
  };

  environment.pathsToLink = ["/libexec"];

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
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

  security = {
    pam.services.i3lock.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = true;

      configFile = ''
        Defaults 	insults
      '';
    };
  };

  services.getty.autologinUser = "luisnquin";

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''${pkgs.greetd}/bin/agreety --cmd ${pkgs.lib.getExe pkgs.i3}'';
    };
  };

  environment = {
    systemPackages = [
      pkgs.xclip
      pkgs.alacritty
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

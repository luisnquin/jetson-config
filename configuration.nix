{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./components/term+shell
  ];

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.lib.getExe pkgs.tuigreet} --time --remember --cmd niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "niri-session";
        user = "luisnquin";
      };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    # reduces build times, produces smaller closures, and provides the CUDA compiler more opportunities for optimization
    cudaCapabilities = ["8.7"];
  };

  boot = {
    loader = {
      timeout = 1;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # audio stack isn’t needed. ADMAIF and graph-card trigger registration errors (-16) due to DT mismatches, so this reduces the boot noise
    kernelParams = [
      "snd_soc_tegra210_admaif.disable=1"
    ];

    blacklistedKernelModules = ["tegra-audio-graph-card"];
  };

  hardware = {
    nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      super = true;
      carrierBoard = "devkit";
      firmware.autoUpdate = true;
      modesetting.enable = true; # wayland
    };

    graphics.enable = true;
  };

  networking = {
    hostName = "jyx";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.luisnquin = {
    isNormalUser = true;
    extraGroups = ["wheel" "video"];
    shell = pkgs.zsh;
  };

  programs.niri.enable = true;

  environment = {
    systemPackages = [
      pkgs.wl-clipboard
      pkgs.alacritty
    ];
    shellAliases = {
      copy = "wl-copy";
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

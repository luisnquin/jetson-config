{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./components/i3.nix
    ./components/term+shell
  ];

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
      carrierBoard = "devkit";
      firmware.autoUpdate = true;
      modesetting.enable = false; # x11 - has proven to be more reliable than wayland
    };

    graphics.enable = true;
  };

  networking = {
    hostName = "jyx";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Lima";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.ori = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  environment = {
    systemPackages = [pkgs.xclip];
    shellAliases = {
      copy = "xclip -selection clipboard";
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

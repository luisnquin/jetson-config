{pkgs, ...}: {
  environment.pathsToLink = ["/libexec"];

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3blocks
      ];
    };
  };

  services.displayManager.defaultSession = "none+i3";
}

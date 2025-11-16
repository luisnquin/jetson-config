{
  pkgs,
  lib,
  ...
}: {
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
    useXkbConfig = false;
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind r
      set-option -ga terminal-overrides ",*256col*:Tc:RGB"
      set -g default-terminal "xterm-256color"
      setw -g pane-base-index 200
      set -g base-index 100
      set-window-option -g mode-keys vi
      set -g window-status-separator '\'
      set -g status-interval 5
      set -g display-time 4000
      setw -g mouse on
      set -g terminal-overrides 'xterm*:smcup@:rmcup@'
      setw -g aggressive-resize off
      setw -g clock-mode-style 24
      set -s escape-time 500
      set -g history-limit 1000000
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestions = {
      enable = true;
      async = true;

      highlightStyle = "fg=#9eadab";
      strategy = [
        "history"
      ];
    };

    syntaxHighlighting = {
      enable = true;
    };

    enableBashCompletion = true;
    enableCompletion = true;

    promptInit = ''
      if [ "$TMUX" = "" ]; then
          exec ${lib.getExe pkgs.tmux}
      fi
    '';

    interactiveShellInit = ''
      export GID UID

      # This keybindings allows for fast navigation from left to right and back.
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

      # Case-less when searching for files/directories
      zstyle ':completion:*' matcher-list '\' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

      # https://stackoverflow.com/a/11873793
      setopt interactivecomments
    '';
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
}

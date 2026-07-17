{ config, lib, pkgs, ... }:

{
  # User configuration
  users = {
    users.user = {
      isNormalUser = true;
      initialPassword = "changeme"; # Change on first login
      home = "/home/user";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "bluetooth"
        "docker"
        "podman"
        "video"
        "audio"
        "input"
        "users"
        "systemd-journal"
        "greetd"
      ];
    };
    
    # Default user shell
    defaultUserShell = pkgs.zsh;
  };

  # Security settings
  security = {
    sudo = {
      enable = true;
      extraRules = [
        {
          users = [ "user" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
    pam = {
      services = {
        swaylock = {};
        greetd = {
          text = ''
            auth include login
            account include login
            password include login
            session include login
          '';
        };
      };
    };
  };

  # Zsh configuration (default shell)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alh";
      la = "ls -A";
      l = "ls -CF";
      ls = "exa --icons --group-directories-first";
      ll = "exa -l --icons --group-directories-first";
      la = "exa -a --icons --group-directories-first";
      lla = "exa -la --icons --group-directories-first";
      tree = "exa --tree --icons";
      grep = "rg";
      find = "fd";
      cat = "bat";
      top = "btop";
      du = "duf";
      df = "duf";
      nixos-rebuild = "sudo nixos-rebuild";
      hm = "home-manager";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
    };
    initExtra = ''
      # Set up custom prompt
      export STARSHIP_CONFIG=~/.config/starship.toml
      
      # Zsh plugins
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      
      # Environment variables
      export EDITOR=vim
      export VISUAL=vim
      export PAGER=less
      
      # Nix specific
      export NIX_PATH="nixpkgs=/etc/nixos:nixpkgs=/run/current-system/sw/share/nixpkgs"
      
      # Autoload functions
      autoload -Uz zmv
      autoload -Uz zcalc
      
      # History settings
      HISTFILE="$HOME/.zsh_history"
      HISTSIZE=10000
      SAVEHIST=10000
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt SHARE_HISTORY
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vicmd_symbol = "[❮](bold blue)";
      };
      git_branch = {
        format = "[$branch]($style)";
        style = "bold purple";
      };
      git_status = {
        style = "bold yellow";
      };
      nodejs = {
        symbol = "⬢";
        style = "bold green";
      };
      python = {
        symbol = "🐍";
        style = "bold blue";
      };
      rust = {
        symbol = "🦀";
        style = "bold red";
      };
      nix_shell = {
        symbol = "❄️";
        style = "bold cyan";
        format = "[$symbol$state]($style) ";
      };
      kubernetes = {
        symbol = "☸️";
        style = "bold blue";
      };
      docker_context = {
        symbol = "🐋";
        style = "bold cyan";
      };
      package = {
        symbol = "📦";
        style = "bold 208";
      };
    };
  };

  # Home Manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = {
      home = {
        stateVersion = "24.11";
        file = {
          # .zshrc is managed by Nix
          ".config/starship.toml".source = "${pkgs.starship}/share/starship/default.toml";
        };
      };
      programs = {
        home-manager.enable = true;
        zsh = {
          enable = true;
          autocd = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          history = {
            size = 10000;
            path = "$HOME/.zsh_history";
          };
          plugins = [
            {
              name = "zsh-completions";
              file = "zsh-completions.zsh";
              src = pkgs.zsh-completions + "/share/zsh-completions";
            }
          ];
        };
      };
    };
  };
}

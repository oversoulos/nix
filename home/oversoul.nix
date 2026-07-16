{ config, lib, osConfig, pkgs, ... }:
let
  user = osConfig.oversoul.user;
  modes = osConfig.oversoul.modeSpecs;

  mkModeFiles = name: spec: {
    "modes/${name}/README.md".text = ''
      # ${lib.toUpper name} mode

      Purpose: ${spec.description}

      Tools:
      ${lib.concatMapStringsSep "\n" (tool: "- ${tool}") spec.tools}

      Hotkeys:
      ${lib.concatMapStringsSep "\n" (key: "- ${key}") spec.hotkeys}

      KOBOLD API: $KOBOLD_API_URL
    '';

    "modes/${name}/.envrc".text = ''
      export MODE_ACTIVE=${name}
      export KOBOLD_API_URL="http://localhost:5001/v1"
      export OBSIDIAN_VAULT_DIR="$HOME/obsidian-vaults"
      export NEXUS_DIR="$HOME/oversoul"
      use flake || true
    '';

    "modes/${name}/shell.nix".text = ''
      { pkgs ? import <nixpkgs> {} }:
      pkgs.mkShell {
        packages = with pkgs; [ git direnv ];
        shellHook = "export MODE_ACTIVE=${name}; export KOBOLD_API_URL=http://localhost:5001/v1; export MODE_TOOLS='${lib.concatStringsSep "," spec.tools}'";
      }
    '';

    "modes/${name}/waybar-config.jsonc".text = builtins.toJSON [
      {
        layer = "top";
        position = "top";
        mode = "dock";
        modules-left = [ "sway/workspaces" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "network" "pulseaudio" "tray" ];
        clock = { format = "{:%Y-%m-%d %H:%M}"; };
      }
    ];

    "modes/${name}/waybar-style.css".text = ''
      * {
        font-family: "Inter", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 12px;
      }

      window#waybar {
        background: rgba(20, 20, 30, 0.65);
        color: #e6edf3;
      }
    '';
  };

  modeFiles = lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList mkModeFiles modes);

  perPackageCheats = {
    ".cheatsheets/global.txt".text = ''
      # Global shortcuts
      mode-switch-menu         # open mode switcher
      mode-switch <mode>       # set workspace mode
      health-check             # full health report
      clean-up                 # cleanup + gc
      debug-tools              # diagnostics toolbox
      sudo systemctl status koboldcpp
    '';

    ".cheatsheets/koboldcpp.txt".text = ''
      sudo systemctl start koboldcpp
      sudo systemctl stop koboldcpp
      sudo systemctl status koboldcpp
      curl -s http://localhost:5001/v1/models
    '';

    ".cheatsheets/sway.txt".text = ''
      $mod+Return terminal
      $mod+Tab mode switch menu
      $mod+Space scratchpad show
      $mod+c cheat sheet terminal
      $mod+a toggle koboldcpp service
    '';
  };
in
{
  imports = [ ./shell.nix ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    KOBOLD_API_URL = "http://localhost:5001/v1";
    OBSIDIAN_VAULT_DIR = "$HOME/obsidian-vaults";
    MODE_ACTIVE = "vibing";
    NEXUS_DIR = "$HOME/oversoul";
    AI_MODEL_PATH = "$HOME/models/current-model.gguf";
  };

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      mode = "dock";
      modules-left = [ "sway/workspaces" "sway/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "memory" "network" "pulseaudio" "battery" "tray" ];
      clock.format = "{:%a %b %d  %H:%M}";
      "sway/window".max-length = 72;
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Inter", "JetBrainsMono Nerd Font", sans-serif;
      }
      window#waybar {
        background: rgba(26, 30, 38, 0.60);
        color: #dbe3ec;
      }
      #workspaces button.focused {
        background: rgba(86, 156, 214, 0.35);
      }
    '';
  };

  xdg.configFile."sway/config".text = ''
    set $mod Mod4
    font pango:Inter 10

    exec waybar
    exec nm-applet
    exec blueman-applet

    bindsym $mod+Return exec ghostty
    bindsym $mod+d exec wofi --show drun
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'
    bindsym $mod+space scratchpad show
    bindsym $mod+Tab exec mode-switch-menu
    bindsym $mod+c exec ghostty -e sh -lc 'cat ~/.cheatsheets/global.txt | less'
    bindsym $mod+h exec ghostty -e "$HOME/scripts/health-check.sh"
    bindsym $mod+a exec "$HOME/oversoul/scripts/ai-control.sh" toggle

    floating_modifier $mod
    default_border pixel 2

    # Scratchpad examples for dockable/floating utilities
    bindsym $mod+Shift+n move scratchpad
    bindsym $mod+Shift+space floating toggle
  '';

  home.packages = with pkgs; [
    starship
    jq
    yq
    unzip
    zip
    killall
    lm_sensors
    bc
    speedtest-cli
  ];

  home.file = modeFiles // perPackageCheats // {
    "scripts/health-check.sh" = {
      source = ../scripts/health-check.sh;
      executable = true;
    };
    "scripts/clean-up.sh" = {
      source = ../scripts/clean-up.sh;
      executable = true;
    };
    "scripts/debug-tools.sh" = {
      source = ../scripts/debug-tools.sh;
      executable = true;
    };
    "scripts/status.sh" = {
      source = ../scripts/status.sh;
      executable = true;
    };

    "oversoul/dashboard.html".text = ''
      <!doctype html>
      <html>
      <head>
        <meta charset="utf-8" />
        <title>Oversoul Nexus</title>
        <style>
          body { font-family: Inter, sans-serif; background: #111827; color: #e5e7eb; margin: 2rem; }
          .card { background: #1f2937; padding: 1rem; margin-bottom: 1rem; border-radius: 10px; }
          a { color: #93c5fd; }
        </style>
      </head>
      <body>
        <h1>Oversoul Nexus</h1>
        <div class="card"><b>Mode switch:</b> <code>mode-switch-menu</code> or <code>mode-switch &lt;mode&gt;</code></div>
        <div class="card"><b>AI endpoint:</b> <code>$KOBOLD_API_URL</code></div>
        <div class="card"><b>Health:</b> <code>~/scripts/health-check.sh</code></div>
        <div class="card"><b>Modes:</b> vibing, schooling, building, creating, spiraling</div>
      </body>
      </html>
    '';

    "oversoul/config/env-vars.nix".text = ''
      {
        KOBOLD_API_URL = "http://localhost:5001/v1";
        OBSIDIAN_VAULT_DIR = "~/obsidian-vaults";
        MODE_ACTIVE = "vibing";
        NEXUS_DIR = "~/oversoul";
        AI_MODEL_PATH = "~/models/current-model.gguf";
      }
    '';

    "oversoul/config/networks.nix".text = ''
      {
        networkManager = true;
        firewall = {
          defaultIncoming = "deny";
          defaultOutgoing = "allow";
        };
      }
    '';

    "oversoul/scripts/mode-switch.sh" = {
      text = ''#!/usr/bin/env bash
        exec mode-switch "$@"
      '';
      executable = true;
    };

    "oversoul/scripts/ai-control.sh" = {
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        action="${1:-status}"
        case "$action" in
          start) sudo systemctl start koboldcpp ;;
          stop) sudo systemctl stop koboldcpp ;;
          kill) sudo systemctl kill koboldcpp ;;
          restart) sudo systemctl restart koboldcpp ;;
          toggle)
            if systemctl is-active --quiet koboldcpp; then
              sudo systemctl stop koboldcpp
            else
              sudo systemctl start koboldcpp
            fi
            ;;
          status) systemctl status --no-pager koboldcpp ;;
          *) echo "Usage: $0 {start|stop|kill|restart|toggle|status}"; exit 1 ;;
        esac
      '';
      executable = true;
    };

    "oversoul/scripts/network-status.sh" = {
      text = ''#!/usr/bin/env bash
        nmcli general status
        echo
        nmcli connection show --active
      '';
      executable = true;
    };

    "oversoul/scripts/health-check.sh" = {
      source = ../scripts/health-check.sh;
      executable = true;
    };

    "oversoul/scripts/clean-up.sh" = {
      source = ../scripts/clean-up.sh;
      executable = true;
    };

    "oversoul/scripts/debug-tools.sh" = {
      source = ../scripts/debug-tools.sh;
      executable = true;
    };

    "oversoul/publish/publish-status.sh" = {
      text = ''#!/usr/bin/env bash
        set -euo pipefail
        mkdir -p "$HOME/oversoul/publish/site"
        "$HOME/scripts/status.sh" > "$HOME/oversoul/publish/site/status.txt"
        echo "Published to $HOME/oversoul/publish/site/status.txt"
      '';
      executable = true;
    };
  };
}

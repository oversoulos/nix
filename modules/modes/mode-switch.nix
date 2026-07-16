{ config, lib, pkgs, ... }:

{
  # Mode switching implementation
  systemd.services.mode-switch = {
    description = "Modal workspace switch service";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/echo MODE_ACTIVE=$1 > /tmp/current-mode'";
    };
  };

  # Global hotkeys configuration for Sway
  environment.etc."sway/config.d/mode-switch.conf".text = ''
    # Mode switching hotkeys
    bindsym $mod+Tab exec ${pkgs.wofi}/bin/wofi --dmenu --prompt "Switch Mode:" --cache-file /dev/null --show drun < ${../home/scripts/mode-switch.sh}
    bindsym $mod+c exec ${pkgs.kitty}/bin/kitty --hold sh -c "${../home/scripts/cheat-sheet.sh}"
    bindsym $mod+h exec ${../home/scripts/health-check.sh}
    bindsym $mod+a exec ${../home/scripts/ai-control.sh}
    
    # Scratchpad
    bindsym $mod+space exec ${pkgs.sway}/bin/swaymsg 'move scratchpad'
    bindsym $mod+shift+space exec ${pkgs.sway}/bin/swaymsg 'scratchpad show'
    
    # Application launcher
    bindsym $mod+d exec ${pkgs.wofi}/bin/wofi --dmenu --prompt "Run:" --cache-file /dev/null --show drun
    bindsym $mod+Return exec ${pkgs.ghostty}/bin/ghostty
    
    # Window management
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+e exec ${pkgs.sway}/bin/swaymsg exit
    
    # Cheat sheet overlay
    bindsym $mod+c exec ${pkgs.sway}/bin/swaymsg 'exec ${pkgs.wofi}/bin/wofi --dmenu --prompt "Cheat Sheet:" < ${../home/cheat-sheets/global.txt}'
  '';

  # Mode switch script
  environment.etc."nixos/scripts/mode-switch.sh".text = ''
    #!/usr/bin/env bash
    
    MODE_DIR="$HOME/modes"
    MODE=""
    
    # Get mode from argument or prompt
    if [ -n "$1" ]; then
      MODE="$1"
    else
      MODE=$(ls -1 "$MODE_DIR" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Switch Mode:" --cache-file /dev/null)
    fi
    
    if [ -z "$MODE" ]; then
      echo "No mode selected"
      exit 1
    fi
    
    # Set current mode
    echo "$MODE" > /tmp/current-mode
    export MODE_ACTIVE="$MODE"
    
    # Run mode-specific setup
    if [ -f "$MODE_DIR/$MODE/setup.sh" ]; then
      bash "$MODE_DIR/$MODE/setup.sh"
    fi
    
    # Update Waybar
    pkill -SIGUSR1 waybar || true
    ${pkgs.sway}/bin/swaymsg reload
    
    # Notify user
    ${pkgs.notify-send}/bin/notify-send -t 3000 "Mode Switched" "Now in: $MODE"
    
    echo "Switched to mode: $MODE"
  '';

  # Ensure mode directories exist
  systemd.services.create-mode-dirs = {
    description = "Create modal workspace directories";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /home/user/modes/{vibing,schooling,building,creating,spiraling}'";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

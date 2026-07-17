{ config, lib, pkgs, ... }:

{
  # Vibing mode - Leisure & Social
  environment.etc."nixos/modes/vibing.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Mode-specific packages
      home.packages = with pkgs; [
        discord
        brave
        vlc
        obs-studio
        spotify
      ];
      
      # Mode-specific environment
      home.sessionVariables = {
        MODE_NAME = "vibing";
        MODE_COLOR = "#8B5CF6"; # Purple
        OBSIDIAN_VAULT = "$HOME/modes/vibing/vault";
      };
      
      # Waybar config for this mode
      xdg.configFile."waybar/config".source = ./modes/vibing/waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./modes/vibing/waybar-style.css;
      
      # Mode-specific aliases
      home.shellAliases = {
        vibe = "cd ~/modes/vibing";
        discord-toggle = "pkill -USR1 discord || discord &";
        media-prev = "playerctl previous";
        media-next = "playerctl next";
        media-play = "playerctl play-pause";
      };
      
      # Sway keybindings for this mode
      xdg.configFile."sway/config.d/vibing.conf".text = ''
        # Media keys
        bindsym XF86AudioPlay exec playerctl play-pause
        bindsym XF86AudioNext exec playerctl next
        bindsym XF86AudioPrev exec playerctl previous
        bindsym XF86AudioStop exec playerctl stop
        bindsym $mod+d exec discord
        bindsym $mod+b exec brave
        bindsym $mod+o exec obs-studio
      '';
    }
  '';

  # Ensure vibing mode directory exists with required files
  systemd.services.vibing-mode-setup = {
    description = "Setup vibing mode workspace";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/modes/vibing/vault
          cat > /home/user/modes/vibing/.envrc << EOF
        export MODE_ACTIVE=vibing
        export OBSIDIAN_VAULT=\$HOME/modes/vibing/vault
        export PATH=\$PATH:\$HOME/modes/vibing/bin
        EOF
          cat > /home/user/modes/vibing/README.md << EOF
        # Vibing Mode
        ## Purpose
        Leisure and social activities - YouTube, Discord, Spotify, light gaming, streaming.
        ## Hotkeys
        - \`$mod+d\`: Launch Discord
        - \`$mod+b\`: Launch Brave
        - \`$mod+o\`: Launch OBS
        - Media keys: Control playback
        ## Tools
        - Discord: Communication
        - Brave: Web browsing
        - VLC: Media playback
        - OBS: Streaming/recording
        - Spotify: Music
        EOF
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}

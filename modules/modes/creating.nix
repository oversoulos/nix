{ config, lib, pkgs, ... }:

{
  # Creating mode - Content Production
  environment.etc."nixos/modes/creating.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Mode-specific packages
      home.packages = with pkgs; [
        gimp
        krita
        shotcut
        obs-studio
        okular
        brave
        obsidian
        inkscape
        darktable
        audacity
        ardour
        blender
        handbrake
        kdenlive
      ];
      
      # Mode-specific environment
      home.sessionVariables = {
        MODE_NAME = "creating";
        MODE_COLOR = "#F59E0B"; # Amber
        OBSIDIAN_VAULT = "$HOME/modes/creating/vault";
        MEDIA_DIR = "$HOME/media";
        GIMP_PROFILE = "$HOME/.config/gimp/creating";
      };
      
      # Waybar config for this mode
      xdg.configFile."waybar/config".source = ./modes/creating/waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./modes/creating/waybar-style.css;
      
      # Mode-specific aliases
      home.shellAliases = {
        create = "cd ~/modes/creating";
        render = "shotcut --render $@";
        export-png = "for f in *.xcf; do gimp -i -b '(gimp-file-save RUN-NONINTERACTIVE \"$f\" \"${f%.xcf}.png\" \"png\")' -b '(gimp-quit 0)'; done";
        export-jpg = "for f in *.xcf; do gimp -i -b '(gimp-file-save RUN-NONINTERACTIVE \"$f\" \"${f%.xcf}.jpg\" \"jpeg\")' -b '(gimp-quit 0)'; done";
        record = "wf-recorder -g \"$(slurp)\" -f recording_$(date +%Y%m%d_%H%M%S).mp4";
        screenshot = "grim -g \"$(slurp)\" screenshot_$(date +%Y%m%d_%H%M%S).png";
      };
      
      # Sway keybindings for this mode
      xdg.configFile."sway/config.d/creating.conf".text = ''
        # Creative tools
        bindsym $mod+g exec gimp
        bindsym $mod+k exec krita
        bindsym $mod+o exec obs-studio
        bindsym $mod+s exec shotcut
        bindsym $mod+e exec obsidian
        bindsym $mod+b exec brave
        bindsym $mod+r exec wf-recorder -g \"$(slurp)\" -f recording_$(date +%Y%m%d_%H%M%S).mp4
        bindsym $mod+Shift+s exec grim -g \"$(slurp)\" screenshot_$(date +%Y%m%d_%H%M%S).png
        bindsym $mod+Shift+e exec handbrake
      '';
    }
  '';

  # Ensure creating mode directory exists
  systemd.services.creating-mode-setup = {
    description = "Setup creating mode workspace";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/modes/creating/vault
          mkdir -p /home/user/media/{videos,images,audio,projects}
          cat > /home/user/modes/creating/.envrc << EOF
        export MODE_ACTIVE=creating
        export OBSIDIAN_VAULT=\$HOME/modes/creating/vault
        export MEDIA_DIR=\$HOME/media
        export PATH=\$PATH:\$HOME/modes/creating/bin
        EOF
          cat > /home/user/modes/creating/README.md << EOF
        # Creating Mode
        ## Purpose
        Content production - video/audio editing, graphic design, writing.
        ## Hotkeys
        - \`$mod+g\`: GIMP
        - \`$mod+k\`: Krita
        - \`$mod+o\`: OBS Studio
        - \`$mod+s\`: Shotcut
        - \`$mod+e\`: Obsidian
        - \`$mod+b\`: Brave
        - \`$mod+r\`: Record screen
        - \`$mod+Shift+s\`: Screenshot
        - \`$mod+Shift+e\`: HandBrake
        ## Tools
        - GIMP: Image editing
        - Krita: Digital painting
        - Shotcut: Video editing
        - OBS: Screen recording/streaming
        - Obsidian: Writing
        - Brave: Research
        EOF
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}

{ config, lib, pkgs, ... }:

{
  # Schooling mode - Learning
  environment.etc."nixos/modes/schooling.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Mode-specific packages
      home.packages = with pkgs; [
        brave
        firefox
        discord
        obsidian
        zotero
        pdf-tools
      ];
      
      # Mode-specific environment
      home.sessionVariables = {
        MODE_NAME = "schooling";
        MODE_COLOR = "#3B82F6"; # Blue
        OBSIDIAN_VAULT = "$HOME/modes/schooling/vault";
        ZOTERO_PROFILE = "$HOME/.zotero/schooling";
      };
      
      # Waybar config for this mode
      xdg.configFile."waybar/config".source = ./modes/schooling/waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./modes/schooling/waybar-style.css;
      
      # Mode-specific aliases
      home.shellAliases = {
        school = "cd ~/modes/schooling";
        research = "cd ~/modes/schooling && nvim ~/modes/schooling/vault/research.md";
        clip = "wl-copy $(wl-paste) && echo 'Content clipped to clipboard'";
        save = "wl-copy $(wl-paste) > ~/modes/schooling/vault/clippings/$(date +%Y%m%d_%H%M%S).txt";
      };
      
      # Sway keybindings for this mode
      xdg.configFile."sway/config.d/schooling.conf".text = ''
        # Research tools
        bindsym $mod+r exec firefox
        bindsym $mod+o exec obsidian
        bindsym $mod+c exec wl-copy $(wl-paste) && echo 'Saved to vault'
        bindsym $mod+s exec ~/modes/schooling/scripts/save-research.sh
        bindsym $mod+t exec ${pkgs.ghostty}/bin/ghostty -e zsh -c "cd ~/modes/schooling && nvim"
      '';
    }
  '';

  # Ensure schooling mode directory exists
  systemd.services.schooling-mode-setup = {
    description = "Setup schooling mode workspace";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/modes/schooling/vault/clippings
          mkdir -p /home/user/modes/schooling/scripts
          cat > /home/user/modes/schooling/.envrc << EOF
        export MODE_ACTIVE=schooling
        export OBSIDIAN_VAULT=\$HOME/modes/schooling/vault
        export PATH=\$PATH:\$HOME/modes/schooling/bin
        EOF
          cat > /home/user/modes/schooling/README.md << EOF
        # Schooling Mode
        ## Purpose
        Learning, research, courses, and knowledge acquisition.
        ## Hotkeys
        - \`$mod+r\`: Launch Firefox
        - \`$mod+o\`: Launch Obsidian
        - \`$mod+c\`: Clip content to vault
        - \`$mod+s\`: Save research
        - \`$mod+t\`: Terminal with research notes
        ## Tools
        - Brave/Firefox: Research
        - Obsidian: Note-taking
        - Discord: Study groups
        - Zotero: Reference management
        EOF
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}

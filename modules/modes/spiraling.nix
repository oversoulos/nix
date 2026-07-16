{ config, lib, pkgs, ... }:

{
  # Spiraling mode - Deep Research/Streaming
  environment.etc."nixos/modes/spiraling.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Mode-specific packages
      home.packages = with pkgs; [
        brave
        obsidian
        speech-to-text
        whisper-cpp
        ffmpeg
        yt-dlp
        curl
        jq
        wget
        lynx
      ];
      
      # Mode-specific environment
      home.sessionVariables = {
        MODE_NAME = "spiraling";
        MODE_COLOR = "#EF4444"; # Red
        OBSIDIAN_VAULT = "$HOME/modes/spiraling/vault";
        SPIRAL_TIMEOUT = "3600"; # 1 hour timeout
        VOICE_RECORD_DIR = "$HOME/modes/spiraling/recordings";
      };
      
      # Waybar config for this mode
      xdg.configFile."waybar/config".source = ./modes/spiraling/waybar-config.jsonc;
      xdg.configFile."waybar/style.css".source = ./modes/spiraling/waybar-style.css;
      
      # Mode-specific aliases
      home.shellAliases = {
        spiral = "cd ~/modes/spiraling";
        record = "arecord -f cd -t wav $VOICE_RECORD_DIR/recording_$(date +%Y%m%d_%H%M%S).wav";
        transcribe = "whisper-cpp -m ~/models/ggml-base.bin -f $@";
        research = "cd ~/modes/spiraling && nvim ~/modes/spiraling/vault/research.md";
        fact-check = "curl -X POST http://localhost:5001/v1/completions -H 'Content-Type: application/json' -d '{\"prompt\": \"Fact check: $@\", \"max_tokens\": 500}'";
        webfetch = "wget -qO- $@ | lynx -stdin -dump";
        log-insight = "date >> ~/modes/spiraling/vault/insights.log && echo \"$@\" >> ~/modes/spiraling/vault/insights.log";
      };
      
      # Sway keybindings for this mode
      xdg.configFile."sway/config.d/spiraling.conf".text = ''
        # Research/Streaming keys
        bindsym $mod+r exec arecord -f cd -t wav $HOME/modes/spiraling/recordings/recording_$(date +%Y%m%d_%H%M%S).wav
        bindsym $mod+t exec ghostty -e zsh -c "cd ~/modes/spiraling && nvim ~/modes/spiraling/vault/research.md"
        bindsym $mod+f exec ghostty -e zsh -c "cd ~/modes/spiraling && curl -X POST http://localhost:5001/v1/completions -H 'Content-Type: application/json' -d '{\"prompt\": \"Fact check: $(wl-paste)\", \"max_tokens\": 500}'"
        bindsym $mod+l exec date >> ~/modes/spiraling/vault/insights.log && wl-paste >> ~/modes/spiraling/vault/insights.log
        bindsym $mod+b exec brave
        bindsym $mod+o exec obsidian
        bindsym $mod+w exec wget -qO- $(wl-paste) | lynx -stdin -dump
      '';
    }
  '';

  # Ensure spiraling mode directory exists with timeout control
  systemd.services.spiraling-mode-setup = {
    description = "Setup spiraling mode workspace with timeout control";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/modes/spiraling/vault
          mkdir -p /home/user/modes/spiraling/recordings
          cat > /home/user/modes/spiraling/.envrc << EOF
        export MODE_ACTIVE=spiraling
        export OBSIDIAN_VAULT=\$HOME/modes/spiraling/vault
        export PATH=\$PATH:\$HOME/modes/spiraling/bin
        export SPIRAL_TIMEOUT=3600
        EOF
          cat > /home/user/modes/spiraling/bin/timer.sh << "EOF"
        #!/usr/bin/env bash
        # Spiral mode timer - prevents excessive time in research mode
        START_TIME=$(date +%s)
        TIMEOUT=3600  # 1 hour
        
        while true; do
          CURRENT_TIME=$(date +%s)
          ELAPSED=$((CURRENT_TIME - START_TIME))
          if [ $ELAPSED -gt $TIMEOUT ]; then
            notify-send -t 5000 "Spiraling Timeout" "You have been in spiraling mode for $((ELAPSED/60)) minutes. Consider switching modes."
            break
          fi
          sleep 300  # Check every 5 minutes
        done
        EOF
          chmod +x /home/user/modes/spiraling/bin/timer.sh
          cat > /home/user/modes/spiraling/README.md << EOF
        # Spiraling Mode
        ## Purpose
        Unconstrained research, voice-to-text, fact-checking, deep exploration.
        ## Limitations
        This mode is timeboxed to 1 hour to prevent unproductive spiraling.
        A timer will notify you when time is up.
        ## Hotkeys
        - \`$mod+r\`: Record audio
        - \`$mod+t\`: Terminal with research notes
        - \`$mod+f\`: Fact-check clipboard content
        - \`$mod+l\`: Log insight from clipboard
        - \`$mod+b\`: Brave browser
        - \`$mod+o\`: Obsidian
        - \`$mod+w\`: Web fetch current URL
        ## Tools
        - Brave: Research
        - Obsidian: Note-taking
        - Voice-to-text: Recording
        - AI: Fact-checking
        - Web tools: Fetching/parsing
        EOF
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}

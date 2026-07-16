{ config, lib, pkgs, ... }:

{
  # Oversoul Nexus - Central dashboard and control
  environment.etc."nixos/oversoul.nix".text = ''
    { config, lib, pkgs, ... }:
    
    {
      # Deploy dashboard files
      home.file = {
        "oversoul/dashboard.html".source = ./home/oversoul/dashboard.html;
        "oversoul/dashboard.txt".source = ./home/oversoul/dashboard.txt;
        "oversoul/config/env-vars.nix".source = ./home/oversoul/env-vars.nix;
        "oversoul/config/networks.nix".source = ./home/oversoul/networks.nix;
        "oversoul/scripts/mode-switch.sh".source = ./home/scripts/mode-switch.sh;
        "oversoul/scripts/ai-control.sh".source = ./home/scripts/ai-control.sh;
        "oversoul/scripts/network-status.sh".source = ./home/scripts/network-status.sh;
        "oversoul/scripts/health-check.sh".source = ./home/scripts/health-check.sh;
        "oversoul/scripts/clean-up.sh".source = ./home/scripts/clean-up.sh;
        "oversoul/scripts/debug-tools.sh".source = ./home/scripts/debug-tools.sh;
        "oversoul/scripts/status.sh".source = ./home/scripts/status.sh;
      };
      
      # Central environment variables
      home.sessionVariables = {
        KOBOLD_API_URL = "http://localhost:5001";
        OBSIDIAN_VAULT_DIR = "$HOME/modes";
        MODE_ACTIVE = "vibing";
        NEXUS_DIR = "$HOME/oversoul";
        AI_MODEL_PATH = "$HOME/models/current-model.gguf";
        SPIRAL_TIMEOUT = "3600";
        DOCKER_HOST = "unix:///run/docker.sock";
        CONTAINER_RUNTIME = "podman";
      };
      
      # Alias for oversoul control
      home.shellAliases = {
        nexus = "cd ~/oversoul";
        os = "cd ~/oversoul && ./scripts/status.sh";
        health = "~/oversoul/scripts/health-check.sh";
        ai-start = "~/oversoul/scripts/ai-control.sh start";
        ai-stop = "~/oversoul/scripts/ai-control.sh stop";
        ai-kill = "~/oversoul/scripts/ai-control.sh kill";
        ai-status = "~/oversoul/scripts/ai-control.sh status";
        mode-switch = "~/oversoul/scripts/mode-switch.sh";
        network-status = "~/oversoul/scripts/network-status.sh";
        clean-up = "~/oversoul/scripts/clean-up.sh";
        debug = "~/oversoul/scripts/debug-tools.sh";
        status = "~/oversoul/scripts/status.sh";
      };
    }
  '';

  # Ensure oversoul directory structure exists
  systemd.services.oversoul-setup = {
    description = "Setup oversoul nexus structure";
    serviceConfig = {
      Type = "oneshot";
      User = "user";
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '
          mkdir -p /home/user/oversoul/{config,scripts,publish}
          mkdir -p /home/user/models
          mkdir -p /home/user/modes
        '
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}

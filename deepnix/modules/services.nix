{ config, lib, pkgs, ... }:

let
  user = "user";
  homeDir = "/home/${user}";
in {
  # KoboldCPP Service
  systemd.services.koboldcpp = {
    description = "KoboldCPP AI Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = user;
      WorkingDirectory = homeDir;
      ExecStart = ''
        ${pkgs.koboldcpp}/bin/koboldcpp \
          --host 0.0.0.0 \
          --port 5001 \
          --model ${homeDir}/models/current-model.gguf \
          --usecublas 0 \
          --contextsize 4096 \
          --threads 4 \
          --blasthreads 2
      '';
      Restart = "on-failure";
      RestartSec = 10;
      Environment = [
        "KOBOLD_API_URL=http://localhost:5001"
        "KOBOLD_MODEL_PATH=${homeDir}/models/current-model.gguf"
      ];
    };
  };

  # Bluetooth service (enabled by default)
  systemd.services.bluetooth = {
    enable = true;
    description = "Bluetooth service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  # NetworkManager service
  systemd.services.NetworkManager = {
    enable = true;
    description = "Network Manager";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  # PipeWire services (enabled by default)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Podman socket
  systemd.sockets.podman = {
    enable = true;
    description = "Podman API Socket";
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "/run/podman/podman.sock" ];
    socketConfig = {
      SocketMode = "0660";
      SocketUser = user;
      SocketGroup = "podman";
    };
  };

  systemd.services.podman = {
    enable = true;
    description = "Podman Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.podman}/bin/podman system service --time=0";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  # Docker service (optional)
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    storageDriver = "btrfs";
  };

  # SSH (disabled by default)
  services.openssh = {
    enable = false;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}

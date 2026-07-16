{ config, lib, pkgs, ... }:
let
  user = config.oversoul.user;
  modelPath = "/home/${user}/models/current-model.gguf";
in
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.dbus.enable = true;
  security.rtkit.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.docker.enable = false;

  systemd.services.koboldcpp = {
    description = "KoboldCPP API service (CPU-only)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      User = user;
      Group = "users";
      WorkingDirectory = "/home/${user}";
      Environment = [ "KOBOLD_API_URL=http://localhost:5001/v1" ];
      ExecStart = "${lib.getExe pkgs.koboldcpp} --host 0.0.0.0 --port 5001 --model ${modelPath}";
      Restart = "on-failure";
      RestartSec = "5s";
      ConditionPathExists = modelPath;
    };
  };
}

{ ... }:
{
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.ufw = {
    enable = true;
    defaultIncoming = "deny";
    defaultOutgoing = "allow";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.openssh.enable = false;
  services.printing.enable = false;
}

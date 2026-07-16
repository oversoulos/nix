{ config, lib, pkgs, ... }:

{
  # Network configuration
  networking = {
    hostName = "nixos-workspace";
    networkmanager = {
      enable = true;
      wifi = {
        backend = "iwd";
        macAddressRandomization = "never";
      };
      dns = "systemd-resolved";
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-vpnc
        networkmanager-openconnect
        networkmanager-strongswan
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 5001 ]; # KoboldCPP
      allowedUDPPorts = [ ];
      # Deny incoming, allow outgoing by default
      # UFW is configured separately for GUI management
    };
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;
            ct state { established, related } accept;
            iifname "lo" accept;
            icmp type { echo-request, echo-reply, destination-unreachable, time-exceeded } accept;
            tcp dport 5001 accept;
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
          }
          chain output {
            type filter hook output priority 0; policy accept;
          }
        }
      '';
    };
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Server";
        ControllerMode = "bredr";
        FastConnectable = "true";
        Name = "NixOS-Workspace";
      };
    };
  };
  services.blueman = {
    enable = true;
    package = pkgs.blueman;
  };

  # DNS
  services.resolved = {
    enable = true;
    dnssec = "false";
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    llmnr = "false";
  };

  # Network packages
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    networkmanager-openvpn
    networkmanager-vpnc
    networkmanager-openconnect
    networkmanager-strongswan
    iwd
    wpa_supplicant
    bluez
    bluez-tools
    blueman
    # Network tools
    mtr
    traceroute
    nmap
    tcpdump
    wireshark-cli
    dnsutils
    dig
    whois
    # VPN tools
    openvpn
    wireguard-tools
    vpnc
    strongswan
    openconnect
  ];

  # Network security
  security.sudo.extraRules = [
    {
      groups = [ "networkmanager" ];
      commands = [
        {
          command = "${pkgs.networkmanager}/bin/nmcli";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl restart NetworkManager";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # UFW (user-friendly firewall)
  services.ufw = {
    enable = true;
    defaultDenyIncoming = true;
    defaultAllowOutgoing = true;
    rules = {
      allowSSH = {
        port = 22;
        proto = "tcp";
        from = "any";
        to = "any";
      };
      allowKobold = {
        port = 5001;
        proto = "tcp";
        from = "any";
        to = "any";
      };
    };
  };
}

{ config, lib, pkgs, ... }:

{
  # Boot settings
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelParams = [ "quiet" "splash" ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    btrfs-progs
    btrfs-assistant
    compsize
    snapper
    # Hardware tools
    hwloc
    cpufrequtils
    lm_sensors
    # System tools
    htop
    btop
    iotop
    iftop
    nload
  ];

  # Systemd services
  systemd.services = {
    # Enable BTRFS balance service
    btrfs-balance = {
      description = "BTRFS balance service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.btrfs-progs}/bin/btrfs balance start /";
      };
      startAt = "weekly";
    };
    # Enable BTRFS scrub
    btrfs-scrub = {
      description = "BTRFS scrub service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.btrfs-progs}/bin/btrfs scrub start /";
      };
      startAt = "monthly";
    };
  };

  # CPU scaling
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Firmware
  hardware = {
    enableRedistributableFirmware = true;
    firmware = with pkgs; [
      linux-firmware
      sof-firmware
    ];
  };

  # Timezone and locale
  time.timeZone = "America/Chicago";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_US.UTF-8";
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "NerdFontsSymbolsOnly" ]; })
      inter
      noto-fonts
      noto-fonts-cjk-sans-serif
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Fira Code" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}

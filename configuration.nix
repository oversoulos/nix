{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/networking.nix
    ./modules/packages.nix
    ./modules/desktop.nix
    ./modules/services.nix
    ./modules/users.nix
    ./modules/modes/mode-switch.nix
    ./modules/modes/vibing.nix
    ./modules/modes/schooling.nix
    ./modules/modes/building.nix
    ./modules/modes/creating.nix
    ./modules/modes/spiraling.nix
    ./modules/oversoul.nix
  ];

  # System configuration
  system.stateVersion = "24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Environment variables
  environment.variables = {
    KOBOLD_API_URL = "http://localhost:5001";
    OBSIDIAN_VAULT_DIR = "~/obsidian-vaults";
    MODE_ACTIVE = "vibing";
    NEXUS_DIR = "~/oversoul";
    AI_MODEL_PATH = "~/models/current-model.gguf";
  };

  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/nvme0n1p2";
    preLVM = false;
  };
  boot.supportedFilesystems = [ "btrfs" ];
}

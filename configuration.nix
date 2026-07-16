{ ... }:
{
  imports = [
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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}

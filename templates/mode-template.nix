# Template for creating new modes
{ config, lib, pkgs, ... }:

{
  # Mode configuration
  home.packages = with pkgs; [
    # Add mode-specific packages here
  ];

  # Mode environment variables
  home.sessionVariables = {
    MODE_NAME = "your-mode-name";
    MODE_COLOR = "#000000"; # Hex color for theme
  };

  # Waybar configuration
  xdg.configFile."waybar/config".source = ./modes/your-mode/waybar-config.jsonc;
  xdg.configFile."waybar/style.css".source = ./modes/your-mode/waybar-style.css;

  # Mode aliases
  home.shellAliases = {
    # Add mode-specific aliases
  };

  # Sway keybindings
  xdg.configFile."sway/config.d/your-mode.conf".text = ''
    # Add mode-specific keybindings
  '';
}

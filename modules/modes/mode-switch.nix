{ config, lib, pkgs, ... }:
let
  cfg = config.oversoul;
  modeNames = builtins.attrNames cfg.modeSpecs;
in
{
  options.oversoul.modeSpecs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        tools = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        hotkeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };
    });
    default = { };
    description = "Per-mode metadata for Oversoul workspaces.";
  };

  config = {
    assertions = [
      {
        assertion = lib.all (name: builtins.hasAttr name cfg.modeSpecs) [ "vibing" "schooling" "building" "creating" "spiraling" ];
        message = "All five required modes must be defined (vibing, schooling, building, creating, spiraling).";
      }
    ];

    environment.etc."oversoul/modes.json".text = builtins.toJSON cfg.modeSpecs;

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "mode-switch";
        runtimeInputs = with pkgs; [ coreutils gnugrep procps sway jq libnotify ];
        text = ''
          set -euo pipefail
          mode="${1:-}"
          if [ -z "$mode" ]; then
            echo "Usage: mode-switch <${lib.concatStringsSep "|" modeNames}>"
            exit 1
          fi
          if ! printf '%s\n' ${lib.concatStringsSep " " modeNames} | tr ' ' '\n' | grep -qx "$mode"; then
            echo "Unknown mode: $mode"
            exit 1
          fi

          mkdir -p "$HOME/.config/oversoul" "$HOME/.config/waybar"
          printf '%s\n' "$mode" > "$HOME/.config/oversoul/active-mode"

          if [ -f "$HOME/modes/$mode/waybar-config.jsonc" ]; then
            cp "$HOME/modes/$mode/waybar-config.jsonc" "$HOME/.config/waybar/config.jsonc"
            pkill -USR2 waybar || true
          fi

          notify-send "Oversoul" "Switched to $mode mode"
          swaymsg reload >/dev/null 2>&1 || true
        '';
      })
      (pkgs.writeShellApplication {
        name = "mode-switch-menu";
        runtimeInputs = with pkgs; [ wofi coreutils ];
        text = ''
          set -euo pipefail
          mode=$(printf '%s\n' ${lib.concatStringsSep " " modeNames} | tr ' ' '\n' | wofi --dmenu --prompt "Select mode")
          [ -z "$mode" ] || exec mode-switch "$mode"
        '';
      })
    ];
  };
}

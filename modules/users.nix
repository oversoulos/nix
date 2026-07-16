{ config, pkgs, ... }:
{
  options.oversoul.user = pkgs.lib.mkOption {
    type = pkgs.lib.types.str;
    default = "oversoulos";
    description = "Primary desktop user";
  };

  config = {
    users.users.${config.oversoul.user} = {
      isNormalUser = true;
      description = "Oversoul Operator";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "bluetooth" "podman" ];
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
    security.sudo.wheelNeedsPassword = true;
  };
}

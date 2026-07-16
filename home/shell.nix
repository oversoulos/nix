{ ... }:
{
  programs.starship.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = import ./aliases.nix;
    initExtra = ''
      export PATH="$HOME/oversoul/scripts:$HOME/scripts:$PATH"
      if [ -f "$HOME/.config/oversoul/active-mode" ]; then
        export MODE_ACTIVE="$(cat "$HOME/.config/oversoul/active-mode")"
      fi
    '';
  };
}

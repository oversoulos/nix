{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    brave
    firefox
    ghostty
    valent
    discord

    vscode
    kate
    git
    direnv
    nodejs
    python3
    gcc
    cmake
    gnumake
    gh

    gimp
    krita
    vlc
    shotcut
    obs-studio

    nemo
    okular
    xarchiver
    p7zip
    obsidian

    koboldcpp
    btop

    waybar
    wofi
    wl-clipboard
    jq
    curl
  ];
}

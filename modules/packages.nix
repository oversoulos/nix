{ config, lib, pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-25.9.0"
      "koboldcpp-1.63"
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Browser & Internet
    brave
    firefox
    discord
    unstable.ghostty
    valent
    
    # Development Tools
    vscode
    kate
    git
    git-lfs
    direnv
    nodejs_22
    python3
    python3Packages.pip
    python3Packages.virtualenv
    gcc
    cmake
    gnumake
    unstable.github-cli
    docker
    docker-compose
    
    # Creative & Media
    gimp
    krita
    vlc
    shotcut
    obs-studio
    unstable.obsidian
    
    # File Management
    nemo
    okular
    xarchiver
    p7zip
    
    # AI & System Tools
    koboldcpp
    btop
    
    # Archive tools
    unzip
    zip
    gzip
    tar
    xz
    
    # System utilities
    age
    sops
    gnupg
    
    # Development tools
    jq
    yq
    ripgrep
    fd
    fzf
    bat
    exa
    zellij
    tmux
    
    # Networking tools
    curl
    wget
    httpx
    httpie
    
    # System monitoring
    htop
    btop
    iotop
    iftop
    nload
    
    # Document tools
    pandoc
    texliveFull
    
    # Other
    tree
    ncdu
    duf
  ];

  # Special packages with specific versions
  environment.etc."nixos/configuration.nix".text = ''
    # Imported via flake
  '';

  # Enable Docker (as optional container runtime)
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      storageDriver = "btrfs";
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    # Allow containers to access host network
    containers = {
      enable = true;
      registries = {
        search = [ "docker.io" ];
      };
    };
  };

  # Docker/Podman group
  users.groups = {
    docker = { };
    podman = { };
  };

  # Session variables for container runtimes
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/docker.sock";
    CONTAINER_RUNTIME = "podman";
  };

  # Add users to docker/podman groups
  users.users.user.extraGroups = [ "docker" "podman" ];
}

{ config, lib, pkgs, ... }:

{
  # Display manager
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "user";
        };
      };
    };
    
    # Sway (Wayland compositor)
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_DESKTOP=sway
        export XDG_SESSION_TYPE=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export GDK_BACKEND=wayland,x11
        export MOZ_ENABLE_WAYLAND=1
        export CLUTTER_BACKEND=wayland
        export SDL_VIDEODRIVER=wayland
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    
    # PipeWire audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Hardware acceleration
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          intel-media-driver
          vaapiIntel
        ];
      };
    };
  };

  # X11/Wayland support
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Desktop environment packages
  environment.systemPackages = with pkgs; [
    # Wayland tools
    wl-clipboard
    wlr-randr
    wf-recorder
    slurp
    grim
    swayidle
    swaylock-effects
    waybar
    mako
    wofi
    
    # GTK themes
    papirus-icon-theme
    adwaita-icon-theme
    gnome.adwaita-icon-theme
    gnome.adwaita-qt
    
    # GTK apps
    nautilus
    eog
    evince
    
    # Fonts
    inter
    noto-fonts
    noto-fonts-emoji
    
    # Theme utilities
    lxappearance
    qt5ct
    qt6ct
    
    # Screenshot tools
    flameshot
    spectacle
  ];

  # GTK theme settings
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    font = {
      name = "Inter";
      size = 11;
    };
  };

  # QT theme settings
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Automatic login (for development, change for production)
  services.greetd.settings.initial_session = {
    command = "${pkgs.sway}/bin/sway";
    user = "user";
  };
}

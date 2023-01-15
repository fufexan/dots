{ config, pkgs, ...}: let
   flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  # Hyprland
  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
  }).defaultNix;

  # Hyprland XDG-Desktop Portal
  xdph = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/fufexan/webcord-flake/archive/refs/heads/master.zip";
  }).defaultNix;

  # Hyprland desktop portal
  xdg-desktop-portal-hyprland = xdph.packages.${pkgs.system}.default.override {
    hyprland-share-picker = xdph.packages.${pkgs.system}.hyprland-share-picker.override {inherit hyprland;};
  };

  # Webcord
  webcord = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/fufexan/webcord-flake/archive/refs/heads/master.zip";
  }).defaultNix;
in {
  imports = [
     hyprland.nixosModules.default
  ];

  # make stuff work on wayland
  environment.variables = {
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
  };

  environment.systemPackages = with pkgs; [
    wayland
    wdisplays
    wlr-randr
    eww-wayland
    wofi
    xdg-desktop-portal-hyprland


    # polkit
    polkit

    # discord but based
    webcord.packages.${pkgs.system}.default
  ];

  # Fix cursor for Nvidia
  environment.variables.WLR_NO_HARDWARE_CURSORS = "1";

  # Enable polkit
  security.polkit.enable = true;

  # Nvidia fix
  hardware.nvidia.modesetting.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      hidpi = true;
    };
    package = hyprland.packages.${pkgs.system}.default;
    nvidiaPatches = true;
  };
}

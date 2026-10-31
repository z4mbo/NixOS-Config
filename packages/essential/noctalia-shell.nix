{ inputs, pkgs, ... }:

# Noctalia v5: bar, control center, notifications, OSDs, wallpaper, lock screen,
# clipboard history, polkit agent. Started by niri (see niri.nix).
#
# Dotfiles:
#   ~/.config/noctalia/config.toml           -> base config below (read-only, from Nix)
#   ~/.config/noctalia/palettes/Monochrome.json -> black/grey palette (noctalia-monochrome.json)
#   ~/.local/state/noctalia/settings.toml   -> changes made in Noctalia's Settings GUI
#                                             (these win over config.toml)
let
  home = "/home/z4mbo";

  config = pkgs.writeText "noctalia-config.toml" ''
    [shell]
    font_family = "JetBrainsMono Nerd Font"
    polkit_agent = true            # password prompts for pkexec / GNOME apps
    telemetry_enabled = false
    setup_wizard_enabled = false

    [shell.greeter_sync]
    auto_sync = true               # login screen follows wallpaper/colors/font

    [theme]
    mode = "dark"
    source = "custom"
    custom_palette = "Monochrome"
    sync_color_scheme = true       # GTK/Qt/Electron apps follow dark mode

    [theme.templates]
    enable_builtin_templates = true
    builtin_ids = ["gtk3", "gtk4"] # GTK apps (Nautilus, GNOME apps...) use the palette

    [wallpaper]
    enabled = true
    directory = "${home}/Pictures/Wallpapers"
    fill_mode = "crop"
    fill_color = "surface"

    [wallpaper.default]
    path = "${home}/Pictures/Wallpapers/2.png"

    [brightness]
    enable_ddcutil = true          # external monitors over DDC/CI

    [hooks]
    # Keep GNOME's wallpaper in sync with the one picked in Noctalia.
    wallpaper_changed = "gsettings set org.gnome.desktop.background picture-uri \"file://$NOCTALIA_WALLPAPER_PATH\"; gsettings set org.gnome.desktop.background picture-uri-dark \"file://$NOCTALIA_WALLPAPER_PATH\""

    [bluetooth]
    connect_when_enabled = true
    connection_notifications = true
  '';
in
{
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.ddcutil
    pkgs.libheif # HEIC/AVIF wallpapers
    pkgs.adw-gtk3 # GTK3 theme that Noctalia's GTK template recolors
  ];

  # Services Noctalia's control center talks to.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery level of BT headsets
  };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true; # avatar shared with the login screen
  services.geoclue2.enable = true; # weather / night-light location

  # Brightness for desktop monitors over DDC/CI.
  hardware.i2c.enable = true;
  users.users.z4mbo.extraGroups = [ "i2c" ];

  systemd.tmpfiles.rules = [
    "d ${home}/.config/noctalia 0755 z4mbo users -"
    "d ${home}/.config/noctalia/palettes 0755 z4mbo users -"
    "L+ ${home}/.config/noctalia/config.toml - - - - ${config}"
    "L+ ${home}/.config/noctalia/palettes/Monochrome.json - - - - ${./noctalia-monochrome.json}"
  ];
}

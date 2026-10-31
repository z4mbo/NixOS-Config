{ lib, pkgs, ... }:

# GNOME as a second desktop, selectable from the login screen's session menu.
# Kept lean, dark, and on the same wallpaper as Noctalia.
{
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-tour
    gnome-music
    gnome-maps
    gnome-contacts
    gnome-weather
    totem
    yelp
    simple-scan
  ];

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "Adwaita-dark";
        };
        # Default only; Noctalia's wallpaper_changed hook keeps it in sync.
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/z4mbo/Pictures/Wallpapers/2.png";
          picture-uri-dark = "file:///home/z4mbo/Pictures/Wallpapers/2.png";
          picture-options = "zoom";
        };
        "org/gnome/desktop/input-sources" = {
          sources = [ (lib.gvariant.mkTuple [ "xkb" "it" ]) ];
        };
      };
    }
  ];
}

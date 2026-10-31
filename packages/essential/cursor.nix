{ pkgs, ... }:

# Cursor: Bibata Modern Classic (sleek black with a thin white outline), so it
# reads well on both the dark and light themes. Used by niri, GTK/GNOME,
# Electron/Chromium apps (XCURSOR_*) and the login screen (login.nix).
let
  theme = "Bibata-Modern-Classic";
  size = 24;
in
{
  environment.systemPackages = [ pkgs.bibata-cursors ];

  environment.sessionVariables = {
    XCURSOR_THEME = theme;
    XCURSOR_SIZE = toString size;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        cursor-theme = theme;
        cursor-size = pkgs.lib.gvariant.mkInt32 size;
      };
    }
  ];
}

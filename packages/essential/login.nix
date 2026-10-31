{ config, pkgs, ... }:

# Login screen: Noctalia Greeter (greetd). Noctalia auto-syncs its wallpaper,
# palette, font and monitor layout into the greeter whenever you change them
# ([shell.greeter_sync] in noctalia-shell.nix), so login always matches the
# desktop. Pick niri or GNOME from the session selector on the login screen.
{
  services.displayManager = {
    defaultSession = "niri";
    noctalia-greeter = {
      enable = true;
      # Noctalia may push appearance updates to the greeter without a password.
      passwordlessSyncUsers = [ "z4mbo" ];
      settings = {
        session.default = "niri";
        # Always the look synced from Noctalia; no scheme picker on the login screen.
        appearance = {
          scheme = "Synced";
          scheme_selector_position = "hidden";
        };
        keyboard.layout = "it";
        cursor = {
          theme = "Adwaita";
          size = 24;
          path = pkgs.adwaita-icon-theme;
        };
      };
    };
  };

  # Point the greeter at every installed session (niri + GNOME); the nixpkgs
  # module otherwise only sees sessions that happen to be in the system PATH.
  services.greetd.settings.default_session.command =
    "${pkgs.coreutils}/bin/env XDG_DATA_DIRS=${config.services.displayManager.sessionData.desktops}/share "
    + "${config.services.displayManager.noctalia-greeter.package}/bin/noctalia-greeter-session";

  # Unlock gnome-keyring with the login password.
  security.pam.services.greetd.enableGnomeKeyring = true;
}

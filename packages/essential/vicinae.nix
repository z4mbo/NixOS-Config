{ pkgs, ... }:

# Vicinae: Raycast-style launcher (apps, calculator, clipboard history, emoji,
# file search, window switcher, Raycast-compatible extensions). Super+Space.

let
  home = "/home/z4mbo";

  # Black/grey theme matching noctalia's "Monochrome" color scheme.
  theme = pkgs.writeText "monochrome.toml" ''
    [meta]
    name = "Monochrome"
    description = "Black theme matching the noctalia Monochrome scheme"
    variant = "dark"
    inherits = "vicinae-dark"

    [colors.core]
    accent = "#aaaaaa"
    accent_foreground = "#111111"
    background = "#111111"
    foreground = "#eeeeee"
    secondary_background = "#1c1c1c"
    border = "#333333"

    [colors.main_window]
    border = "colors.core.border"
    footer = { background = "colors.core.secondary_background" }

    [colors.settings_window]
    border = "#333333"

    [colors.shortcut]
    border = "colors.core.border"

    [colors.text]
    default = "colors.core.foreground"
    muted = "#999999"
    danger = "#e06c75"
    success = "#98c379"
    placeholder = "#666666"
    selection = { background = "#aaaaaa", foreground = "#111111" }

    [colors.text.links]
    default = "#cccccc"
    visited = "#999999"

    [colors.input]
    border = "#333333"
    border_focus = "#aaaaaa"
    border_error = "#e06c75"

    [colors.button.primary]
    background = "#1c1c1c"
    foreground = "#eeeeee"
    hover = { background = "#282828" }
    focus = { outline = "#aaaaaa" }

    [colors.list.item.hover]
    foreground = "#ffffff"
    secondary_foreground = "#aaaaaa"

    [colors.list.item.selection]
    background = "#2a2a2a"
    foreground = "#ffffff"
    secondary_background = "#aaaaaa"
    secondary_foreground = "#111111"

    [colors.grid.item]
    background = "#1c1c1c"
    hover = { outline = "#aaaaaa" }
    selection = { outline = "#ffffff" }

    [colors.scrollbars]
    background = "#333333"

    [colors.loading]
    bar = "#aaaaaa"
    spinner = "#eeeeee"
  '';

  # Settings managed by Nix. ~/.config/vicinae/settings.json only imports this
  # file, so tweaks made in the Vicinae settings window still work and win.
  settings = pkgs.writeText "vicinae-nix.json" (builtins.toJSON {
    telemetry.system_info = false;
    escape_key_behavior = "close_window";
    pop_to_root_on_close = true;
    font.normal = {
      family = "JetBrainsMono Nerd Font";
      size = 11;
    };
    theme.dark = {
      name = "monochrome";
      icon_theme = "auto";
    };
    launcher_window = {
      size = {
        width = 800;
        height = 500;
      };
      client_side_decorations = {
        enabled = true;
        border_width = 1;
      };
    };
  });
in
{
  environment.systemPackages = [ pkgs.vicinae ];

  # Background server so Super+Space opens instantly (niri sessions only).
  systemd.packages = [ pkgs.vicinae ];
  systemd.user.services.vicinae.wantedBy = [ "niri.service" ];

  systemd.tmpfiles.rules = [
    "d ${home}/.config/vicinae 0755 z4mbo users -"
    "L+ ${home}/.config/vicinae/nix.json - - - - ${settings}"
    ''f ${home}/.config/vicinae/settings.json 0644 z4mbo users - {"imports": ["./nix.json"]}''
    "d ${home}/.local/share/vicinae 0755 z4mbo users -"
    "d ${home}/.local/share/vicinae/themes 0755 z4mbo users -"
    "L+ ${home}/.local/share/vicinae/themes/monochrome.toml - - - - ${theme}"
  ];
}

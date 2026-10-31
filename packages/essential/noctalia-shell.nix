{ inputs, pkgs, ... }:

# Noctalia v5: bar, control center, notifications, OSDs, wallpaper, lock screen,
# clipboard history, polkit agent. Started by niri (see niri.nix).
#
# Dotfiles:
#   ~/.config/noctalia/config.toml              -> base config below (read-only, from Nix)
#   ~/.config/noctalia/palettes/Monochrome.json -> black/grey palette (noctalia-monochrome.json)
#   ~/.local/state/noctalia/settings.toml       -> everything you change in Noctalia's
#                                                 Settings GUI (wins over config.toml)
#
# GUI settings are never lost: every time settings.toml changes it's copied to
# noctalia-settings.toml in this repo (committed + pushed by `update`), and on a
# fresh install that copy is restored if settings.toml doesn't exist yet.
let
  home = "/home/z4mbo";

  config = pkgs.writeText "noctalia-config.toml" ''
    [shell]
    font_family = "JetBrainsMono Nerd Font"
    polkit_agent = true            # password prompts for pkexec / GNOME apps
    telemetry_enabled = false
    setup_wizard_enabled = false

    [accessibility]
    ui_scale = 1.15                # launcher, control center, panels a bit larger

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

    # Layout ported from the old v4 setup.
    [bar.default]
    position = "top"
    radius = 12
    thickness = 40
    scale = 1.15
    padding = 16
    widget_spacing = 10
    capsule = false
    start = ["launcher", "workspace_apps"]
    center = ["active_window", "clock", "media"]
    end = ["tray", "notifications", "volume", "brightness", "control_center", "cpu_temp", "cpu", "ram"]

    # Workspaces as groups of the app icons open on each one.
    [widget.workspace_apps]
    type = "taskbar"
    group_by_workspace = true
    show_running = true
    show_all_outputs = false
    only_active_workspace = false
    hide_empty_workspaces = true
    show_workspace_label = true
    workspace_label_placement = "corner"
    workspace_group_capsule = true
    workspace_group_content = "icons"
    workspace_group_active_border_color = "primary"
    workspace_group_inactive_border_color = "outline_variant"
    group_single_icon_per_app = true
    prefer_symbolic_icons = false
    show_active_indicator = true
    active_indicator_color = "primary"

    [widget.active_window]
    max_length = 300
    title_scroll = "on_hover"

    [widget.clock]
    format = "{:%H:%M %a, %b %d}"
    tooltip_format = "{:%A, %B %d, %Y}"

    [widget.media]
    artist_first = true
    hide_when_no_media = true

    [widget.cpu_temp]
    type = "sysmon"
    stat = "cpu_temp"

    [widget.cpu]
    type = "sysmon"
    stat = "cpu_usage"

    [widget.ram]
    type = "sysmon"
    stat = "ram_used"

    [shell.launcher]
    categories = false
    track_usage = true

    [notification]
    position = "top_right"

    [osd]
    position = "top_right"
  '';

  # Copies GUI settings into the repo whenever Noctalia saves them.
  backupSettings = pkgs.writeShellScript "noctalia-settings-backup" ''
    src="$HOME/.local/state/noctalia/settings.toml"
    dst=/etc/nixos/packages/essential/noctalia-settings.toml
    [ -f "$src" ] && ! ${pkgs.diffutils}/bin/cmp -s "$src" "$dst" && cp "$src" "$dst"
    exit 0
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
    # Restore GUI settings from the repo only if none exist yet (fresh install).
    "d ${home}/.local/state/noctalia 0700 z4mbo users -"
    "C ${home}/.local/state/noctalia/settings.toml - - - - ${./noctalia-settings.toml}"
    "z ${home}/.local/state/noctalia/settings.toml 0644 z4mbo users -"
  ];

  systemd.user.services.noctalia-settings-backup = {
    description = "Copy Noctalia GUI settings into /etc/nixos";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = backupSettings;
    };
  };

  systemd.user.paths.noctalia-settings-backup = {
    wantedBy = [ "default.target" ];
    pathConfig.PathChanged = "%h/.local/state/noctalia/settings.toml";
  };
}

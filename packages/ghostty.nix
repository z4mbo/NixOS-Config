{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ghostty
  ];

  # Monochrome dark + light themes (noctalia "Monochrome" palette). Ghostty
  # switches between them live when the system color scheme flips (Noctalia
  # drives that: auto by sunrise/sunset, or dark/light by hand).
  #
  # ANSI slots keep the same *meaning* in both: 0 = raised surface, 8 = dim
  # text, 7/15 = normal/strong text. So anything drawn with ANSI colors
  # (starship, tmux, eza, tv, Helix, Claude Code, opencode...) flips with it.
  environment.etc."xdg/ghostty/themes/monochrome-dark".text = ''
    background = #111111
    foreground = #e0e0e0
    cursor-color = #e0e0e0
    cursor-text = #111111
    selection-background = #3c3c3c
    selection-foreground = #ffffff
    palette = 0=#1c1c1c
    palette = 1=#d07a7a
    palette = 2=#9fbf8f
    palette = 3=#d8c38c
    palette = 4=#8fa8c8
    palette = 5=#b89ac8
    palette = 6=#8fc0c0
    palette = 7=#cccccc
    palette = 8=#6a6a6a
    palette = 9=#e08f8f
    palette = 10=#b4d4a4
    palette = 11=#ead6a0
    palette = 12=#a6bedc
    palette = 13=#ccb0dc
    palette = 14=#a6d4d4
    palette = 15=#ffffff
  '';

  environment.etc."xdg/ghostty/themes/monochrome-light".text = ''
    background = #f5f5f5
    foreground = #262626
    cursor-color = #262626
    cursor-text = #f5f5f5
    selection-background = #d4d4d4
    selection-foreground = #000000
    palette = 0=#e6e6e6
    palette = 1=#b04a4a
    palette = 2=#4d7a3d
    palette = 3=#8a6a1c
    palette = 4=#3d5d8a
    palette = 5=#7a4d8a
    palette = 6=#3d7a7a
    palette = 7=#3a3a3a
    palette = 8=#8a8a8a
    palette = 9=#c05050
    palette = 10=#5a8a48
    palette = 11=#9a7820
    palette = 12=#4a6a9a
    palette = 13=#8a5a9a
    palette = 14=#4a8a8a
    palette = 15=#0a0a0a
  '';

  environment.etc."xdg/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 18
    font-feature = calt
    font-feature = liga
    adjust-cell-height = 18%
    theme = light:/etc/xdg/ghostty/themes/monochrome-light,dark:/etc/xdg/ghostty/themes/monochrome-dark
    background-opacity = 0.96
    background-blur = true
    window-padding-x = 24
    window-padding-y = 20
    window-padding-balance = true
    window-padding-color = extend
    window-decoration = none
    cursor-style = bar
    cursor-style-blink = true
    mouse-hide-while-typing = true
    copy-on-select = clipboard
    unfocused-split-opacity = 0.85
    mouse-scroll-multiplier = 3
    command = ${pkgs.fish}/bin/fish
    shell-integration = fish
    shell-integration-features = cursor,sudo,title
    desktop-notifications = true
    notify-on-command-finish = unfocused
    notify-on-command-finish-action = no-bell,notify
    notify-on-command-finish-after = 10s
  '';

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config 0755 z4mbo users -"
    "d /home/z4mbo/.config/ghostty 0755 z4mbo users -"
    "r /home/z4mbo/.config/ghostty/config.ghostty"
    "L+ /home/z4mbo/.config/ghostty/config - - - - /etc/xdg/ghostty/config"
  ];
}

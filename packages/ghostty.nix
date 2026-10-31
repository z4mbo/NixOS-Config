{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ghostty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Black theme matching the noctalia "Monochrome" color scheme.
  environment.etc."xdg/ghostty/themes/monochrome".text = ''
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
    palette = 8=#57514e
    palette = 9=#e08f8f
    palette = 10=#b4d4a4
    palette = 11=#ead6a0
    palette = 12=#a6bedc
    palette = 13=#ccb0dc
    palette = 14=#a6d4d4
    palette = 15=#ffffff
  '';

  environment.etc."xdg/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 18
    theme = /etc/xdg/ghostty/themes/monochrome
    background-opacity = 1
    window-padding-x = 15
    window-padding-y = 15
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

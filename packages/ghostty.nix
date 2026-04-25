{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ghostty
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  environment.etc."xdg/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 18
    theme = "Rose Pine Moon"
    background = #232136
    background-opacity = 1
    background-blur = 32
    window-padding-x = 15
    window-padding-y = 15
    mouse-scroll-multiplier = 3
    command = ${pkgs.zsh}/bin/zsh
    shell-integration = zsh
    shell-integration-features = cursor,sudo,title
    desktop-notifications = true
    notify-on-command-finish = unfocused
    notify-on-command-finish-action = no-bell,notify
    notify-on-command-finish-after = 10s
  '';

  programs.zsh.interactiveShellInit = ''
    if [[ "$TERM" == "xterm-ghostty" ]]; then
      builtin source ${pkgs.ghostty.shell_integration}/zsh/ghostty-integration
    fi
  '';

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config 0755 z4mbo users -"
    "d /home/z4mbo/.config/ghostty 0755 z4mbo users -"
    "r /home/z4mbo/.config/ghostty/config.ghostty"
    "L+ /home/z4mbo/.config/ghostty/config - - - - /etc/xdg/ghostty/config"
  ];
}

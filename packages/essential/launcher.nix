{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fuzzel
  ];

  environment.etc."xdg/fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=14
    prompt="> "
    width=32
    horizontal-pad=16
    vertical-pad=12
    inner-pad=10
    line-height=22

    [colors]
    background=000000ee
    text=ffffffff
    prompt=5277c3ff
    placeholder=8a8a8aff
    input=ffffffff
    match=5277c3ff
    selection=1a1a1aff
    selection-text=ffffffff
    border=5277c3ff
  '';

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config/fuzzel 0755 z4mbo users -"
    "L+ /home/z4mbo/.config/fuzzel/fuzzel.ini - - - - /etc/xdg/fuzzel/fuzzel.ini"
  ];
}

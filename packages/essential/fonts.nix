{ lib, pkgs, ... }:

# One font everywhere: JetBrainsMono Nerd Font for UI, documents and code
# (fontconfig defaults are what Helium, Electron and Qt apps fall back to;
# the GNOME keys cover GTK apps and GNOME itself).
let
  font = "JetBrainsMono Nerd Font";
in
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
      noto-fonts-cjk-sans # Japanese/Chinese/Korean text
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ font "Noto Sans CJK JP" ];
      serif = [ font "Noto Sans CJK JP" ];
      monospace = [ font ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        font-name = "${font} 12";
        document-font-name = "${font} 12";
        monospace-font-name = "${font} 12";
        font-antialiasing = "rgba";
        font-hinting = "slight";
      };
    }
  ];
}

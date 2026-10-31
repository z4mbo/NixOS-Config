{ pkgs, ... }:

# Battle.net runs through Wine. Lutris has a maintained one-click installer:
# open Lutris -> "+" -> "Search the Lutris website for installers" -> Battle.net.
# It uses umu/GE-Proton automatically.
{
  environment.systemPackages = with pkgs; [
    lutris
    umu-launcher
    wineWow64Packages.stagingFull
    winetricks
  ];
}

{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    # extest currently injects a preload that is breaking Steam's 32-bit pieces.
    extest.enable = false;
    # GE-Proton: community Proton with extra game fixes and codecs.
    # Pick it per game under Properties -> Compatibility.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    protontricks.enable = true;
  };

  # Per-game performance mode. Launch options: `gamemoderun %command%`
  programs.gamemode.enable = true;

  # Micro-compositor for games: `gamescope -W 2560 -H 1440 -r 360 -- %command%`
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud # FPS/frametime overlay: `mangohud %command%`
  ];
}

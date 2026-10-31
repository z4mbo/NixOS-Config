{ pkgs, ... }:

# Unreal Engine isn't in nixpkgs (Epic's license requires logging in to
# download). Install it once by hand:
#   1. Download "Linux_Unreal_Engine_<version>.zip" from https://www.unrealengine.com/linux
#   2. Unzip it to ~/Applications/UnrealEngine  (so Engine/ is directly inside)
# Then launch "Unreal Engine" from the launcher (or `unreal-engine` in a terminal).
# It runs inside an FHS environment with the libraries the editor expects.
let
  unrealFhs = pkgs.buildFHSEnv {
    name = "unreal-engine";
    targetPkgs =
      p: with p; [
        vulkan-loader
        libGL
        libglvnd
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxrandr
        libxi
        libxext
        libxrender
        libxfixes
        libxscrnsaver
        libsm
        libice
        alsa-lib
        libpulseaudio
        icu
        openssl
        zlib
        nss
        nspr
        expat
        fontconfig
        freetype
        dbus
        udev
        glib
        gtk3
        xdg-user-dirs
        which
        python3
      ];
    runScript = pkgs.writeShellScript "unreal-engine-run" ''
      ue_root="''${UE_ROOT:-$HOME/Applications/UnrealEngine}"
      editor="$ue_root/Engine/Binaries/Linux/UnrealEditor"
      if [ ! -x "$editor" ]; then
        echo "Unreal Editor not found at $editor" >&2
        echo "Download it from https://www.unrealengine.com/linux and unzip to $ue_root" >&2
        exit 1
      fi
      exec "$editor" "$@"
    '';
  };

  desktop = pkgs.makeDesktopItem {
    name = "unreal-engine";
    desktopName = "Unreal Engine";
    comment = "Unreal Editor (manually installed in ~/Applications/UnrealEngine)";
    exec = "unreal-engine %U";
    icon = "applications-games";
    categories = [ "Development" "Game" ];
  };
in
{
  environment.systemPackages = [
    unrealFhs
    desktop
  ];
}

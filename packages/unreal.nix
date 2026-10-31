{ lib, pkgs, ... }:

# Unreal Engine isn't in nixpkgs (Epic requires logging in to download it).
#   1. Sign in at https://www.unrealengine.com/linux in Helium and download the
#      latest "Linux_Unreal_Engine_<version>.zip" into ~/Downloads.
#   2. Launch "Unreal Engine": the first run unpacks the zip into
#      ~/Applications/UnrealEngine (notifications show progress), then opens it.
# If nothing is downloaded yet, launching it opens the download page instead.
# The editor runs inside an FHS environment with the libraries it expects.
let
  ueRoot = "$HOME/Applications/UnrealEngine";

  icon = pkgs.fetchurl {
    url = "https://cdn.simpleicons.org/unrealengine/ffffff";
    name = "unreal-engine.svg";
    hash = "sha256-zU2k1MbWjOmfSX2QK0xhh8WTHPdOH5gsqGoBXCSoA70=";
  };

  fhs = pkgs.buildFHSEnv {
    name = "unreal-engine-fhs";
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
        # Chromium Embedded Framework (web browser/Fab panels) + GTK dialogs
        stdenv.cc.cc.lib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        pango
        gdk-pixbuf
        cups
        libdrm
        libgbm
        libxcb
        libxcomposite
        libxdamage
        libxtst
        libxshmfence
        libxkbfile
        libuuid
        libsecret
        mono
        dotnet-sdk_8
        xdg-utils
      ];
    runScript = pkgs.writeShellScript "unreal-engine-run" ''
      export LD_LIBRARY_PATH=/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
      export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
      export VK_ICD_FILENAMES=$(ls /run/opengl-driver/share/vulkan/icd.d/nvidia_icd*.json 2>/dev/null | head -n1)
      exec "${ueRoot}/Engine/Binaries/Linux/UnrealEditor" "$@"
    '';
  };

  notify = "${lib.getExe pkgs.libnotify} -a 'Unreal Engine' -i ${icon}";

  launcher = pkgs.writeShellScriptBin "unreal-engine" ''
    set -u
    root="${ueRoot}"
    editor="$root/Engine/Binaries/Linux/UnrealEditor"

    if [ ! -x "$editor" ]; then
      zip=$(ls -t "$HOME"/Downloads/Linux_Unreal_Engine*.zip 2>/dev/null | head -n1)
      if [ -z "$zip" ]; then
        ${notify} "Unreal Engine isn't installed yet" \
          "Sign in and download the latest Linux zip into ~/Downloads, then launch Unreal Engine again."
        exec ${pkgs.xdg-utils}/bin/xdg-open https://www.unrealengine.com/linux
      fi

      ${notify} "Installing Unreal Engine" "Unpacking $(basename "$zip"). This takes a few minutes…"
      tmp="$root.partial"
      rm -rf "$tmp"; mkdir -p "$tmp"
      if ! ${lib.getExe pkgs.unzip} -q "$zip" -d "$tmp"; then
        ${notify} -u critical "Unreal Engine install failed" "Couldn't unpack $zip"
        exit 1
      fi
      # The zip may or may not have a top-level folder around Engine/.
      engine=$(find "$tmp" -maxdepth 2 -type d -name Engine | head -n1)
      rm -rf "$root"
      mv "$(dirname "$engine")" "$root"
      rm -rf "$tmp"
      chmod +x "$editor" 2>/dev/null || true
      ${notify} "Unreal Engine installed" "Starting the editor…"
    fi

    cd "$HOME"
    exec ${fhs}/bin/unreal-engine-fhs "$@"
  '';

  desktop = pkgs.makeDesktopItem {
    name = "UnrealEditor";
    desktopName = "Unreal Engine";
    comment = "Unreal Editor";
    exec = "unreal-engine %U";
    icon = "${icon}";
    startupWMClass = "UnrealEditor";
    categories = [ "Development" "Game" ];
  };
in
{
  environment.systemPackages = [
    launcher
    desktop
  ];
}

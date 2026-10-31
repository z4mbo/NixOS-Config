# Run an official vendor .deb (Electron/Chromium app) on NixOS: unpack it and
# launch its binary inside an FHS environment with the usual desktop libraries.
{
  pkgs,
  pname,
  version,
  src,
  # Path of the real executable inside the .deb, e.g. "usr/lib/foo/foo".
  executable,
  # .desktop file inside the .deb, e.g. "usr/share/applications/foo.desktop".
  desktopFile,
  # Icon file inside the .deb.
  icon,
  # MIME types to drop from the .desktop file (e.g. http/https browser claims).
  dropMimeTypes ? [ ],
}:
let
  unpacked = pkgs.stdenvNoCC.mkDerivation {
    pname = "${pname}-unpacked";
    inherit version src;
    nativeBuildInputs = [ pkgs.dpkg ];
    # --no-same-permissions: the store can't hold the SUID chrome-sandbox bit.
    unpackPhase = "mkdir -p $out && dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner -C $out";
    dontBuild = true;
    dontInstall = true;
    dontFixup = true;
  };

  libs =
    p: with p; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libGL
      libglvnd
      libnotify
      libpulseaudio
      libsecret
      libusb1
      libuuid
      libxkbcommon
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxscrnsaver
      libxshmfence
      libxtst
      nspr
      nss
      openssl
      pango
      pipewire
      stdenv.cc.cc.lib
      systemd
      tpm2-tss
      vulkan-loader
      wayland
      xdg-utils
      xz
      zlib
    ];

  dropMime = pkgs.lib.concatMapStrings (m: "; s|${m};||g") dropMimeTypes;
in
pkgs.buildFHSEnv {
  name = pname;
  inherit version;
  targetPkgs = libs;
  runScript = pkgs.writeShellScript "${pname}-run" ''
    export ELECTRON_OZONE_PLATFORM_HINT=auto
    # Use the system GPU driver (NVIDIA) instead of the FHS env's Mesa.
    export LD_LIBRARY_PATH=/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d
    export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS=/run/opengl-driver/share/egl/egl_external_platform.d
    export GBM_BACKENDS_PATH=/run/opengl-driver/lib/gbm
    export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri
    # niri isn't a desktop Chromium knows, so name the keyring backend explicitly.
    exec ${unpacked}/${executable} --ozone-platform=wayland --password-store=gnome-libsecret "$@"
  '';

  extraInstallCommands = ''
    install -Dm444 ${unpacked}/${desktopFile} $out/share/applications/${baseNameOf desktopFile}
    sed -i -E 's|^Exec=[^ ]+|Exec=${pname}|${dropMime}' $out/share/applications/${baseNameOf desktopFile}
    sed -i -E 's|^Icon=.*|Icon=${pname}|' $out/share/applications/${baseNameOf desktopFile}
    install -Dm444 ${unpacked}/${icon} $out/share/icons/hicolor/256x256/apps/${pname}.png
  '';

  passthru = { inherit unpacked; };
}

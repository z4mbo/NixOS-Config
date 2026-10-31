{ pkgs, ... }:

# Helium browser (privacy-focused Chromium, https://helium.computer), packaged
# from the official AppImage since it isn't in nixpkgs. To update: bump
# `version` and replace `hash` with the sha256 listed on the GitHub release.
let
  pname = "helium";
  version = "0.20.3.1";

  src = pkgs.fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-H69Thkj+FKHqkuMlyxI4rojEeGZsteY9DSrxcP5MoDc=";
  };

  contents = pkgs.appimageTools.extract { inherit pname version src; };

  helium = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      desktop=$(find ${contents} -maxdepth 1 -name '*.desktop' | head -n1)
      install -Dm444 "$desktop" $out/share/applications/helium.desktop
      substituteInPlace $out/share/applications/helium.desktop \
        --replace-quiet 'Exec=AppRun' 'Exec=helium' \
        --replace-quiet 'Exec=helium-wrapper' 'Exec=helium' \
        --replace-quiet 'Exec=chromium' 'Exec=helium'
      if [ -d ${contents}/usr/share/icons ]; then
        mkdir -p $out/share
        cp -r ${contents}/usr/share/icons $out/share/
      fi
    '';
  };
in
{
  environment.systemPackages = [ helium ];

  xdg.mime.defaultApplications = {
    "text/html" = "helium.desktop";
    "x-scheme-handler/http" = "helium.desktop";
    "x-scheme-handler/https" = "helium.desktop";
    "x-scheme-handler/about" = "helium.desktop";
    "x-scheme-handler/unknown" = "helium.desktop";
  };
}

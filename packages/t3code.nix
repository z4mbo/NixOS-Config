{ lib, pkgs, ... }:

# T3 Code (nightly channel). Nightlies ship several times a day, so instead of
# pinning a version here, the AppImage lives in ~/Applications and updates
# itself through its built-in updater. The launcher downloads the newest
# nightly the first time (or if the file goes missing).
let
  appImage = "$HOME/Applications/T3-Code-nightly.AppImage";

  launcher = pkgs.writeShellScriptBin "t3code" ''
    set -eu
    app="${appImage}"
    if [ ! -x "$app" ]; then
      mkdir -p "$(dirname "$app")"
      url=$(${lib.getExe pkgs.curl} -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases?per_page=20" \
        | ${lib.getExe pkgs.jq} -r '[.[] | select(.tag_name | test("nightly"))][0].assets[]
            | select(.name | test("x86_64\\.AppImage$")) | .browser_download_url')
      ${lib.getExe pkgs.libnotify} -a "T3 Code" "Downloading T3 Code nightly…" || true
      ${lib.getExe pkgs.curl} -fL --progress-bar -o "$app.part" "$url"
      chmod +x "$app.part"
      mv "$app.part" "$app"
    fi
    export APPIMAGE="$app"
    exec ${lib.getExe pkgs.appimage-run} "$app" "$@"
  '';

  # Named after the app's Wayland app-id so the bar/taskbar shows the right icon.
  desktop = pkgs.makeDesktopItem {
    name = "com.t3tools.T3Code";
    desktopName = "T3 Code";
    comment = "Coding agent GUI (nightly)";
    exec = "t3code %U";
    icon = "${../assets/t3code.png}";
    startupWMClass = "com.t3tools.T3Code";
    categories = [ "Development" ];
  };
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [
    launcher
    desktop
  ];
}

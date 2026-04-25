{ pkgs, ... }:

let
  zedX11 = pkgs.symlinkJoin {
    name = "zed-editor-x11";
    paths = [ pkgs.zed-editor ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/zeditor"
      makeWrapper "${pkgs.zed-editor}/bin/zeditor" "$out/bin/zeditor" \
        --set WAYLAND_DISPLAY ""
    '';
  };
in

{
  environment.systemPackages = [
    zedX11
  ];
}

{ pkgs, ... }:

# Helix uses the terminal's own colors (base16_transparent) so it always matches
# the Ghostty Monochrome theme.
let
  config = pkgs.writeText "helix-config.toml" ''
    theme = "base16_transparent"

    [editor]
    line-number = "relative"
    cursorline = true
    color-modes = true
    bufferline = "multiple"

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.indent-guides]
    render = true
  '';

  # `code` stand-in: apps that only know how to open VS Code (Unreal Engine's
  # source-code integration, "Open in editor" buttons...) get Helix in a new
  # Ghostty window instead. Understands `code [folder] [-g file:line:col] [files]`.
  codeShim = pkgs.writeShellScriptBin "code" ''
    dir="" files=()
    while [ $# -gt 0 ]; do
      case "$1" in
        -g|--goto) shift; [ $# -gt 0 ] && files+=("$1") ;;
        -*) ;;
        *.code-workspace) dir=$(dirname -- "$1") ;;
        *) if [ -d "$1" ] && [ -z "$dir" ]; then dir="$1"; else files+=("$1"); fi ;;
      esac
      shift
    done
    [ -n "$dir" ] || dir="''${files[0]%/*}"
    [ -d "$dir" ] || dir="$HOME"
    [ ''${#files[@]} -gt 0 ] || files=("$dir")
    cd "$dir" || exit 1
    exec ${pkgs.util-linux}/bin/setsid -f ${pkgs.ghostty}/bin/ghostty \
      --working-directory="$dir" -e ${pkgs.helix}/bin/hx "''${files[@]}" >/dev/null 2>&1
  '';
in
{
  environment.systemPackages = with pkgs; [
    helix
    codeShim
    clang-tools # clangd: C/C++ language server (Unreal, Godot C++ ...)
    nil # Nix language server
  ];

  # Helix is the default terminal editor (git, tv, sudoedit, ...).
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config/helix 0755 z4mbo users -"
    "L+ /home/z4mbo/.config/helix/config.toml - - - - ${config}"
  ];
}

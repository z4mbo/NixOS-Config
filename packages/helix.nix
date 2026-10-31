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
in
{
  environment.systemPackages = with pkgs; [
    helix
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

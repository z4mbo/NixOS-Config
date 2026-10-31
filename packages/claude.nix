{ pkgs, ... }:

# Claude: Claude Code CLI + the official Claude Desktop app (chat, Cowork,
# Claude Code), from Anthropic's apt repository. `update` bumps the desktop app.
#
# The CLI is Anthropic's native install in ~/.local/bin, which updates itself
# (and via T3 Code's update button). Fresh machine:
#   curl -fsSL https://claude.ai/install.sh | bash
let
  version = "4.4212.0";
  hash = "sha256-T89ljg/IlTkKuCWTKHKB37ziYbDsPqkAYOgti/v9eoQ=";

  claude-desktop = import ../lib/deb-app.nix {
    inherit pkgs version;
    pname = "claude-desktop";
    src = pkgs.fetchurl {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
      inherit hash;
    };
    executable = "usr/lib/claude-desktop/claude-desktop";
    desktopFile = "usr/share/applications/com.anthropic.Claude.desktop";
    icon = "usr/share/icons/hicolor/256x256/apps/claude-desktop.png";
  };
in
{
  environment.systemPackages = [ claude-desktop ];
}

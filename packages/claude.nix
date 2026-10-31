{ pkgs, ... }:

# Claude: Claude Code CLI + Claude "desktop" app. There is no official Linux
# desktop build, so like Omarchy it's claude.ai opened as a Helium app window.
let
  icon = pkgs.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/claude-ai.png";
    hash = "sha256-76HQVfcmqUniwXKBC/E5DiaIdUMR0K3oVWA26HwSdfA=";
  };

  desktop = pkgs.makeDesktopItem {
    name = "claude";
    desktopName = "Claude";
    comment = "Claude desktop (web app)";
    exec = "helium --app=https://claude.ai/new";
    icon = "${icon}";
    categories = [ "Network" "Development" ];
  };
in
{
  environment.systemPackages = [
    pkgs.claude-code
    desktop
  ];
}

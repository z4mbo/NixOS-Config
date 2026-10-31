{ pkgs, ... }:

# ChatGPT: OpenAI Codex CLI (`codex`, sign in with your ChatGPT account) +
# ChatGPT "desktop" app. OpenAI ships no Linux desktop build, so like Omarchy
# it's chatgpt.com opened as a Helium app window.
let
  icon = pkgs.fetchurl {
    url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png";
    hash = "sha256-TogafwFxgWgUOHSNJAkkChBOF2SGCEe0nolK+sAy9a0=";
  };

  desktop = pkgs.makeDesktopItem {
    name = "chatgpt";
    desktopName = "ChatGPT";
    comment = "ChatGPT desktop (web app)";
    exec = "helium --app=https://chatgpt.com";
    icon = "${icon}";
    categories = [ "Network" "Office" ];
  };
in
{
  environment.systemPackages = [
    pkgs.codex
    desktop
  ];
}

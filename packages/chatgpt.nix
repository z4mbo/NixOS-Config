{ pkgs, ... }:

# ChatGPT: the official ChatGPT Desktop app (ChatGPT, ChatGPT Work, Codex),
# from OpenAI's apt repository (`update` bumps it), + the Codex CLI.
#
# The CLI is an npm global install in ~/.npm-global that updates itself
# (`codex update`, or T3 Code's update button). Fresh machine:
#   npm install -g @openai/codex
let
  version = "26.1027.30824";
  hash = "sha256-ThOaRPfJF6ZD8t0BStMimN0wrsbTJNMjUksZD3ZnaEw=";

  chatgpt-desktop = import ../lib/deb-app.nix {
    inherit pkgs version;
    pname = "chatgpt";
    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
      inherit hash;
    };
    executable = "usr/lib/chatgpt/ChatGPT";
    desktopFile = "usr/share/applications/chatgpt.desktop";
    icon = "usr/share/pixmaps/chatgpt.png";
    # Don't let it take over as the default web browser.
    dropMimeTypes = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
  };
in
{
  environment.systemPackages = [ chatgpt-desktop ];
}

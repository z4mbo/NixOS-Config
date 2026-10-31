{ pkgs, ... }:

# opencode CLI (sst/opencode). npm global install in ~/.npm-global that
# updates itself (`opencode upgrade`, or T3 Code's update button); the
# nixpkgs "opencode" is a different, older project. Fresh machine:
#   npm install -g opencode-ai
#
# Theme "system" draws with the terminal's own colors, so it follows the
# light/dark switch. Only written if you don't have a config yet.
let
  config = pkgs.writeText "opencode.json" (builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    theme = "system";
  });
in
{
  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config/opencode 0755 z4mbo users -"
    "C /home/z4mbo/.config/opencode/opencode.json - - - - ${config}"
    "z /home/z4mbo/.config/opencode/opencode.json 0644 z4mbo users -"
  ];
}

{ pkgs, ... }:

# Obsidian. Notes vault: ~/Obsidian, a clone of github.com/z4mbo/Obsidian
# (private). Cloned automatically at login if it's missing, and registered
# as Obsidian's vault so it opens straight into it.
let
  setup = pkgs.writeShellScript "obsidian-vault-setup" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.git pkgs.gh pkgs.coreutils pkgs.jq ]}:$PATH
    vault="$HOME/Obsidian"
    if [ ! -d "$vault/.git" ]; then
      gh repo clone z4mbo/Obsidian "$vault" || exit 0
    fi
    cfg="$HOME/.config/obsidian/obsidian.json"
    if [ ! -f "$cfg" ]; then
      mkdir -p "$(dirname "$cfg")"
      jq -n --arg p "$vault" --argjson ts "$(date +%s000)" \
        '{vaults: {zambo: {path: $p, ts: $ts, open: true}}}' > "$cfg"
    fi
  '';
in
{
  environment.systemPackages = [ pkgs.obsidian ];

  systemd.user.services.obsidian-vault-setup = {
    description = "Clone the Obsidian notes vault if missing";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = setup;
    };
  };
}

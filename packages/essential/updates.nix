{ lib, pkgs, ... }:

# Updates
#   - A user timer checks every 3 hours (and after login) whether nixpkgs
#     (NixOS + every app), Noctalia, or Helium have something newer than what's
#     installed, and sends a desktop notification with the list.
#   - `update` (in any terminal) pulls everything to the latest version, rebuilds,
#     keeps the last 2 generations, then commits and pushes /etc/nixos to GitHub.
#   - `update-check` runs the check by hand.
let
  flakeDir = "/etc/nixos";
  path = lib.makeBinPath (with pkgs; [
    coreutils
    gnugrep
    gnused
    git
    jq
    curl
    nix
    libnotify
  ]);

  # Prints one line per input that has an update; empty output = up to date.
  check = pkgs.writeShellScriptBin "update-check" ''
    export PATH=${path}:$PATH
    cd ${flakeDir}
    lock=flake.lock

    remote_rev() { git ls-remote "https://github.com/$1" "$2" 2>/dev/null | cut -f1; }
    locked_rev() { jq -r ".nodes[\"$1\"].locked.rev" "$lock"; }

    nixpkgs_new=$(remote_rev NixOS/nixpkgs refs/heads/nixos-unstable)
    [ -n "$nixpkgs_new" ] && [ "$nixpkgs_new" != "$(locked_rev nixpkgs)" ] \
      && echo "NixOS + apps (nixpkgs unstable)"

    noctalia_new=$(remote_rev noctalia-dev/noctalia-shell HEAD)
    [ -n "$noctalia_new" ] && [ "$noctalia_new" != "$(locked_rev noctalia)" ] \
      && echo "Noctalia shell"

    helium_cur=$(sed -n 's/^ *version = "\(.*\)";/\1/p' packages/helium.nix | head -n1)
    helium_new=$(curl -fsSL https://api.github.com/repos/imputnet/helium-linux/releases/latest | jq -r .tag_name)
    [ -n "$helium_new" ] && [ "$helium_new" != "null" ] && [ "$helium_new" != "$helium_cur" ] \
      && echo "Helium $helium_cur -> $helium_new"
    exit 0
  '';

  notify = pkgs.writeShellScript "update-notify" ''
    export PATH=${path}:$PATH
    updates=$(${lib.getExe check})
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/update-notify"
    mkdir -p "$(dirname "$state")"
    # Only notify when the set of pending updates changes.
    if [ -n "$updates" ] && [ "$updates" != "$(cat "$state" 2>/dev/null)" ]; then
      notify-send -a "System" -i system-software-update \
        "Updates available" "$updates"$'\n\n'"Run 'update' in a terminal to install."
    fi
    printf '%s' "$updates" > "$state"
  '';

  update = pkgs.writeShellScriptBin "update" ''
    set -euo pipefail
    export PATH=${path}:$PATH
    cd ${flakeDir}

    echo ":: Updating flake inputs (nixpkgs, noctalia)"
    nix flake update

    helium_cur=$(sed -n 's/^ *version = "\(.*\)";/\1/p' packages/helium.nix | head -n1)
    release=$(curl -fsSL https://api.github.com/repos/imputnet/helium-linux/releases/latest)
    helium_new=$(jq -r .tag_name <<<"$release")
    if [ -n "$helium_new" ] && [ "$helium_new" != "null" ] && [ "$helium_new" != "$helium_cur" ]; then
      echo ":: Updating Helium $helium_cur -> $helium_new"
      digest=$(jq -r '.assets[] | select(.name | endswith("x86_64.AppImage")) | .digest' <<<"$release")
      sri=$(nix hash convert --hash-algo sha256 --to sri "''${digest#sha256:}")
      sed -i "s|^\( *version = \)\".*\";|\1\"$helium_new\";|; s|^\( *hash = \)\"sha256-.*\";|\1\"$sri\";|" packages/helium.nix
    fi

    echo ":: Rebuilding"
    git add -A
    sudo nixos-rebuild switch --flake ${flakeDir}#nixos

    echo ":: Keeping only the current and previous generation"
    sudo systemctl start prune-generations.service

    if ! git diff --cached --quiet; then
      git commit -q -m "update: $(date +%F)"
    fi
    git push -q && echo ":: Pushed to GitHub"

    rm -f "''${XDG_STATE_HOME:-$HOME/.local/state}/update-notify"
    echo ":: Done"
  '';
in
{
  environment.systemPackages = [
    check
    update
    pkgs.libnotify
    pkgs.glib # gsettings, used by Noctalia hooks
  ];

  systemd.user.services.update-notify = {
    description = "Notify about available system updates";
    after = [ "graphical-session.target" "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = notify;
    };
  };

  systemd.user.timers.update-notify = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "5min";
      OnUnitActiveSec = "3h";
    };
  };
}

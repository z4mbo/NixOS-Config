{ lib, pkgs, ... }:

let
  appImagePath = "/home/z4mbo/Applications/CurseForge.AppImage";
  jq = lib.getExe pkgs.jq;
  niri = lib.getExe pkgs.niri;
  appimageRun = lib.getExe pkgs.appimage-run;
  pgrep = lib.getExe' pkgs.procps "pgrep";
  pkill = lib.getExe' pkgs.procps "pkill";
  setsid = lib.getExe' pkgs.util-linux "setsid";
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  runtimeShell = pkgs.runtimeShell;

  curseforgeLauncher = pkgs.writeShellScriptBin "curseforge" ''
    appimage=${lib.escapeShellArg appImagePath}
    launch_appimage="$appimage"
    logfile="''${XDG_RUNTIME_DIR:-/tmp}/curseforge-launcher.log"
    stale_process_pattern='(/\.cache/appimage-run/.*/curseforge|CurseForge\.AppImage)'

    set -- "$HOME"/.cache/curseforge-updater/pending/CurseForge-*.AppImage
    if [ -e "$1" ]; then
      launch_appimage="$1"
    fi

    if [ ! -f "$launch_appimage" ]; then
      echo "CurseForge AppImage not found at $launch_appimage" >&2
      exit 1
    fi

    if [ -z "''${NIRI_SOCKET:-}" ]; then
      NIRI_SOCKET="$(${systemctl} --user show-environment 2>/dev/null | sed -n 's/^NIRI_SOCKET=//p; q')"

      if [ -n "$NIRI_SOCKET" ]; then
        export NIRI_SOCKET
      fi
    fi

    find_window_info() {
      ${niri} msg -j windows 2>/dev/null | ${jq} -r '
        map(select(
          ((.app_id // "") | ascii_downcase | contains("curseforge"))
          or ((.title // "") | ascii_downcase | contains("curseforge"))
        ))
        | first
        | if . == null then empty else [(.id | tostring), (.workspace_id | tostring)] | @tsv end
      ' 2>/dev/null
    }

    deferred_focus_window() {
      helper_window_id="$1"
      helper_workspace_ref="$2"

      if [ -z "''${NIRI_SOCKET:-}" ] || [ -z "$helper_window_id" ]; then
        return 0
      fi

      NIRI_SOCKET="$NIRI_SOCKET" WINDOW_ID="$helper_window_id" WORKSPACE_REF="$helper_workspace_ref" \
        ${setsid} -f ${runtimeShell} -lc '
          i=0
          sleep 0.3
          while [ "$i" -lt 20 ]; do
            if [ -n "$WORKSPACE_REF" ]; then
              ${niri} msg action focus-workspace "$WORKSPACE_REF" >/dev/null 2>&1 || true
            fi

            ${niri} msg action focus-window --id "$WINDOW_ID" >/dev/null 2>&1 || true
            sleep 0.1
            i=$((i + 1))
          done
        ' >/dev/null 2>&1
    }

    focus_window() {
      window_info="$(find_window_info)"

      if [ -z "$window_info" ]; then
        return 1
      fi

      IFS=$'\t' read -r window_id workspace_id <<EOF
$window_info
EOF

      if [ -n "$window_id" ]; then
        workspace_ref="$(
          ${niri} msg -j workspaces 2>/dev/null | ${jq} -r --argjson workspace_id "$workspace_id" '
            map(select(.id == $workspace_id))
            | first
            | .idx // empty
          ' 2>/dev/null
        )"

        if [ -n "$workspace_ref" ]; then
          ${niri} msg action focus-workspace "$workspace_ref" >/dev/null 2>&1 || true

          i=0
          while [ "$i" -lt 20 ]; do
            focused_workspace_ref="$(
              ${niri} msg -j workspaces 2>/dev/null | ${jq} -r '
                map(select(.is_focused))
                | first
                | .idx // empty
              ' 2>/dev/null
            )"

            if [ "$focused_workspace_ref" = "$workspace_ref" ]; then
              break
            fi

            sleep 0.1
            i=$((i + 1))
          done
        fi

        # Niri can ignore the first focus-window right after a workspace switch.
        i=0
        while [ "$i" -lt 5 ]; do
          ${niri} msg action focus-window --id "$window_id" >/dev/null 2>&1 || true
          sleep 0.1
          i=$((i + 1))
        done

        deferred_focus_window "$window_id" "$workspace_ref"

        return 0
      fi

      return 1
    }

    if [ -n "''${NIRI_SOCKET:-}" ]; then
      if focus_window; then
        exit 0
      fi

      # CurseForge sometimes leaves a live background process without a visible
      # window. If that happens, kill it before starting a fresh instance.
      if ${pgrep} -f "$stale_process_pattern" >/dev/null 2>&1; then
        ${pkill} -f "$stale_process_pattern" >/dev/null 2>&1 || true
        sleep 1
      fi
    fi

    cd "$HOME"
    {
      printf '\n[%s] launching CurseForge\n' "$(${runtimeShell} -lc 'date -Is' 2>/dev/null || echo unknown-time)"
      printf 'APPIMAGE=%s\n' "$launch_appimage"
      printf 'NIRI_SOCKET=%s\n' "''${NIRI_SOCKET:-}"
    } >>"$logfile"
    ${setsid} -f ${appimageRun} "$launch_appimage" --no-sandbox "$@" >>"$logfile" 2>&1

    if [ -n "''${NIRI_SOCKET:-}" ]; then
      i=0
      while [ "$i" -lt 150 ]; do
        if focus_window; then
          break
        fi

        sleep 0.2
        i=$((i + 1))
      done
    fi
  '';

  curseforgeDesktop = pkgs.makeDesktopItem {
    name = "curseforge";
    desktopName = "CurseForge";
    comment = "Launch the official CurseForge Linux AppImage";
    exec = "/run/current-system/sw/bin/curseforge";
    terminal = false;
    startupNotify = true;
    categories = [ "Game" ];
  };
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = [
    curseforgeLauncher
    curseforgeDesktop
  ];
}

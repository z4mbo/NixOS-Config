{ lib, pkgs, ... }:

let
  # Scratchpad (Hyprland-style) on top of a hidden named workspace "scratch":
  #   scratchpad send   -> focused window becomes floating and goes to "scratch"
  #   scratchpad toggle -> bring every scratch window, floating and centered,
  #                        above the current workspace; run again to hide them
  #   scratchpad init   -> (at startup) move "scratch" after your workspaces
  #   scratchpad goto N / moveto N -> Super(+Shift)+N, skipping "scratch"
  scratchpad = pkgs.writeShellScriptBin "scratchpad" ''
    set -u
    export PATH=${lib.makeBinPath [ pkgs.jq pkgs.coreutils pkgs.libnotify ]}:$PATH
    state="''${XDG_RUNTIME_DIR:-/tmp}/niri-scratchpad-shown"
    ws=$(niri msg -j workspaces)
    wins=$(niri msg -j windows)
    scratch=$(jq -r '.[] | select(.name == "scratch") | .id' <<<"$ws")
    scratch_out=$(jq -r '.[] | select(.name == "scratch") | .output' <<<"$ws")
    cur_out=$(jq -r '.[] | select(.is_focused) | .output' <<<"$ws")
    cur_idx=$(jq -r '.[] | select(.is_focused) | .idx' <<<"$ws")
    [ -n "$scratch" ] || exit 1

    # niri lists named workspaces first; keep "scratch" last so Super+1..9
    # still mean your own workspaces.
    last=$(jq --arg o "$scratch_out" '[.[] | select(.output == $o)] | length' <<<"$ws")
    niri msg action move-workspace-to-index --reference scratch "$last" >/dev/null 2>&1 || true
    [ "''${1:-}" = init ] && exit 0

    # Scratch windows currently shown somewhere else.
    shown=()
    if [ -f "$state" ]; then
      while read -r id; do
        w=$(jq -r --argjson id "$id" '.[] | select(.id == $id) | .workspace_id' <<<"$wins")
        [ -n "$w" ] && [ "$w" != "$scratch" ] && shown+=("$id")
      done < "$state"
    fi

    # Workspace N on the focused monitor, not counting "scratch".
    real_idx() {
      local n=$1 sidx
      sidx=$(jq -r --arg o "$cur_out" '.[] | select(.output == $o and .name == "scratch") | .idx' <<<"$ws")
      if [ -n "$sidx" ] && [ "$n" -ge "$sidx" ]; then echo $((n + 1)); else echo "$n"; fi
    }

    case "''${1:-toggle}" in
      goto) niri msg action focus-workspace "$(real_idx "$2")" ;;
      moveto) niri msg action move-column-to-workspace "$(real_idx "$2")" ;;
      send)
        id=$(jq -r '.[] | select(.is_focused) | .id' <<<"$wins")
        [ -n "$id" ] || exit 0
        niri msg action move-window-to-floating --id "$id"
        niri msg action move-window-to-workspace --window-id "$id" --focus false scratch
        [ -f "$state" ] && grep -vx "$id" "$state" > "$state.tmp"; mv -f "$state.tmp" "$state" 2>/dev/null || true
        ;;
      toggle)
        if [ ''${#shown[@]} -gt 0 ]; then
          for id in "''${shown[@]}"; do
            niri msg action move-window-to-workspace --window-id "$id" --focus false scratch
          done
          rm -f "$state"
          exit 0
        fi
        ids=$(jq -r --argjson s "$scratch" '.[] | select(.workspace_id == $s) | .id' <<<"$wins")
        if [ -z "$ids" ]; then
          notify-send -a Scratchpad "Scratchpad is empty" "Send a window there with Super+Shift+S"
          exit 0
        fi
        : > "$state"
        for id in $ids; do
          niri msg action move-window-to-floating --id "$id"
          if [ "$cur_out" != "$scratch_out" ]; then
            niri msg action move-window-to-monitor --id "$id" "$cur_out"
          else
            niri msg action move-window-to-workspace --window-id "$id" --focus false "$cur_idx"
          fi
          niri msg action center-window --id "$id"
          echo "$id" >> "$state"
          last=$id
        done
        niri msg action focus-window --id "$last"
        ;;
    esac
  '';
in
{
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = lib.mkForce [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      # niri can't bind app shortcuts through the GNOME portal; apps like Hex
      # are driven by niri keybinds instead (see hex.nix).
      "org.freedesktop.impl.portal.GlobalShortcuts" = [ "none" ];
    };
  };

  environment.systemPackages = with pkgs; [
    # niri auto-detects this on PATH and starts it on demand for X11 apps like Steam.
    xwayland-satellite
    scratchpad
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WGPU_BACKEND = "vulkan";
  };

  environment.etc."xdg/niri/config.kdl".text = ''
    // Main monitor: Samsung Odyssey G60SD, on the right.
    output "DP-1" {
        mode "2560x1440@359.999"
        position x=1920 y=0
        variable-refresh-rate
        focus-at-startup
        backdrop-color "#000000"
    }

    // Secondary monitor: HP 25x, on the left.
    output "HDMI-A-1" {
        mode "1920x1080@143.981"
        position x=0 y=0
        backdrop-color "#000000"
    }

    input {
        // Super+H/J/K/L (and any focus change) moves the pointer to the
        // center of the newly focused window.
        warp-mouse-to-focus mode="center-xy"
        keyboard {
            xkb {
                layout "it"
            }
        }

        touchpad {
            tap
            natural-scroll
        }
    }

    layout {
        gaps 12
        center-focused-column "never"

        preset-column-widths {
            proportion 0.25
            proportion 0.33333
            proportion 0.5
            proportion 0.75
            proportion 1.0
        }

        default-column-width { proportion 0.5; }

        // Hairline, barely-visible grey frame.
        border {
            on
            width 1
            active-color "#3a3a3a"
            inactive-color "#1e1e1e"
        }

        focus-ring {
            off
            width 2
            active-color "#aaaaaa"
            inactive-color "#00000000"
        }
    }

    prefer-no-csd

    // Frosted-glass blur used by the Theme menu's transparent modes.
    blur {
        passes 4
        offset 4.0
        noise 0.03
        saturation 1.3
    }

    // Hidden workspace that holds scratchpad windows (see `scratchpad`).
    workspace "scratch" {
        open-on-output "DP-1"
    }

    window-rule {
        geometry-corner-radius 14
        clip-to-geometry true
    }

    // Noctalia settings window floats.
    window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
    }

    // Blurred wallpaper behind niri's overview.
    layer-rule {
        match namespace="^noctalia-backdrop"
        place-within-backdrop true
    }

    debug {
        honor-xdg-activation-with-invalid-serial
    }

    spawn-at-startup "noctalia"
    spawn-at-startup "scratchpad" "init"

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+S { spawn "scratchpad" "toggle"; }
        Mod+Shift+S { spawn "scratchpad" "send"; }
        Mod+C { spawn-sh "noctalia msg panel-toggle control-center"; }

        // Hex voice dictation (see hex.nix)
        Mod+D { spawn "hex" "dictation" "toggle"; }
        Mod+Shift+D { spawn "hex" "paste-last"; }
        Mod+Ctrl+D { spawn "hex" "dictation" "cancel"; }
        Mod+Shift+Comma { spawn-sh "noctalia msg settings-toggle"; }
        Mod+Escape { spawn-sh "noctalia msg session lock"; }
        Mod+V { spawn-sh "noctalia msg panel-toggle clipboard"; }
        Mod+B { spawn-sh "noctalia msg bar-toggle"; }
        Mod+Shift+W { spawn-sh "noctalia msg panel-toggle wallpaper"; }
        Alt+Tab { spawn-sh "noctalia msg window-switcher hold"; }
        Print { spawn-sh "noctalia msg screenshot-region"; }
        Shift+Print { spawn-sh "noctalia msg screenshot-fullscreen"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }
        XF86AudioMute allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }
        XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }
        Mod+E { spawn "nautilus"; }
        Mod+W { toggle-window-floating; }
        Mod+Q { close-window; }

        // Focus/move across windows, workspaces and monitors as one grid:
        // H/L walk columns and spill over onto the neighbouring monitor,
        // J/K walk windows in a column and spill over to the workspace below/above.
        Mod+Left  { focus-column-or-monitor-left; }
        Mod+Down  { focus-window-or-workspace-down; }
        Mod+Up    { focus-window-or-workspace-up; }
        Mod+Right { focus-column-or-monitor-right; }
        Mod+H     { focus-column-or-monitor-left; }
        Mod+J     { focus-window-or-workspace-down; }
        Mod+K     { focus-window-or-workspace-up; }
        Mod+L     { focus-column-or-monitor-right; }

        Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
        Mod+Shift+Down  { move-window-down-or-to-workspace-down; }
        Mod+Shift+Up    { move-window-up-or-to-workspace-up; }
        Mod+Shift+Right { move-column-right-or-to-monitor-right; }
        Mod+Shift+H     { move-column-left-or-to-monitor-left; }
        Mod+Shift+J     { move-window-down-or-to-workspace-down; }
        Mod+Shift+K     { move-window-up-or-to-workspace-up; }
        Mod+Shift+L     { move-column-right-or-to-monitor-right; }

        Mod+1 { spawn "scratchpad" "goto" "1"; }
        Mod+2 { spawn "scratchpad" "goto" "2"; }
        Mod+3 { spawn "scratchpad" "goto" "3"; }
        Mod+4 { spawn "scratchpad" "goto" "4"; }
        Mod+5 { spawn "scratchpad" "goto" "5"; }
        Mod+6 { spawn "scratchpad" "goto" "6"; }
        Mod+7 { spawn "scratchpad" "goto" "7"; }
        Mod+8 { spawn "scratchpad" "goto" "8"; }
        Mod+9 { spawn "scratchpad" "goto" "9"; }

        Mod+Shift+1 { spawn "scratchpad" "moveto" "1"; }
        Mod+Shift+2 { spawn "scratchpad" "moveto" "2"; }
        Mod+Shift+3 { spawn "scratchpad" "moveto" "3"; }
        Mod+Shift+4 { spawn "scratchpad" "moveto" "4"; }
        Mod+Shift+5 { spawn "scratchpad" "moveto" "5"; }
        Mod+Shift+6 { spawn "scratchpad" "moveto" "6"; }
        Mod+Shift+7 { spawn "scratchpad" "moveto" "7"; }
        Mod+Shift+8 { spawn "scratchpad" "moveto" "8"; }
        Mod+Shift+9 { spawn "scratchpad" "moveto" "9"; }

        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Shift+E { quit; }
    }

    cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 24
    }

    // Window transparency mode (solid / transparent / inactive), written by
    // the Theme menu in the bar. niri reloads it live.
    include "/home/z4mbo/.config/niri/appearance.kdl"
  '';

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config 0755 z4mbo users -"
    "d /home/z4mbo/.config/niri 0755 z4mbo users -"
    "L+ /home/z4mbo/.config/niri/config.kdl - - - - /etc/xdg/niri/config.kdl"
    # Starts out solid (empty); the Theme menu rewrites it.
    "f /home/z4mbo/.config/niri/appearance.kdl 0644 z4mbo users - // mode: solid"
  ];
}

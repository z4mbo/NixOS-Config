{ lib, pkgs, ... }:

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
    };
  };

  environment.systemPackages = with pkgs; [
    # niri auto-detects this on PATH and starts it on demand for X11 apps like Steam.
    xwayland-satellite
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
        backdrop-color "#111111"
    }

    // Secondary monitor: HP 25x, on the left.
    output "HDMI-A-1" {
        mode "1920x1080@143.981"
        position x=0 y=0
        backdrop-color "#111111"
    }

    input {
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
        gaps 8
        center-focused-column "never"

        preset-column-widths {
            proportion 0.25
            proportion 0.33333
            proportion 0.5
            proportion 0.75
            proportion 1.0
        }

        default-column-width { proportion 0.5; }

        border {
            on
            width 2
            active-color "#aaaaaa"
            inactive-color "#282828"
        }

        focus-ring {
            off
            width 2
            active-color "#aaaaaa"
            inactive-color "#00000000"
        }
    }

    prefer-no-csd

    window-rule {
        geometry-corner-radius 8
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

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn "vicinae" "toggle"; }
        Mod+Shift+Space { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+S { spawn-sh "noctalia msg panel-toggle control-center"; }
        Mod+Shift+Comma { spawn-sh "noctalia msg settings-toggle"; }
        Mod+Escape { spawn-sh "noctalia msg session lock"; }
        Mod+V { spawn-sh "noctalia msg panel-toggle clipboard"; }
        Mod+B { spawn-sh "noctalia msg bar-toggle"; }
        Mod+Shift+W { spawn-sh "noctalia msg panel-toggle wallpaper"; }
        Alt+Tab { spawn-sh "noctalia msg window-switcher hold"; }
        Mod+Shift+S { spawn-sh "noctalia msg screenshot-region"; }
        Print { spawn-sh "noctalia msg screenshot-fullscreen"; }

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

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }
        Mod+Shift+6 { move-column-to-workspace 6; }
        Mod+Shift+7 { move-column-to-workspace 7; }
        Mod+Shift+8 { move-column-to-workspace 8; }
        Mod+Shift+9 { move-column-to-workspace 9; }

        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Shift+E { quit; }
    }

    cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
    }
  '';

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config 0755 z4mbo users -"
    "d /home/z4mbo/.config/niri 0755 z4mbo users -"
    "L+ /home/z4mbo/.config/niri/config.kdl - - - - /etc/xdg/niri/config.kdl"
  ];
}

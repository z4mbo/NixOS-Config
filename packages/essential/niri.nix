{ pkgs, ... }:

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
      default = [ "gtk" ];
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
    output "DP-1" {
        mode "2560x1440@359.999"
        variable-refresh-rate
        backdrop-color "#232136"
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
            active-color "#56526e"
            inactive-color "#2a283e"
        }

        focus-ring {
            off
            width 2
            active-color "#56526e"
            inactive-color "#00000000"
        }
    }

    prefer-no-csd

    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
    }

    debug {
        honor-xdg-activation-with-invalid-serial
    }

    spawn-at-startup "noctalia-shell" "--no-duplicate"

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+B { spawn "noctalia-shell" "ipc" "call" "bar" "toggle"; }
        Mod+E { spawn "nautilus"; }
        Mod+W { toggle-window-floating; }
        Mod+Q { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H     { move-column-left; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+L     { move-column-right; }

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
    "d /home/z4mbo/.config/noctalia 0755 z4mbo users -"
    "z /home/z4mbo/.config/noctalia/settings.json 0644 z4mbo users -"
    "L+ /home/z4mbo/.config/niri/config.kdl - - - - /etc/xdg/niri/config.kdl"
  ];
}

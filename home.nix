{ config, lib, pkgs, ... }:

{
  home.username = lib.mkDefault "z4mbo";
  home.homeDirectory = lib.mkDefault "/home/z4mbo";
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # tmux theme
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      set -g status-bg "#5277C3"
      set -g status-fg "#000000"
      set -g pane-active-border-style fg='#5277C3'
      set -g pane-border-style fg='#333333'
      set -g message-style bg='#5277C3',fg='#000000'
      set -g status-position bottom
    '';
  };


  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Alessandro Zambon";
        email = "alessandrozambon1997@gmail.com";
      };
      safe.directory = "/etc/nixos";
    };
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
    };
  };

  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    settings = {
      font.size = 18;
      window = {
        opacity = 0.95;
        rounding = 8;
      };
    };
  };

  # Zsh with Powerlevel10k
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initContent = ''
      if [ "$USER" != "root" ] && [ -z "$TMUX" ]; then
        exec tmux
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };
  };

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.file.".local/bin/noctalia-shell-fixed" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${pkgs.noctalia-qs}/bin/qs -p "${config.home.homeDirectory}/.config/quickshell/noctalia-shell" "$@"
    '';
  };

  home.activation.noctaliaShellLocalPatch = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="$HOME/.config/quickshell/noctalia-shell"
    rm -rf "$target"
    mkdir -p "$HOME/.config/quickshell"
    cp -r ${pkgs.noctalia-shell}/share/noctalia-shell "$target"
    chmod -R u+w "$target"

    sed -i \
      -e 's/property bool i18nLoaded: false/property bool i18nLoaded: I18n ? I18n.isLoaded : false/' \
      -e 's/property bool settingsLoaded: false/property bool settingsLoaded: Settings ? Settings.isLoaded : false/' \
      -e 's/property bool shellStateLoaded: false/property bool shellStateLoaded: ShellState ? ShellState.isLoaded : false/' \
      "$target/shell.qml"
  '';

  # Niri configuration
  home.file.".config/niri/config.kdl".text = ''
    output "DP-1" {
        mode "2560x1440@359.999"
        variable-refresh-rate
        backdrop-color "#000000"
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

    workspace "1"
    workspace "2"
    workspace "3"
    workspace "4"
    workspace "5"
    workspace "6"
    workspace "7"
    workspace "8"
    workspace "9"

    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
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

        preset-window-heights {
            proportion 0.25
            proportion 0.33333
            proportion 0.5
            proportion 0.75
            proportion 1.0
        }

        default-column-width { proportion 0.5; }

        border {
            on
            width 0.5
            active-color "#181818"
            inactive-color "#00000000"
        }

        focus-ring {
            on
            width 0.5
            active-color "#2F2F2F"
            inactive-color "#00000000"
        }
    }
    prefer-no-csd

    spawn-at-startup "swaybg" "-c" "#000000"
    spawn-at-startup "${config.home.homeDirectory}/.local/bin/noctalia-shell-fixed" "--no-duplicate"
    spawn-at-startup "swaync"

    binds {
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn "vicinae" "open"; }
        Mod+E { spawn "nautilus"; }
        Mod+Q { close-window; }
        Mod+W { toggle-window-floating; }
        Mod+B { spawn "${config.home.homeDirectory}/.local/bin/noctalia-shell-fixed" "ipc" "call" "bar" "toggle"; }

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

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+1 { focus-workspace "1"; }
        Mod+2 { focus-workspace "2"; }
        Mod+3 { focus-workspace "3"; }
        Mod+4 { focus-workspace "4"; }
        Mod+5 { focus-workspace "5"; }
        Mod+6 { focus-workspace "6"; }
        Mod+7 { focus-workspace "7"; }
        Mod+8 { focus-workspace "8"; }
        Mod+9 { focus-workspace "9"; }

        Mod+Shift+1 { move-column-to-workspace "1"; }
        Mod+Shift+2 { move-column-to-workspace "2"; }
        Mod+Shift+3 { move-column-to-workspace "3"; }
        Mod+Shift+4 { move-column-to-workspace "4"; }
        Mod+Shift+5 { move-column-to-workspace "5"; }
        Mod+Shift+6 { move-column-to-workspace "6"; }
        Mod+Shift+7 { move-column-to-workspace "7"; }
        Mod+Shift+8 { move-column-to-workspace "8"; }
        Mod+Shift+9 { move-column-to-workspace "9"; }

        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+Shift+E { quit; }

        Mod+Slash { show-hotkey-overlay; }
    }

    cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
    }

    screenshot-path "~/Pictures/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"
  '';

  home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 18
    background = 000000
    background-opacity = 0.6
    background-blur-radius = 32
    foreground = ffffff
    selection-background = 5277C3
    selection-foreground = 000000
    cursor-color = 5277C3
    window-padding-x = 15
    window-padding-y = 15
    mouse-scroll-multiplier = 3
    shell-integration = detect
  '';

  # Hide unwanted apps from launchers
  home.file.".local/share/applications/com.google.Chrome.desktop".text = ''
    [Desktop Entry]
    Name=Google Chrome
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/btop.desktop".text = ''
    [Desktop Entry]
    Name=btop++
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/nm-connection-editor.desktop".text = ''
    [Desktop Entry]
    Name=Advanced Network Configuration
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/nvidia-settings.desktop".text = ''
    [Desktop Entry]
    Name=NVIDIA X Server Settings
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/vim.desktop".text = ''
    [Desktop Entry]
    Name=Vim
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/gvim.desktop".text = ''
    [Desktop Entry]
    Name=GVim
    Type=Application
    NoDisplay=true
  '';
  home.file.".local/share/applications/nvim.desktop".text = ''
    [Desktop Entry]
    Name=Neovim
    GenericName=Text Editor
    Comment=Edit text files
    Exec=nvim %F
    Terminal=true
    Type=Application
    Keywords=Text;editor;
    Icon=nvim
    Categories=Utility;TextEditor;
    StartupNotify=false
    MimeType=text/english;text/plain;
  '';

  # Web Apps (Omarchy-style)
  home.file.".local/share/applications/chatgpt.desktop".text = ''
    [Desktop Entry]
    Name=ChatGPT
    Comment=OpenAI ChatGPT
    Exec=google-chrome-stable --app=https://chat.openai.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/chatgpt.png
    Type=Application
    Categories=Network;WebBrowser;
  '';
  home.file.".local/share/applications/claude.desktop".text = ''
    [Desktop Entry]
    Name=Claude
    Comment=Anthropic Claude AI
    Exec=google-chrome-stable --app=https://claude.ai
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/claude-ai.png
    Type=Application
    Categories=Network;WebBrowser;
  '';
  home.file.".local/share/applications/gemini.desktop".text = ''
    [Desktop Entry]
    Name=Gemini
    Comment=Google Gemini AI
    Exec=google-chrome-stable --app=https://gemini.google.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/google-gemini.png
    Type=Application
    Categories=Network;WebBrowser;
  '';
  home.file.".local/share/applications/grok.desktop".text = ''
    [Desktop Entry]
    Name=Grok
    Comment=xAI Grok
    Exec=google-chrome-stable --app=https://grok.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/grok.png
    Type=Application
    Categories=Network;WebBrowser;
  '';
  home.file.".local/share/applications/google-calendar.desktop".text = ''
    [Desktop Entry]
    Name=Google Calendar
    Comment=Google Calendar
    Exec=google-chrome-stable --app=https://calendar.google.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/google-calendar.png
    Type=Application
    Categories=Office;Calendar;
  '';
  home.file.".local/share/applications/youtube-music.desktop".text = ''
    [Desktop Entry]
    Name=YouTube Music
    Comment=YouTube Music
    Exec=google-chrome-stable --app=https://music.youtube.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/youtube-music.png
    Type=Application
    Categories=Audio;Music;Network;WebBrowser;
  '';
  home.file.".local/share/applications/figma.desktop".text = ''
    [Desktop Entry]
    Name=Figma
    Comment=Figma Design Tool
    Exec=google-chrome-stable --app=https://www.figma.com
    Icon=${config.home.homeDirectory}/.local/share/icons/webapps/figma.png
    Type=Application
    Categories=Graphics;Design;
  '';

  # Download webapp icons and wallpapers on activation
  home.activation.downloadWebappIcons = config.lib.dag.entryAfter ["writeBoundary"] ''
    PATH="${pkgs.coreutils}/bin:${pkgs.curl}/bin:${pkgs.findutils}/bin:$PATH"
    ICON_DIR="$HOME/.local/share/icons/webapps"
    run mkdir -p "$ICON_DIR"

    download_icon() {
      if [ ! -f "$ICON_DIR/$2" ]; then
        run curl -sL "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/$1.png" -o "$ICON_DIR/$2"
      fi
    }

    download_icon "chatgpt" "chatgpt.png"
    download_icon "claude-ai" "claude-ai.png"
    download_icon "google-gemini" "google-gemini.png"
    download_icon "grok" "grok.png"
    download_icon "google-calendar" "google-calendar.png"
    download_icon "youtube-music" "youtube-music.png"
    download_icon "figma" "figma.png"

  '';

  home.activation.installNvChad = config.lib.dag.entryAfter ["writeBoundary"] ''
    NVCHAD_DIR="$HOME/.config/nvim"
    if [ ! -d "$NVCHAD_DIR" ]; then
      run ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config"
      run ${pkgs.git}/bin/git clone --depth 1 https://github.com/NvChad/starter "$NVCHAD_DIR"
    fi
  '';

  home.file.".config/nvim/lua/chadrc.lua".text = ''
    local M = {}

    M.base46 = {
      theme = "gruvbox",
      transparency = false,
      changed_themes = {
        gruvbox = {
          base_00 = "000000",
          base_01 = "000000",
          base_02 = "0a0a0a",
          base_03 = "1a1a1a",
          base_04 = "262626",
          base_05 = "ebdbb2",
          base_0D = "5277C3",
          base_0E = "5277C3",
        },
      },
      hl_override = {
        Normal = { bg = "#000000" },
        NormalNC = { bg = "#000000" },
        NormalFloat = { bg = "#000000" },
        FloatBorder = { bg = "#000000", fg = "#1a1a1a" },
        SignColumn = { bg = "#000000" },
        FoldColumn = { bg = "#000000" },
        WinSeparator = { fg = "#1a1a1a", bg = "#000000" },
        VertSplit = { fg = "#1a1a1a", bg = "#000000" },
        NvimTreeNormal = { bg = "#000000" },
        NvimTreeNormalNC = { bg = "#000000" },
        NvimTreeWinSeparator = { fg = "#1a1a1a", bg = "#000000" },
        NvimTreeVertSplit = { fg = "#1a1a1a", bg = "#000000" },
      },
    }

    M.ui = {
      statusline = { theme = "minimal" },
    }

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        pcall(function()
          require("base46").load_all_highlights()
        end)
      end,
    })

    return M
  '';

  home.file.".config/nvim/init.lua".text = ''
    vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
    vim.g.mapleader = " "

    local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

    if not vim.uv.fs_stat(lazypath) then
      local repo = "https://github.com/folke/lazy.nvim.git"
      vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
    end

    vim.opt.rtp:prepend(lazypath)

    local lazy_config = require "configs.lazy"

    require("lazy").setup({
      {
        "NvChad/NvChad",
        lazy = false,
        branch = "v2.5",
        import = "nvchad.plugins",
      },

      { import = "plugins" },
    }, lazy_config)

    local defaults = vim.g.base46_cache .. "defaults"

    if not vim.uv.fs_stat(defaults) then
      pcall(function()
        require("base46").load_all_highlights()
      end)
    end

    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")

    require "options"
    require "autocmds"

    vim.schedule(function()
      require "mappings"
    end)
  '';

  home.file.".local/bin/powermenu.sh" = {
    text = ''
      #!/bin/sh
      entries="Logout\nReboot\nShutdown"
      selected=$(printf '%s\n' "$entries" | vicinae dmenu -p "Power Menu")
      case $selected in
        Logout) niri msg action quit;;
        Reboot) reboot;;
        Shutdown) shutdown now;;
      esac
    '';
    executable = true;
  };

  home.file.".local/bin/cheatsheet.sh" = {
    text = ''
      #!/bin/sh
      if pgrep -f "ghostty.*class=cheatsheet" > /dev/null; then
        pkill -f "ghostty.*class=cheatsheet"
      else
        ghostty --class=cheatsheet -e sh -c 'cat ~/.local/share/niri-cheatsheet.txt; read -r'
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/wallpaper-rotate.sh" = {
    text = ''
      #!/bin/sh
      pkill swaybg
      swaybg -c "#000000" &
    '';
    executable = true;
  };

  home.file.".local/bin/wallpaper-changer.sh" = {
    text = ''
      #!/bin/sh
      pkill swaybg
      swaybg -c "#000000" &
    '';
    executable = true;
  };

  home.file.".local/share/niri-cheatsheet.txt".text = ''
    ╔══════════════════════════════════════════════════════════════╗
    ║                    NIRI CHEATSHEET                           ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  WINDOWS                                                     ║
    ║    Super + Return      Open terminal                         ║
    ║    Super + Space       App launcher (vicinae)                ║
    ║    Super + E           File manager                          ║
    ║    Super + Q           Close window                          ║
    ║    Super + F           Full width (maximize column)           ║
    ║    Super + Shift + F   Fullscreen                            ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  NAVIGATION                                                  ║
    ║    Super + H/Left      Focus left                            ║
    ║    Super + J/Down      Focus down                            ║
    ║    Super + K/Up        Focus up                              ║
    ║    Super + L/Right     Focus right                           ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  MOVE WINDOWS                                                ║
    ║    Super + Shift + H/Left   Move left                        ║
    ║    Super + Shift + J/Down   Move down                        ║
    ║    Super + Shift + K/Up     Move up                          ║
    ║    Super + Shift + L/Right  Move right                       ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  RESIZE                                                      ║
    ║    Super + R           Cycle width (25→33→50→75→100%)        ║
    ║    Super + Shift + R   Cycle height (25→33→50→75→100%)       ║
    ║    Super + -/=         Shrink/grow width 10%                 ║
    ║    Super + Shift + -/= Shrink/grow height 10%                ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  COLUMNS                                                     ║
    ║    Super + ,           Consume window into column            ║
    ║    Super + .           Expel window from column              ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  WORKSPACES                                                  ║
    ║    Super + 1-9         Switch to workspace                   ║
    ║    Super + Shift + 1-9 Move window to workspace              ║
    ╠══════════════════════════════════════════════════════════════╣
    ║  SYSTEM                                                      ║
    ║    Super + \           Toggle this cheatsheet                ║
    ║    Super + /           Hotkey overlay                        ║
    ║    Super + Shift + E   Quit niri                             ║
    ╚══════════════════════════════════════════════════════════════╝
  '';


  # GTK dark theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
    iconTheme = {
      name = "Adwaita";
    };
    gtk3.extraCss = ''
      @define-color accent_color #5277C3;
      @define-color accent_bg_color #5277C3;
      @define-color window_bg_color #000000;
      @define-color view_bg_color #000000;
      @define-color headerbar_bg_color #000000;
      @define-color sidebar_bg_color #000000;
      @define-color card_bg_color #0a0a0a;
      window, .background { background-color: #000000; }
    '';
    gtk4.extraCss = ''
      @define-color accent_color #5277C3;
      @define-color accent_bg_color #5277C3;
      @define-color window_bg_color #000000;
      @define-color view_bg_color #000000;
      @define-color headerbar_bg_color #000000;
      @define-color sidebar_bg_color #000000;
      @define-color card_bg_color #0a0a0a;
      @define-color popover_bg_color #000000;
      @define-color dialog_bg_color #000000;
      window, .background, .view { background-color: #000000; }
      headerbar { background-color: #000000; }
      .sidebar, .navigation-sidebar { background-color: #000000; }
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
    };
  };

  # Opencode config
  home.file.".opencode.json".text = ''
    {
      "theme": "tokyonight"
    }
  '';

  # Spicetify theme matching system colors
  home.file.".config/spicetify/Themes/CustomDark/color.ini".text = ''
    [custom]
    text               = ffffff
    subtext            = cccccc
    sidebar-text       = ffffff
    main               = 000000
    sidebar            = 000000
    player             = 000000
    card               = 1a1a1a
    shadow             = 000000
    selected-row       = 5277C3
    button             = 5277C3
    button-active      = 5277C3
    button-disabled    = 333333
    tab-active         = 5277C3
    notification       = 5277C3
    notification-error = ff4444
    misc               = 333333
  '';

  home.file.".config/spicetify/Themes/CustomDark/user.css".text = ''
    :root {
      --spice-text: #ffffff;
      --spice-subtext: #cccccc;
      --spice-main: #000000;
      --spice-sidebar: #000000;
      --spice-player: #000000;
      --spice-card: #1a1a1a;
      --spice-button: #5277C3;
      --spice-button-active: #5277C3;
      --spice-notification: #5277C3;
    }
  '';

  # Swaync configuration
  home.file.".config/swaync/config.json".text = builtins.toJSON {
    "$schema" = "/etc/xdg/swaync/configSchema.json";
    positionX = "right";
    positionY = "top";
    layer = "overlay";
    control-center-layer = "top";
    layer-shell = true;
    cssPriority = "user";
    control-center-margin-top = 46;
    control-center-margin-bottom = 10;
    control-center-margin-right = 10;
    control-center-margin-left = 0;
    notification-2fa-action = true;
    notification-inline-replies = false;
    notification-icon-size = 48;
    notification-body-image-height = 100;
    notification-body-image-width = 200;
    timeout = 5;
    timeout-low = 3;
    timeout-critical = 0;
    fit-to-screen = false;
    control-center-width = 400;
    control-center-height = 600;
    notification-window-width = 400;
    keyboard-shortcuts = true;
    image-visibility = "when-available";
    transition-time = 200;
    hide-on-clear = false;
    hide-on-action = true;
    script-fail-notify = true;
    scripts = {};
    notification-visibility = {};
    widgets = [
      "title"
      "dnd"
      "notifications"
    ];
    widget-config = {
      title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear All";
      };
      dnd = {
        text = "Do Not Disturb";
      };
    };
  };

  home.file.".config/swaync/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 18px;
      color: #ffffff;
    }

    window,
    window.blank-window,
    window.notification-window,
    window.control-center {
      background: transparent;
    }

    box.notifications {
      background: transparent;
    }

    .notification-row {
      outline: none;
      background: transparent;
    }

    .notification-row:focus,
    .notification-row:hover {
      background: transparent;
    }

    .notification-row .notification-background {
      background: transparent;
    }

    .notification-row .notification-background .notification {
      background: #000000;
                border-radius: 8px;
      margin: 6px 12px;
      box-shadow: none;
      padding: 0;
      border: 2px solid #5277C3;
    }

    .notification-content {
      background: #000000;
      padding: 10px;
      border-radius: 8px;
    }

    .close-button {
      background: #5277C3;
      color: #000000;
      text-shadow: none;
      padding: 0;
      border-radius: 100%;
      margin-top: 10px;
      margin-right: 10px;
      box-shadow: none;
      border: none;
      min-width: 24px;
      min-height: 24px;
    }

    .close-button:hover {
      box-shadow: none;
      background: #6b8fd4;
    }

    .notification-default-action,
    .notification-action {
      padding: 4px;
      margin: 0;
      box-shadow: none;
      background: #000000;
      border: none;
      color: #ffffff;
      transition: all 200ms ease;
      border-radius: 8px;
    }

    .notification-default-action:hover,
    .notification-action:hover {
      background: #5277C3;
      color: #000000;
    }

    .notification-default-action {
      border-radius: 8px;
      background: #000000;
    }

    .notification-default-action:not(:only-child) {
      border-bottom-left-radius: 0px;
      border-bottom-right-radius: 0px;
    }

    .notification-action:first-child {
      border-bottom-left-radius: 10px;
    }

    .notification-action:last-child {
      border-bottom-right-radius: 10px;
    }

    .inline-reply {
      margin-top: 8px;
    }

    .inline-reply-entry {
      background: #000000;
      color: #ffffff;
      caret-color: #ffffff;
      border: 1px solid #5277C3;
      border-radius: 8px;
    }

    .inline-reply-button {
      margin-left: 4px;
      background: #5277C3;
      border: none;
      border-radius: 8px;
      color: #000000;
    }

    .inline-reply-button:hover {
      background: #6b8fd4;
    }

    .body-image {
      margin-top: 6px;
      background-color: #000000;
      border-radius: 8px;
    }

    .summary {
      font-size: 14px;
      font-weight: bold;
      background: transparent;
      color: #ffffff;
      text-shadow: none;
    }

    .time {
      font-size: 12px;
      font-weight: bold;
      background: transparent;
      color: #cccccc;
      text-shadow: none;
      margin-right: 18px;
    }

    .body {
      font-size: 13px;
      font-weight: normal;
      background: transparent;
      color: #cccccc;
      text-shadow: none;
    }

    .control-center {
      background: #000000;
      border: 2px solid #5277C3;
                border-radius: 8px;
    }

    .control-center-list {
      background: #000000;
    }

    .control-center-list-placeholder {
      opacity: 0.5;
      background: #000000;
    }

    .blank-window {
      background: transparent;
    }

    .floating-notifications {
      background: transparent;
    }

    .widget-title {
      color: #ffffff;
      background: #000000;
      padding: 5px 10px;
      margin: 10px 10px 5px 10px;
      font-size: 1.2em;
      font-weight: bold;
    }

    .widget-title > button {
      font-size: initial;
      color: #000000;
      text-shadow: none;
      background: #5277C3;
      box-shadow: none;
      border-radius: 8px;
      padding: 4px 10px;
    }

    .widget-title > button:hover {
      background: #6b8fd4;
    }

    .widget-dnd {
      background: #000000;
      padding: 5px 10px;
      margin: 5px 10px;
      border-radius: 8px;
      font-size: large;
      color: #ffffff;
    }

    .widget-dnd > switch {
      border-radius: 8px;
      background: #000000;
      border: 1px solid #5277C3;
    }

    .widget-dnd > switch:checked {
      background: #5277C3;
    }

    .widget-dnd > switch slider {
      background: #ffffff;
      border-radius: 8px;
    }

    .widget-inhibitors {
      margin: 5px 10px;
      padding: 5px 10px;
      background: #000000;
      color: #ffffff;
      font-size: large;
      border-radius: 8px;
    }

    .widget-inhibitors > button {
      font-size: initial;
      color: #000000;
      background: #5277C3;
      box-shadow: none;
      border-radius: 8px;
      padding: 4px 10px;
    }

    .widget-inhibitors > button:hover {
      background: #6b8fd4;
    }
  '';

  home.file.".config/helix/config.toml".text = ''
    theme = "base16_transparent"
  '';

  programs.home-manager.enable = true;
}

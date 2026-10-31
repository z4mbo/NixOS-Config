{ lib, pkgs, ... }:

# television (`tv`): fuzzy finder for files, text, git, env... Fish integration
# binds Ctrl+T (smart autocomplete) and Ctrl+R (history search).
let
  config = pkgs.writeText "television-config.toml" ''
    [ui]
    theme = "monochrome"

    [ui.input_bar]
    prompt = "λ"
  '';

  # Enter in the files channel: text/code -> Helix, anything else (images,
  # video, PDFs...) -> its default app.
  tvOpen = pkgs.writeShellScript "tv-open" ''
    text=()
    for f in "$@"; do
      case "$(${lib.getExe pkgs.file} -Lb --mime-type -- "$f")" in
        text/* | inode/x-empty | application/json | application/xml | application/toml \
          | application/javascript | application/x-*sh* | application/x-*script* | application/x-nix)
          text+=("$f") ;;
        *) ${pkgs.util-linux}/bin/setsid -f ${pkgs.xdg-utils}/bin/xdg-open "$f" >/dev/null 2>&1 ;;
      esac
    done
    [ ''${#text[@]} -gt 0 ] && exec hx "''${text[@]}"
    exit 0
  '';

  # Overrides tv's built-in files channel (same source/preview) to add the above.
  filesChannel = pkgs.writeText "television-files.toml" ''
    [metadata]
    name = "files"
    description = "Files: Enter opens text in Helix, media in its default app"
    requirements = ["fd", "bat"]

    [source]
    command = [
      { name = "Default", run = "fd -t f" },
      { name = "Hidden",  run = "fd -t f -H" },
    ]

    [preview]
    command = "bat -n --color=always '{}'"
    env = { BAT_THEME = "base16" }

    [keybindings]
    shortcut = "f1"
    enter = "actions:open"
    ctrl-up = "actions:goto_parent_dir"

    [actions.open]
    description = "Open: text in Helix, other files in their default app"
    command = "${tvOpen} {}"
    mode = "execute"

    [actions.goto_parent_dir]
    description = "Re-opens tv in the parent directory"
    command = "tv files .."
    mode = "execute"
  '';

  # ANSI color names, so tv follows the terminal light/dark theme.
  theme = pkgs.writeText "television-monochrome.toml" ''
    border_fg = 'bright-black'
    text_fg = 'white'
    dimmed_text_fg = 'bright-black'
    input_text_fg = 'bright-white'
    result_count_fg = 'bright-black'
    result_name_fg = 'white'
    result_line_number_fg = 'bright-black'
    result_value_fg = 'white'
    selection_fg = 'bright-white'
    selection_bg = 'black'
    match_fg = 'bright-white'
    preview_title_fg = 'white'
    channel_mode_fg = 'black'
    channel_mode_bg = 'white'
    remote_control_mode_fg = 'black'
    remote_control_mode_bg = 'bright-white'
    action_picker_mode_fg = 'black'
    action_picker_mode_bg = 'bright-black'
    send_to_channel_mode_fg = 'white'
  '';
in
{
  # Channels shell out to these (files -> fd, text -> rg, previews -> bat).
  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    bat
  ];

  programs.television = {
    enable = true;
    enableFishIntegration = true;
  };

  systemd.tmpfiles.rules = [
    "d /home/z4mbo/.config/television 0755 z4mbo users -"
    "d /home/z4mbo/.config/television/themes 0755 z4mbo users -"
    "d /home/z4mbo/.config/television/cable 0755 z4mbo users -"
    "L+ /home/z4mbo/.config/television/cable/files.toml - - - - ${filesChannel}"
    "L+ /home/z4mbo/.config/television/config.toml - - - - ${config}"
    "L+ /home/z4mbo/.config/television/themes/monochrome.toml - - - - ${theme}"
  ];
}

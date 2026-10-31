{ pkgs, ... }:

# television (`tv`): fuzzy finder for files, text, git, env... Fish integration
# binds Ctrl+T (smart autocomplete) and Ctrl+R (history search).
let
  config = pkgs.writeText "television-config.toml" ''
    [ui]
    theme = "monochrome"

    [ui.input_bar]
    prompt = "λ"
  '';

  theme = pkgs.writeText "television-monochrome.toml" ''
    border_fg = '#333333'
    text_fg = '#e0e0e0'
    dimmed_text_fg = '#888888'
    input_text_fg = '#ffffff'
    result_count_fg = '#888888'
    result_name_fg = '#e0e0e0'
    result_line_number_fg = '#888888'
    result_value_fg = '#aaaaaa'
    selection_fg = '#ffffff'
    selection_bg = '#2a2a2a'
    match_fg = '#ffffff'
    preview_title_fg = '#cccccc'
    channel_mode_fg = '#111111'
    channel_mode_bg = '#aaaaaa'
    remote_control_mode_fg = '#111111'
    remote_control_mode_bg = '#cccccc'
    action_picker_mode_fg = '#111111'
    action_picker_mode_bg = '#888888'
    send_to_channel_mode_fg = '#aaaaaa'
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
    "L+ /home/z4mbo/.config/television/config.toml - - - - ${config}"
    "L+ /home/z4mbo/.config/television/themes/monochrome.toml - - - - ${theme}"
  ];
}

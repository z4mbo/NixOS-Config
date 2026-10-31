{ ... }:

# Prompt: full path + git in rounded "pills", then a white NixOS logo + user,
# in the black/grey noctalia palette.
# Written to /etc/starship.toml; fish integration is automatic.
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true; # blank line between commands
      palette = "mono";
      format = "$directory$git_branch$git_status$nix_shell$cmd_duration\n[ ](bold fg:white)$username$character";

      palettes.mono = {
        pill = "#1c1c1c";
        pill_alt = "#282828";
        fg = "#e0e0e0";
        muted = "#aaaaaa";
        red = "#d07a7a";
        white = "#ffffff";
      };

      directory = {
        style = "fg:fg bg:pill bold";
        truncation_length = 0; # always the full path
        truncate_to_repo = false;
        read_only = " 󰌾";
        read_only_style = "fg:red bg:pill bold";
        format = "[](fg:pill)[󰉋 $path ]($style)[$read_only]($read_only_style)[](fg:pill) ";
      };

      git_branch = {
        symbol = "󰊢 ";
        style = "fg:muted bg:pill_alt bold";
        format = "[](fg:pill_alt)[$symbol$branch ]($style)";
      };

      git_status = {
        style = "fg:muted bg:pill_alt";
        format = "[$all_status$ahead_behind ]($style)[](fg:pill_alt) ";
      };

      nix_shell = {
        symbol = " ";
        style = "fg:muted bg:pill";
        format = "[](fg:pill)[$symbol$name ]($style)[](fg:pill) ";
      };

      cmd_duration = {
        min_time = 500;
        style = "fg:muted bg:pill";
        format = "[](fg:pill)[󰔚 $duration ]($style)[](fg:pill) ";
      };

      username = {
        show_always = true;
        style_user = "bold fg:fg";
        style_root = "bold fg:red";
        format = "[$user]($style) ";
      };

      character = {
        success_symbol = "[󰜴](bold fg:muted)";
        error_symbol = "[󰜴](bold fg:red)";
      };

      package.disabled = true;
    };
  };
}

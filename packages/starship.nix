{ ... }:

# Prompt (black/grey noctalia palette):
#
#   (󰉋  /etc/nixos)  (󰊢  main +1)                       1.2s  13:04
#   › _
#
# Path and git on one line, the command on the next.
# Written to /etc/starship.toml; fish integration is automatic.
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true; # blank line between commands
      palette = "mono";
      format = "$directory$git_branch$git_status$nix_shell\n$character";
      right_format = "$cmd_duration$time";

      palettes.mono = {
        pill = "#1a1a1a";
        pill_alt = "#242424";
        fg = "#e0e0e0";
        dim = "#8a8a8a";
        faint = "#5a5a5a";
        red = "#d07a7a";
        green = "#9fbf8f";
        yellow = "#d8c38c";
        white = "#ffffff";
      };

      directory = {
        style = "fg:fg bg:pill bold";
        truncation_length = 0; # always the full path
        truncate_to_repo = false;
        home_symbol = "~";
        read_only = " 󰌾";
        read_only_style = "fg:red bg:pill";
        format = "[](fg:pill)[󰉋  $path ]($style)[$read_only]($read_only_style)[](fg:pill) ";
      };

      git_branch = {
        symbol = "󰊢  ";
        style = "fg:dim bg:pill_alt";
        format = "[](fg:pill_alt)[$symbol$branch]($style)";
      };

      git_status = {
        style = "bg:pill_alt";
        format = "[( $all_status$ahead_behind)]($style)[ ](bg:pill_alt)[](fg:pill_alt) ";
        conflicted = "[=$count](fg:red bg:pill_alt)";
        ahead = "[⇡$count](fg:green bg:pill_alt)";
        behind = "[⇣$count](fg:yellow bg:pill_alt)";
        diverged = "[⇕](fg:yellow bg:pill_alt)";
        untracked = "[?$count](fg:dim bg:pill_alt)";
        stashed = "[≡](fg:dim bg:pill_alt)";
        modified = "[~$count](fg:yellow bg:pill_alt)";
        staged = "[+$count](fg:green bg:pill_alt)";
        renamed = "[»$count](fg:dim bg:pill_alt)";
        deleted = "[-$count](fg:red bg:pill_alt)";
      };

      nix_shell = {
        symbol = "  ";
        style = "fg:dim bg:pill";
        format = "[](fg:pill)[$symbol$name]($style)[](fg:pill) ";
      };


      character = {
        success_symbol = "[›](fg:white)";
        error_symbol = "[›](fg:red)";
        vimcmd_symbol = "[‹](fg:white)";
      };

      cmd_duration = {
        min_time = 1000;
        style = "fg:faint";
        format = "[󰥔 $duration]($style)  ";
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "fg:faint";
        format = "[$time]($style)";
      };

      package.disabled = true;
    };
  };
}

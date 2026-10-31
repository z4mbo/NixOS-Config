{ ... }:

# Prompt: rounded "pills" with a lambda, in the black/grey noctalia palette.
# Written to /etc/starship.toml; fish integration is automatic.
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      palette = "mono";
      format = "$directory$git_branch$git_status$nix_shell$cmd_duration\n$character";

      palettes.mono = {
        pill = "#1c1c1c";
        pill_alt = "#282828";
        fg = "#e0e0e0";
        muted = "#aaaaaa";
        red = "#d07a7a";
      };

      directory = {
        style = "fg:fg bg:pill bold";
        truncation_length = 3;
        truncation_symbol = "…/";
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

      character = {
        success_symbol = "[λ](bold fg:fg)";
        error_symbol = "[λ](bold fg:red)";
      };

      package.disabled = true;
    };
  };
}

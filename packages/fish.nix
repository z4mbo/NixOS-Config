{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eza # ls with icons/git status
    bat # cat with syntax highlighting
  ];

  # bat uses the terminal's own colors (matches the Monochrome theme).
  environment.variables.BAT_THEME = "base16";

  # eza: monochrome metadata columns (ANSI white / bright-black so they follow
  # the terminal light/dark theme);
  # file names keep their normal colors.
  environment.variables.EZA_COLORS = builtins.concatStringsSep ":" [
    # permission bits: r w x, setuid/sticky, extended attrs, file-type letter
    "ur=37" "uw=37" "ux=37" "ue=37"
    "gr=37" "gw=37" "gx=37"
    "tr=90" "tw=90" "tx=90"
    "su=37" "sf=37" "xa=90"
    "di=1;37" # the "d" of directories in the permission column, and dir names
    "xx=90" # punctuation like "-" and "."
    # size number / unit, user / group, date
    "sn=37" "sb=90" "df=37" "ds=90"
    "uu=37" "uR=31" "un=90" "gu=90" "gR=31" "gn=90"
    "da=90"
  ];

  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "eza --icons=auto --group-directories-first";
      ll = "eza -l --icons=auto --group-directories-first --git --time-style=relative";
      la = "eza -la --icons=auto --group-directories-first --git --time-style=relative";
      lt = "eza --tree --level=2 --icons=auto";
      l = "eza --icons=auto --group-directories-first";
      cat = "bat --paging=never --style=plain";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };

    interactiveShellInit = ''
      set -g fish_greeting
      # Tools that shell out via $SHELL (tv, editors) must get fish, never a
      # stale value inherited from an older login.
      set -gx SHELL (command -v fish)

      # Syntax colors in ANSI names so they follow the terminal's light/dark theme.
      set -g fish_color_normal normal
      set -g fish_color_command brwhite --bold
      set -g fish_color_keyword white --bold
      set -g fish_color_param normal
      set -g fish_color_option white
      set -g fish_color_quote green
      set -g fish_color_redirection blue
      set -g fish_color_end white
      set -g fish_color_error red
      set -g fish_color_comment brblack
      set -g fish_color_operator cyan
      set -g fish_color_escape cyan
      set -g fish_color_autosuggestion brblack
      set -g fish_pager_color_prefix brwhite --bold
      set -g fish_pager_color_progress brblack
    '';
  };
}

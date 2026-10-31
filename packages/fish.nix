{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    eza # ls with icons/git status
    bat # cat with syntax highlighting
  ];

  # bat uses the terminal's own colors (matches the Monochrome theme).
  environment.variables.BAT_THEME = "base16";

  # eza: monochrome metadata columns (permissions, size, user, date in greys);
  # file names keep their normal colors.
  environment.variables.EZA_COLORS = builtins.concatStringsSep ":" [
    # permission bits: r w x, setuid/sticky, extended attrs, file-type letter
    "ur=38;5;250" "uw=38;5;250" "ux=38;5;250" "ue=38;5;250"
    "gr=38;5;246" "gw=38;5;246" "gx=38;5;246"
    "tr=38;5;243" "tw=38;5;243" "tx=38;5;243"
    "su=38;5;250" "sf=38;5;250" "xa=38;5;243"
    "di=1;38;5;252" # the "d" of directories in the permission column, and dir names
    "xx=38;5;240" # punctuation like "-" and "."
    # size number / unit, user / group, date
    "sn=38;5;250" "sb=38;5;244" "df=38;5;250" "ds=38;5;244"
    "uu=38;5;246" "uR=38;5;174" "un=38;5;243" "gu=38;5;243" "gR=38;5;174" "gn=38;5;240"
    "da=38;5;244"
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

      # Black/grey syntax colors matching the noctalia Monochrome scheme.
      set -g fish_color_normal e0e0e0
      set -g fish_color_command ffffff --bold
      set -g fish_color_keyword cccccc --bold
      set -g fish_color_param e0e0e0
      set -g fish_color_option aaaaaa
      set -g fish_color_quote 9fbf8f
      set -g fish_color_redirection 8fa8c8
      set -g fish_color_end aaaaaa
      set -g fish_color_error d07a7a
      set -g fish_color_comment 666666
      set -g fish_color_operator 8fc0c0
      set -g fish_color_escape 8fc0c0
      set -g fish_color_autosuggestion 666666
      set -g fish_pager_color_prefix ffffff --bold
      set -g fish_pager_color_progress 666666
    '';
  };
}

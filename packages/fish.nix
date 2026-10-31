{ ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };

    interactiveShellInit = ''
      set -g fish_greeting

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

  # Tools installed outside Nix (npm -g, pip --user, standalone binaries).
  environment.extraInit = ''
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
  '';
}

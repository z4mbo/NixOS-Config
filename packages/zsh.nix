{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    interactiveShellInit = ''
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
    '';
  };
}

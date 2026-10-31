{ ... }:

# Self-updating user-level tools (Claude Code native installer -> ~/.local/bin,
# `npm install -g` -> ~/.npm-global) must win over anything in the system
# profile, in terminals *and* in apps started from the desktop (T3 Code, the
# launcher, ...), so their own updaters keep them on the latest version.
{
  # Login shells / terminals.
  environment.extraInit = ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
  '';

  # The systemd user manager, which niri and every app it launches inherit.
  environment.etc."environment.d/50-user-bin.conf".text = ''
    NPM_CONFIG_PREFIX=''${HOME}/.npm-global
    PATH=''${HOME}/.local/bin:''${HOME}/.npm-global/bin:''${PATH}
  '';
}

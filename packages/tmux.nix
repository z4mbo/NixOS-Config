{ pkgs, ... }:

# tmux styled like the terminal/prompt (ANSI colors, so it follows the
# terminal light/dark theme), rounded "pills",
# status bar on top. Prefix is Ctrl+B (default); mouse on; windows start at 1.
#   prefix |  split right      prefix -  split down
#   prefix h/j/k/l  move between panes   prefix r  reload config
# Sessions survive reboots (tmux-resurrect + tmux-continuum, see bottom).
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    shortcut = "b"; # prefix Ctrl+B (tmux default)
    clock24 = true;
    extraConfig = ''
      set -g mouse on
      set -g focus-events on
      set -g renumber-windows on
      set -g set-clipboard on
      set -ga terminal-overrides ",xterm-ghostty:RGB,xterm-256color:RGB"
      set -g default-shell ${pkgs.fish}/bin/fish

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind r source-file /etc/tmux.conf \; display "config reloaded"

      # --- look ---
      set -g status-position top
      set -g status-interval 5
      set -g status-justify left
      set -g status-style "bg=default,fg=colour8"
      set -g status-left-length 60
      set -g status-right-length 60
      set -g status-left "#[fg=colour0]#[bg=colour0,fg=colour15]   #S #[bg=default,fg=colour0]  "
      set -g status-right "#[fg=colour8]󰉋  #{b:pane_current_path}   %H:%M "
      set -g window-status-format "#[fg=colour8] #I #W "
      set -g window-status-current-format "#[fg=colour0]#[bg=colour0,fg=colour15] #I #W #[bg=default,fg=colour0]"
      set -g window-status-separator ""
      set -g pane-border-style "fg=colour0"
      set -g pane-active-border-style "fg=colour8"
      set -g pane-border-lines single
      set -g message-style "bg=colour0,fg=colour15"
      set -g mode-style "bg=colour8,fg=colour15"
      set -g display-panes-active-colour "colour15"
      set -g display-panes-colour "colour8"
      set -g clock-mode-colour "colour15"

      # --- sessions survive reboots ---
      # resurrect saves sessions, windows, panes, layouts, working dirs, pane
      # contents and a few programs; continuum auto-saves every 10 minutes and
      # restores everything when tmux starts again. Manual: prefix Ctrl+S save,
      # prefix Ctrl+R restore. Loaded last: continuum hooks into status-right.
      set -g @resurrect-dir "$HOME/.local/share/tmux/resurrect"
      set -g @resurrect-capture-pane-contents "on"
      set -g @resurrect-processes "hx btop htop lazygit yazi 'tv' 'claude' 'codex' 'opencode' 'omp' 'ssh'"
      set -g @continuum-save-interval "10"
      set -g @continuum-restore "on"
      run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
      run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
    '';
  };
}

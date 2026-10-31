{ pkgs, ... }:

# tmux styled like the terminal/prompt: Monochrome greys, rounded "pills",
# status bar on top. Prefix is Ctrl+Space; mouse on; windows start at 1.
#   prefix |  split right      prefix -  split down
#   prefix h/j/k/l  move between panes   prefix r  reload config
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    shortcut = "Space";
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
      set -g status-style "bg=default,fg=#8a8a8a"
      set -g status-left-length 60
      set -g status-right-length 60
      set -g status-left "#[fg=#1a1a1a]#[bg=#1a1a1a,fg=#ffffff]   #S #[bg=default,fg=#1a1a1a]  "
      set -g status-right "#[fg=#5a5a5a]󰉋  #{b:pane_current_path}   %H:%M "
      set -g window-status-format "#[fg=#5a5a5a] #I #W "
      set -g window-status-current-format "#[fg=#242424]#[bg=#242424,fg=#e0e0e0] #I #W #[bg=default,fg=#242424]"
      set -g window-status-separator ""
      set -g pane-border-style "fg=#1e1e1e"
      set -g pane-active-border-style "fg=#3a3a3a"
      set -g pane-border-lines single
      set -g message-style "bg=#1a1a1a,fg=#e0e0e0"
      set -g mode-style "bg=#3c3c3c,fg=#ffffff"
      set -g display-panes-active-colour "#e0e0e0"
      set -g display-panes-colour "#5a5a5a"
      set -g clock-mode-colour "#e0e0e0"
    '';
  };
}

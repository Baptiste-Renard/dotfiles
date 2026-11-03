#!/bin/sh

if ! command -v tmux; then
    echo "tmux not found" >&2
    exit 1
fi

name="dummy"
dir="$HOME/projects/dummy"

# Attch if exist, create otherwise (one-liner)
#tmux new-session -A -s "$name"

if ! tmux has-session -t "=$name" >/dev/null 2>&1; then
    # Create a detached session in the editor
    tmux new-session -d -s "$name" -c "$dir" -n editor 'vim .'
    # Use -e VAR="value" to set environment variables

    tmux set-option -t "=$name" status-left "[$name] "
    # -t "=$name" is an exact match otherwise it is prefix and fnmatch
    tmux new-window -t "=$name:" -n logs 'journalctl -f'
    tmux split-window -t "=$name:logs" -h 'watch -n1 df -h'
    tmux new-window -t "=$name:" -n launch
    tmux send-keys -t "=$name:launch" 'docker-compose up -d' Enter # Enter is optional
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t "=$name"
else
    tmux attach-session -t "=$name"
fi

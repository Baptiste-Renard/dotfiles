#!/bin/sh

name="dummy"
dir="$HOME/projects/dummy"

cd -- "$dir" || { echo "no such directory: $dir" >&2; exit 1; }

if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found" >&2
    exit 1
fi

if [ -d "$dir" ]; then
    echo "$dir is not a directory" >&2
    exit 1
fi

# Attch if exist, create otherwise (one-liner)
#tmux new-session -A -s "$name"

if ! tmux has-session -t "=$name" >/dev/null 2>&1; then
    # Create a detached session in the editor
    tmux new-session -d -s "$name" -n editor 'vim .'
    # Use -e VAR="value" to set environment variables

    tmux set-option -t "=$name" status-left "[$name] "
    # -t "=$name" is an exact match otherwise it is prefix and fnmatch
    tmux new-window -t "=$name:" -n logs 'journalctl -f'
    tmux split-window -t "=$name:logs" -h 'watch -n1 df -h'

    # Start a window but don't select it with -d
    tmux new-window -d -t "=$name:" -n launch
    tmux send-keys -t "=$name:launch" 'docker-compose up -d' Enter # Enter is optional
    tmux select-window -t "=$name:editor"
    #tmux select-pane -t "=$name:logs.0"
    # you can use -c to change the directory. It's simpler to cd inside the script itself
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t "=$name"
else
    tmux attach-session -t "=$name"
fi

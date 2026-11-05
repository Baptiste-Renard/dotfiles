#!/bin/sh

if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux not found" >&2
    exit 1
fi

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found" >&2
    exit 1
fi

dir=${PROJECTS_DIR:-$HOME/projects}
cd -- "$dir" || exit 1

project=$(find . ! -name . -prune -type d -perm -u+x | sed 's|^\./||' | sort |
    fzf --prompt='project> ' --preview 'ls {}') || exit 1

cd -- "$project" || exit 1

if ! tmux has-session -t "=$project" >/dev/null 2>&1; then
    tmux new-session -d -s "$project" -n shell

    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        tmux send-keys -t "=$project:shell" 'git status' Enter
    fi

    if [ -n "$EDITOR" ]; then
        tmux new-window -d -t "=$project:" -n editor "$EDITOR ."
    fi

    if [ -n "$AGENT" ]; then
        tmux new-window -d -t "=$project:" -n agent "$AGENT"
    fi

    if [ ! -d "/tmp/$project" ]; then
        mkdir "/tmp/$project" >/dev/null 2>&1
    fi
    tmux new-window -d -t "=$project:" -c "/tmp/$project" -n tmp

    if [ -n "$IDE" ]; then
        tmux new-window -d -t "=$project:" -n ide "$IDE ."
    fi
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t "=$project"
else
    tmux attach-session -t "=$project"
fi

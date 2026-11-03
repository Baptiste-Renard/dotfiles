#!/bin/sh

if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found" >&2
    exit 1
fi

dir=${SCRIPTS_DIR:-$HOME/scripts}
cd -- "$dir" || exit 1

script=$(find . -type f -perm -u+x | sed 's|^\./||' | sort |
    fzf --prompt='script> ') || exit 0

exec "./$script"

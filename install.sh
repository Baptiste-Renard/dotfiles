#!/bin/sh
# Run from the root of the dotfiles repo.
# For every file in config/, ask whether to link it, copy it, or skip it.
# Whatever is already in $HOME under that name is replaced, with no backup.
set -eu

if ! [ -d config ]; then
    echo "failed to find config directory" >&2
    exit 1
fi

for file in config/.* config/*; do
    [ -e "$file" ] || continue              # glob matched nothing
    name=${file#config/}
    case $name in .|..) continue ;; esac

    src="$PWD/$file"
    dst="$HOME/$name"

    # Show the current state so the choice is informed.
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        state="already linked"
    elif [ -f "$dst" ] && cmp -s "$src" "$dst"; then
        state="identical copy"
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
        state="exists, differs"
    else
        state="missing"
    fi

    while :; do
        printf '%s (%s): [l]ink, [c]opy, [s]kip? ' "$name" "$state"
        if ! read -r answer; then echo; exit 1; fi   # Ctrl-D aborts
        case $answer in
            l|L)
                rm -rf "$dst"
                ln -s "$src" "$dst"
                echo "  linked $dst -> $src"
                break ;;
            c|C)
                rm -rf "$dst"
                cp -R "$src" "$dst"
                echo "  copied $src -> $dst"
                break ;;
            s|S|'')
                echo "  skipped"
                break ;;
            *)
                echo "  please answer l, c or s" ;;
        esac
    done
done

# make a `$HOME/.bashrc` a symbolic link to this file.


# Set environment
export EDITOR='vi'
export PAGER='less'
export LESS='-Ri'

export PATH="$HOME/.local/bin:$PATH"


# History

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="ls:cd:cd ..:..:history:clear:exit:"
HISTCONTROL="ignoredups:ignorespace:erasedups"


# Shell options

# cd enhancers
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
# update LINES and COLUMNS after each command
shopt -s checkwinsize
# include dotfiles in *
shopt -u dotglob
# enable ** to match all files recursively
shopt -s globstar
# extand globing
shopt -u extglob
# In bash, if a pattern with * doesn't match any file,
# it will be expanded as just the pattern.
# Enable nullglob and the pattern will expand to nothing.
# (in the case of `ls *`, it lists all files, be carefull).
shopt -u nullglob
# set -o vi

# Disable bell
bind 'set bell-style none'


# Aliases

# tip: use `\cmd` or `command cmd` to dodge aliases of cmd.
alias shred='shred -z -u -n 3'
alias mv='mv -b'
alias ll='ls -lha'
alias checkwhitespace="grep -nHE '[[:blank:]]+$'"
alias gitlog='git log --all --graph --decorate=auto'

if ls --color=auto >/dev/null 2>&1; then
    alias ls='ls -p --color=auto'
else
    alias ls='ls -p'
fi

if command -v grep >/dev/null 2>&1 &&
        echo | grep --color=auto "" >/dev/null 2>&1; then
    alias grep='grep --color=auto'
fi

if command -v diff >/dev/null 2>&1 &&
     diff --color=auto /dev/null /dev/null >/dev/null 2>&1; then
    alias diff='diff --color=auto'
fi

if command -v pkg_add >/dev/null 2>&1; then
    # OpenBSD
    if command -v doas >/dev/null 2>&1; then
        alias upup='doas pkg_add -u'
    fi
elif command -v apt >/dev/null 2>&1; then
    # Debian
    if command -v doas >/dev/null 2>&1; then
        alias upup='doas apt update && doas apt upgrade'
    elif command -v sudo >/dev/null 2>&1; then
        alias upup='sudo apt update && sudo apt upgrade'
    fi
elif command -v dnf >/dev/null 2>&1; then
    # Fedora
    if command -v doas >/dev/null 2>&1; then
        alias upup='doas dnf upgrade --refresh'
    elif command -v sudo >/dev/null 2>&1; then
        alias upup='sudo dnf upgrade --refresh'
    fi
fi

if command -v vim >/dev/null 2>&1; then
    alias vi='vim'
fi

if command -v xdg-open >/dev/null 2>&1; then
    alias open='xdg-open'
fi


# PS1 and colors
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -x /usr/bin/tput ] && tput setaf 1 >/dev/null 2>&1; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \[\033[2 q\]'
else
    ps1='\u@\h:\w\$ '
fi
unset color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      source  /etc/bash_completion
    fi
fi

if [ -r $HOME/.bashrcplus ]; then
    source $HOME/.bashrcplus # I put rustup/juliaup there
fi

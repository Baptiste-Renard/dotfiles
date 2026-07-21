# _               _              
#| |__   __ _ ___| |__  _ __ ___ 
#| '_ \ / _` / __| '_ \| '__/ __|
#| |_) | (_| \__ \ | | | | | (__ 
#|_.__/ \__,_|___/_| |_|_|  \___|

# make a `~/.bashrc` link to this file/inode.


# Set environment
export EDITOR='vim'
export PAGER='less'
export LESS='-R -i'


# History

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
HISTIGNORE="ls:cd:cd ..:history:clear:exit:"
HISTCONTROL="ignoredups:ignorespace:erasedups"


# Shell options

# cd enhancers
shopt -u autocd
shopt -u cdspell
# update LINES and COLUMNS after each command
shopt -u checkwinsize
# include dotfiles in *
shopt -u dotglob
# enable ** to match all files recursively
shopt -u globstar

shopt -u extglob

# In bash, if a pattern with * doesn't match any file,
# it will be expanded as just the pattern.
# Enable nullglob and the pattern will expand to nothing.
# (in the case of ls, it lists all files, be carefull).
shopt -u nullglob

# set -o vi


# Aliases

# tip: use `\cmd` or `command cmd` to dodge aliases of cmd.
alias shred='shred -z -u -n 3'
alias mv='mv -b'
alias ls='ls -p'
alias ll='ls -lha'
alias checkwhitespace="grep -nHE '[[:blank:]]+$'"

ls --color=auto </dev/null &>/dev/null &&
    alias ls='ls -p --color=auto'

grep --color=auto < /dev/null &>/dev/null &&
    alias grep='grep --color=auto'

diff --color=auto < /dev/null &>/dev/null &&
    alias diff='diff --color=auto'

xdg-open --version < /dev/null &>/dev/null &&
    alias open='xdg-open'

apt --version </dev/null &>/dev/null &&
    alias upup='sudo apt install && sudo apt upgrade'


# PS1 and colors
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;35m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ \[\033[2 q\]'
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


# POSIX
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

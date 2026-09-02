# Prompt. starship when available, a minimal fallback otherwise.

# Default starship config; local.bash loads later and can override it
# (starship re-reads STARSHIP_CONFIG on every render, so a later change sticks).
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/gruvbox-rainbow.toml}"

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    # For machines without starship: user@host:cwd, colored if the term supports it.
    if [ -x /usr/bin/tput ] && tput setaf 1 >/dev/null 2>&1; then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
    else
        PS1='\u@\h:\w\n\$ '
    fi

    # Put user@host:cwd in the terminal title as well
    case "$TERM" in
        xterm*|rxvt*|screen*|tmux*) PS1="\[\e]0;\u@\h: \w\a\]$PS1" ;;
    esac
fi

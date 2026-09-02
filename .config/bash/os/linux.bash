# Linux-specific settings (including WSL).

# --------------------------------------------------------------- ssh-agent
# Pin the agent to a fixed socket so only one ever runs. Without this, WSL
# starts a new agent per terminal and the agent holding your keys ends up
# different from the one $SSH_AUTH_SOCK points at.
# A forwarded agent (SSH_AUTH_SOCK already valid) always wins.
if command -v ssh-agent >/dev/null 2>&1; then
    if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
        ssh-add -l >/dev/null 2>&1
        # exit 2 = cannot reach an agent (1 just means "no keys loaded")
        if [ $? -eq 2 ]; then
            rm -f "$SSH_AUTH_SOCK"
            eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
        fi
    fi
fi

# --------------------------------------------------------------------- WSL
if command -v explorer.exe >/dev/null 2>&1; then
    alias el='explorer.exe'
fi

# ------------------------------------------------------------------- alert
# Desktop notification when a long command finishes:  sleep 10; alert
if command -v notify-send >/dev/null 2>&1; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

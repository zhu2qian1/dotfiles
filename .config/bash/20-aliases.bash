# Aliases and small helper functions.

alias sb='source ~/.bashrc'
alias cl='clear'
alias ip='ip --color=auto'
alias portcheck='ss -tlpn'

# Color support for ls/grep
if command -v dircolors >/dev/null 2>&1; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias  ll='ls -Flh'
alias lla='ls -Flha'
alias  la='ls -Ah'
alias   l='ls -CF'

# eza replaces the ls aliases when present. The `i` variants ignore .gitignore.
if command -v eza >/dev/null 2>&1; then
    alias   ll='eza -l  --icons=auto -F=auto --header --time-style long-iso --git-ignore'
    alias  lli='eza -l  --icons=auto -F=auto --header --time-style long-iso'
    alias  lla='eza -la --icons=auto -F=auto --header --time-style long-iso --git-ignore'
    alias llai='eza -la --icons=auto -F=auto --header --time-style long-iso'
fi

command -v git     >/dev/null 2>&1 && alias  g='git'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'
command -v tmux    >/dev/null 2>&1 && alias  t='tmux'
command -v claude  >/dev/null 2>&1 && alias cusage='claude -p "/usage"'

# Debian packages bat as batcat
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat='batcat'

# nvim profiles
if command -v nvim >/dev/null 2>&1; then
    alias v='nvim'                       # lite: reading / quick memo (<1s startup)
    alias vide='NVIM_PROFILE=ide nvim'   # ide:  LSP and friends (slow start is fine)
fi

alias scratchpad='$EDITOR "$(date +%F)-scratchpad.md"'
alias envlocal='$EDITOR ~/.config/bash/local.bash'

# Activate a venv in the current directory, whichever name it uses.
pyenv() {
    if [ -f ./venv/bin/activate ]; then
        . ./venv/bin/activate
    elif [ -f ./.venv/bin/activate ]; then
        . ./.venv/bin/activate
    else
        echo "no venv found in $PWD" >&2
        return 1
    fi
}

weather() {
    curl "wttr.in/$1"
}

gitignore() {
    curl -L "gitignore.io/api/$1"
}

# ------------------------------------------------------------- fzf pickers
if command -v fzf >/dev/null 2>&1; then
    if command -v git >/dev/null 2>&1; then
        # Pick a branch and switch to it
        alias gfs='git branch --list | fzf | sed s/\*// | xargs git switch'

        # Pick a worktree and cd into it (shows branch name + path)
        gwt() {
            local dir
            dir=$(git worktree list --porcelain | awk '
                    /^worktree /  { p = substr($0, 10) }
                    /^branch /    { b = substr($0, 8); sub(/^refs\/heads\//, "", b) }
                    /^detached$/  { b = "(detached)" }
                    /^$/          { if (p != "") printf "%-24s\t%s\n", b, p; p = ""; b = "" }
                    END           { if (p != "") printf "%-24s\t%s\n", b, p }
                ' | fzf --delimiter='\t' --nth=1 | cut -f2)
            [ -n "$dir" ] && builtin cd -- "$dir"
        }
    fi

    # Pick a tmux session and attach, or switch if already inside tmux
    ts() {
        local session
        session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
            | fzf --prompt='tmux> ' --height=40% --reverse) || return
        [ -z "$session" ] && return
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "$session"
        else
            tmux attach-session -t "$session"
        fi
    }
fi

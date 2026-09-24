# Aliases and small helper functions, shared by bash and zsh.

# Re-read the rc file of whichever shell this is
if [ -n "${ZSH_VERSION:-}" ]; then
    alias sb='source ~/.zshrc'
else
    alias sb='source ~/.bashrc'
fi
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
alias envlocal='$EDITOR ~/.config/shell/local.sh'

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

    # Pick a tmux session and attach, or switch if already inside tmux.
    # With no server / no sessions there is nothing to pick, so start "main"
    # instead of showing an empty fzf list the user has to cancel out of.
    #
    # Enter picks an existing session; ctrl-n creates one named after the
    # query. Creating on Enter-when-nothing-matches would not work: fzf's
    # fuzzy match makes "work" (or even "wrk") select an existing "work-api",
    # so a name that is a subsequence of another could never be created.
    # Targets use "=name" for the same reason -- tmux -t also prefix-matches.
    its() {
        local sessions out name
        sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
        if [ -z "$sessions" ]; then
            tmux new-session -s main
            return
        fi
        out=$(printf '%s\n' "$sessions" | fzf --prompt='tmux> ' --height=40% --reverse \
            --header='enter: attach / ctrl-n: new session' \
            --bind 'ctrl-n:print-query') || return
        # Trim surrounding whitespace so a blank query counts as empty
        name=${out#"${out%%[![:space:]]*}"}
        name=${name%"${name##*[![:space:]]}"}
        [ -z "$name" ] && return
        # tmux accepts these in new-session -s, but -t then parses them as
        # the window / pane separators, so the session could never be targeted
        case $name in
            *[.:]*) echo "its: session name must not contain '.' or ':'" >&2; return 1 ;;
        esac
        if ! tmux has-session -t "=$name" 2>/dev/null; then
            tmux new-session -d -s "$name" || return
        fi
        if [ -n "$TMUX" ]; then
            tmux switch-client -t "=$name"
        else
            tmux attach-session -t "=$name"
        fi
    }
fi

# --------------------------------------------------------------- ssh picker
# Pick a Host entry from ~/.ssh/config with fzf, then ssh to it.
# A Host line may list several names ("Host a b c"), so split on whitespace
# and offer each one separately. Wildcards (Host *, *.example.com) are not
# connectable targets, so drop them.
if command -v ssh >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
    issh() {
        local config="${1:-$HOME/.ssh/config}" target

        if [ ! -f "$config" ]; then
            echo "issh: ssh config file '$config' is not found. Aborting." >&2
            return 1
        fi

        # Match Host at the start of a line only, so HostName lines are not picked up.
        target=$(awk '
                tolower($1) == "host" {
                    for (i = 2; i <= NF; i++)
                        if ($i !~ /[*?!]/ && !seen[$i]++) print $i
                }
            ' "$config" | fzf --prompt='ssh> ' --height=40% --reverse) || return

        [ -z "$target" ] && return
        ssh "$target"
    }
fi

alias sb='source ~/.bashrc'
alias cl='clear'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias  ll='ls -Flh'
alias lla='ls -Flha'
alias  la='ls -Ah'
alias   l='ls -CF'

if command -v eza &> /dev/null; then
    alias   ll='eza -l  --icons=auto -F=auto --header --time-style long-iso --git-ignore'
    alias  lli='eza -l  --icons=auto -F=auto --header --time-style long-iso'
    alias  lla='eza -la --icons=auto -F=auto --header --time-style long-iso --git-ignore'
    alias llai='eza -la --icons=auto -F=auto --header --time-style long-iso'
fi

if command -v git &> /dev/null; then
    alias g='git'
fi

if command -v lazygit &> /dev/null; then
    alias lg='lazygit'
fi

if command -v batcat &> /dev/null; then
    alias bat='batcat'
fi

function pyenv {
    if [ -f ./venv/bin/activate ]; then
        source ./venv/bin/activate
    elif [ -f ./.venv/bin/activate ]; then
        source ./.venv/bin/activate
    fi
}

function weather {
  curl wttr.in/$1;
}

function gitignore {
    curl -L gitignore.io/api/$1
}

# WSL explorer.exe
if command -v explorer.exe &> /dev/null; then
    alias el='explorer.exe'
fi

# yazi
if command -v yazi &> /dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        command rm -f -- "$tmp"
    }
fi

# nvim profiles
if command -v nvim &> /dev/null; then
    alias v='nvim'                       # lite: 閲覧/quick memo (<1s)
    alias vide='NVIM_PROFILE=ide nvim'   # ide:  LSP等あり (起動遅延OK)
fi

# tmux
if command -v tmux &> /dev/null; then
    alias t='tmux'
fi

# fzf
if command -v fzf &> /dev/null && command -v git &> /dev/null; then
    alias gfs='git branch --list | fzf | sed s/\*// | xargs git switch'

    # worktree を選んで cd (ブランチ名 + パス表示)
    function gwt() {
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

# tmux セッションを fzf で選択して attach / switch
ts() {
    local session
    session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --prompt='tmux> ' --height=40% --reverse) || return
    [ -z "$session" ] && return
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    fi
}

alias portcheck='ss -tlpn'

command -v claude &> /dev/null && alias cusage='claude -p "/usage"'


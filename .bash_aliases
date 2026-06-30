alias sb='source ~/.bashrc'

alias  ll='ls -Flh'
alias lla='ls -Flha'
alias  la='ls -Ah'
alias   l='ls -CF'

if command -v eza &> /dev/null; then
    alias  ll='eza -l  --git-ignore --icons --header --time-style long-iso'
    alias lla='eza -la --git-ignore --icons --header --time-style long-iso'
    alias  la='eza -a  --git-ignore --icons          --time-style long-iso'
    alias   l='eza --git-ignore'
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

alias uportcheck='netstat -tulpn | grep LISTEN'
alias portcheck='sudo netstat -tulpn | grep LISTEN'


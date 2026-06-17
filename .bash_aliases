alias sb='source ~/.bashrc'

if command -v eza >/dev/null 2>&1; then
    alias  ll='eza -l  --git-ignore --icons --header --time-style long-iso'
    alias lla='eza -la --git-ignore --icons --header --time-style long-iso'
    alias  la='eza -a  --git-ignore --icons          --time-style long-iso'
    alias   l='eza --git-ignore'
else
    alias  ll='ls -Flh'
    alias lla='ls -Flha'
    alias  la='ls -Ah'
    alias   l='ls -CF'
fi

if command -v git 1>/dev/null 2>&1; then
    alias g='git'
fi

if command -v lazygit 1>/dev/null 2>&1; then
    alias lg='lazygit'
fi

if command -v batcat 1>/dev/null 2>&1; then
    alias bat='batcat'
fi

function pyenv {
    if [ -f ./venv/bin/activate ]; then
        source ./venv/bin/activate
    elif [ -f ./.venv/bin/activate ]; then
        source ./.venv/bin/activate
    fi
}

# WSL explorer.exe
if command -v explorer.exe 1>/dev/null 2>&1; then
    alias el='explorer.exe'
fi

alias uportcheck='netstat -tulpn | grep LISTEN'
alias portcheck='sudo netstat -tulpn | grep LISTEN'


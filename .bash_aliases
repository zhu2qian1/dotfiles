alias sb='source ~/.bashrc'

# some more ls aliases
alias ll='ls -Flh'
alias lla='ls -Flha'
alias la='ls -Ah'
alias l='ls -CF'

if command -v eza 1>/dev/null 2>&1; then
    alias  ll='eza -l  --icons --header --time-style long-iso'
    alias lla='eza -la --icons --header --time-style long-iso'
    alias  la='eza -a  --icons          --time-style long-iso'
fi

function pyenv {
    if [ -f ./venv/bin/activate ]; then
        source ./venv/bin/activate
    elif [ -f ./.venv/bin/activate ]; then
        source ./.venv/bin/activate
    fi
}

alias uportcheck='netstat -tulpn | grep LISTEN'
alias portcheck='sudo netstat -tulpn | grep LISTEN'


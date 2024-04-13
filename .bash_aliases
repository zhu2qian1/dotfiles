alias sb='source ~/.bashrc'

# some more ls aliases
alias ll='ls -Flh'
alias lla='ls -Flha'
alias la='ls -Ah'
alias l='ls -CF'

function pyenv {
    if [ -f ./venv/bin/activate ]; then
        source ./venv/bin/activate
    elif [ -f ./.venv/bin/activate ]; then
        source ./.venv/bin/activate
    fi
}

alias uportcheck='netstat -tulpn | grep LISTEN'
alias portcheck='sudo netstat -tulpn | grep LISTEN'


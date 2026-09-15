# Prompt for zsh. starship when available, a minimal fallback otherwise --
# the same shape as 40-prompt.bash.

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # user@host:cwd, then the prompt character on its own line.
    # %F{...} degrades to plain text on terminals without colour.
    PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b'$'\n''%# '

    # Put user@host:cwd in the terminal title as well
    case "$TERM" in
        xterm*|rxvt*|screen*|tmux*)
            autoload -Uz add-zsh-hook
            _prompt_title() { print -Pn '\e]0;%n@%m: %~\a'; }
            add-zsh-hook precmd _prompt_title
            ;;
    esac
fi

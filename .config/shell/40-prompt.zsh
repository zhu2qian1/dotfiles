# Prompt for zsh. starship when available, a minimal fallback otherwise --
# the same shape as 40-prompt.bash.

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # user@host:cwd, then the prompt character on its own line.
    # %F{...} degrades to plain text on terminals without colour.
    # The terminal title is set by 60-terminal.zsh, with starship or without.
    PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b'$'\n''%# '
fi

# zoxide for zsh. Numbered after the prompt for the same reason as
# 50-zoxide.bash: zoxide wants to be initialised after anything else that hooks
# the prompt (starship adds its own precmd hook in 40-prompt.zsh).
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

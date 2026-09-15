# Third-party tool integration for zsh -- the counterpart of 30-tools.bash.
# The shell-neutral blocks (herdr wrapper, yazi, lesspipe, man) are in
# 30-tools.sh, which has already loaded. compinit ran in 10-shell.zsh, so
# compdef is available to everything below.

# ------------------------------------------------------------------- fzf
# Same reasoning as 30-tools.bash: try fzf's built-in integration (>= 0.48)
# first, or Ctrl-R / Ctrl-T stay unbound on machines with a packaged fzf.
if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
    elif [ -f "$HOME/.fzf.zsh" ]; then
        . "$HOME/.fzf.zsh"
    fi
fi

# --------------------------------------------------- fzf tab completion
# The same clone as in 30-tools.bash ships a zsh front end, so <Tab> is the
# same fzf picker in both shells. Nothing is bound if the clone is absent.
_fzf_tab_completion="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-tab-completion/zsh/fzf-zsh-completion.sh"
if [ -f "$_fzf_tab_completion" ]; then
    . "$_fzf_tab_completion"
    bindkey '^I' fzf_completion
fi
unset _fzf_tab_completion

# ------------------------------------------------------------------ asdf
# Both asdf generations, as in 30-tools.bash. zsh does not source a completion
# script: it autoloads a `_asdf` function found on fpath. asdf v0.16+ only
# prints that function, so write it out once, the way asdf's docs do.
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    _asdf_completions="${ASDF_DIR:-$HOME/.asdf}/completions"
elif command -v asdf >/dev/null 2>&1; then
    path_prepend "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
    export PATH
    _asdf_completions="${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
    if [ ! -f "$_asdf_completions/_asdf" ]; then
        mkdir -p "$_asdf_completions" && asdf completion zsh >| "$_asdf_completions/_asdf"
    fi 2>/dev/null
fi
if [ -n "${_asdf_completions:-}" ] && [ -f "$_asdf_completions/_asdf" ]; then
    fpath=("$_asdf_completions" $fpath)
    autoload -Uz _asdf && compdef _asdf asdf
fi
unset _asdf_completions

# ------------------------------------------------------------- tailscale
# The generated script calls compdef itself, so sourcing it is enough.
if command -v tailscale >/dev/null 2>&1; then
    . <(tailscale completion zsh) 2>/dev/null
fi

# ----------------------------------------------------------------- herdr
# Completion only; the TMUX-stripping wrapper is in 30-tools.sh.
if command -v herdr >/dev/null 2>&1; then
    . <(herdr completion zsh) 2>/dev/null
fi

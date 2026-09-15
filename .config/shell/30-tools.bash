# Third-party tool integration for bash. Every block is guarded so a machine
# that is missing the tool just skips it instead of erroring at startup.
# The shell-neutral blocks (herdr wrapper, yazi, lesspipe, man) are in
# 30-tools.sh, which has already loaded; 30-tools.zsh is the zsh counterpart.

# ------------------------------------------------------------------- fzf
# fzf >= 0.48 ships its own shell integration; `~/.fzf.bash` only exists when
# fzf was installed via its git install script. Try the modern path first, or
# Ctrl-R / Ctrl-T silently stay unbound on machines with a packaged fzf.
if command -v fzf >/dev/null 2>&1; then
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    elif [ -f "$HOME/.fzf.bash" ]; then
        . "$HOME/.fzf.bash"
    fi
fi

# --------------------------------------------------- fzf tab completion
# readline draws its candidate list as ordinary terminal output -- it never
# uses the alternate screen -- so every <Tab> that is ambiguous leaves a wall
# of candidates in the scrollback. fzf-tab-completion feeds bash's own
# programmable completion into fzf instead, so the picker cleans up after
# itself the way Ctrl-T does. Nothing is bound if the clone is absent:
#   git clone --depth 1 https://github.com/lincheney/fzf-tab-completion \
#       ~/.local/share/fzf-tab-completion
# `bind -x` needs bash >= 4.4; older bashes just keep the stock completion.
_fzf_tab_completion="${XDG_DATA_HOME:-$HOME/.local/share}/fzf-tab-completion/bash/fzf-bash-completion.sh"
if [ -f "$_fzf_tab_completion" ] &&
        ((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4))); then
    . "$_fzf_tab_completion"
    bind -x '"\t": fzf_bash_completion'
    # vi-insert is a separate keymap; bind there too so `set editing-mode vi`
    # in ~/.inputrc does not silently fall back to the stock completion.
    bind -m vi-insert -x '"\t": fzf_bash_completion'
fi
unset _fzf_tab_completion

# ------------------------------------------------------------------ asdf
# asdf v0.16+ (the Go rewrite) dropped asdf.sh and just needs its shims on
# PATH; older versions need the script sourced. Handle both.
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    [ -f "$HOME/.asdf/completions/asdf.bash" ] && . "$HOME/.asdf/completions/asdf.bash"
elif command -v asdf >/dev/null 2>&1; then
    path_prepend "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
    export PATH
    . <(asdf completion bash) 2>/dev/null
fi

# ------------------------------------------------------------- tailscale
if command -v tailscale >/dev/null 2>&1; then
    . <(tailscale completion bash) 2>/dev/null
fi

# ----------------------------------------------------------------- herdr
# Completion only; the TMUX-stripping wrapper is in 30-tools.sh.
if command -v herdr >/dev/null 2>&1; then
    . <(herdr completion bash) 2>/dev/null
fi

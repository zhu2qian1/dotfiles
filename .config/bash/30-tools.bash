# Third-party tool integration. Every block is guarded so a machine that is
# missing the tool just skips it instead of erroring at startup.

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

# ---------------------------------------------------------------- zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

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

# ------------------------------------------------------------------ yazi
# Wrapper that leaves the shell in the directory yazi exited from.
if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp cwd
        tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        command rm -f -- "$tmp"
    }
fi

# ------------------------------------------------------------- lesspipe
# Makes `less` handle archives and binaries. Debian ships lesspipe(1),
# Homebrew and others ship lesspipe.sh.
if command -v lesspipe >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"
elif command -v lesspipe.sh >/dev/null 2>&1; then
    export LESSOPEN='|lesspipe.sh %s'
fi

# ------------------------------------------------------------------- man
# man を Neovim の組み込み :Man で開く。less と違い通常のバッファとして読むので、
# CTRL-] で printf(3) のような相互参照へジャンプでき、CTRL-T で戻れる (gO で目次)。
# `+Man!` は「標準入力で受け取った整形済みテキストを man ページとして扱う」指定。
# MANWIDTH: man 側でハードラップさせず nvim にソフトラップさせる (最大 1000)。
#           config/options.lua の g:man_hardwrap = 0 と対になっている。
#
# 注意: AppImage 版の nvim だとここは動かない。man-db 2.12 は子プロセス (整形
#   パイプラインとページャ) を seccomp サンドボックスに入れるので、AppImage が
#   FUSE マウントに使う mount(2) が弾かれて "fuse: mount failed" になる。
#   nvim は Homebrew 等の通常ビルドを使うこと。
if command -v nvim >/dev/null 2>&1; then
    export MANPAGER='nvim +Man!'
    export MANWIDTH=999
fi

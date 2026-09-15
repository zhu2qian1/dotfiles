# Third-party tool integration shared by bash and zsh. Every block is guarded
# so a machine that is missing the tool just skips it instead of erroring.
# The shell-specific halves (fzf key bindings, completions) are in
# 30-tools.bash / 30-tools.zsh, which load right after this file.

# ----------------------------------------------------------------- herdr
# herdr server は常駐デーモンで、最初のクライアントの環境をそのまま抱え込み、
# 以降そこから生える全ペインへ配る。tmux のペインから起動すると TMUX /
# TMUX_PANE が漏れ、tmux が動いていないペインでも $TMUX を見て分岐するツール
# (nvim のクリップボード判定など) が誤爆する — ヤンクが無関係な tmux
# セッションのバッファへ飛ぶ。常駐サーバに拾われる前にここで剥がす
# (env は関数ではなく PATH 上のバイナリを exec するので再帰しない)。
# 逆向き (herdr のペインの中で tmux attach) は何も漏れないので問題ない。
if command -v herdr >/dev/null 2>&1; then
    herdr() { env -u TMUX -u TMUX_PANE herdr "$@"; }
fi

# ------------------------------------------------------------------ yazi
# Wrapper that leaves the shell in the directory yazi exited from.
# `read -d ''` (read up to NUL) behaves the same in bash and zsh.
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

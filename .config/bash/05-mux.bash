# Auto-start a terminal multiplexer for interactive shells.
#
# Forgetting to start one means a terminal can never be closed without losing
# whatever is running in it, so attach (or create) before anything else. This
# file is loaded early on purpose: the outer shell exec's away, and doing so
# before starship/fzf/asdf initialise saves that work.
#
# DOTFILES_MUX で起動するものを選ぶ: herdr (既定) / tmux / none。
# local.bash・host/<host>.bash に書くか、その場限りなら
# `DOTFILES_MUX=none bash` のように渡す。tmux / screen / zellij / herdr の
# 中では常に見送る。
#
# herdr を既定にしてあるのは好みの問題ではなく、順番を固定するため。
# herdr server は常駐デーモンで、最初のクライアントの環境をそのまま抱え込み、
# 以降そこから生える全ペインへ配る。tmux の中から起動すると TMUX / TMUX_PANE
# が漏れ、tmux が動いていないペインでも $TMUX を見て分岐するツール
# (nvim のクリップボード判定など) が誤爆する — ヤンクが無関係な tmux
# セッションのバッファへ飛ぶ。逆向き (herdr のペインの中で tmux attach) は
# 何も漏れないので問題ない。

_mux_start_herdr() {
    # herdr 自身が永続セッションへの attach / 作成を面倒みる。
    exec herdr
}

_mux_start_tmux() {
    local sessions target

    sessions=$(tmux list-sessions -F '#{session_attached} #{session_activity} #{session_name}' 2>/dev/null)

    # Prefer a detached "main"; otherwise the detached session used most
    # recently. Attached ones are left alone -- another machine is on them and
    # sharing a session mirrors every window switch to both ends.
    target=$(printf '%s\n' "$sessions" | awk '$1 == 0 && $3 == "main" { print $3 }')
    [ -n "$target" ] || target=$(printf '%s\n' "$sessions" \
        | awk '$1 == 0 { print $2, $3 }' | sort -rn | head -n1 | cut -d' ' -f2-)

    if [ -n "$target" ]; then
        exec tmux attach-session -t "=$target"
    elif printf '%s\n' "$sessions" | grep -q ' main$'; then
        # "main" exists but is attached elsewhere: take a fresh numbered one.
        exec tmux new-session
    else
        exec tmux new-session -s main
    fi
}

_mux_autostart() {
    local mux="${DOTFILES_MUX:-herdr}"
    [ "$mux" != none ] && [ "$mux" != 0 ] || return

    # Already multiplexed, or inside something that does its own thing.
    # herdr は自前でペイン/タブを管理するので、その中で tmux を起動すると
    # 多重化が二重になり herdr 側のペイン操作もエージェント検出も効かなくなる。
    [ -z "$TMUX" ] && [ -z "$STY" ] && [ -z "$ZELLIJ" ] && [ -z "$HERDR_ENV" ] || return
    [ -z "$INSIDE_EMACS" ] || return
    # Needs a real terminal; TERM=dumb means a caller that cannot drive tmux.
    [ -t 0 ] && [ -t 1 ] && [ "$TERM" != dumb ] || return

    # herdr が入っていないマシンでは tmux に落ちる。多重化が無いよりはまし。
    if [ "$mux" = herdr ] && ! command -v herdr >/dev/null 2>&1; then
        mux=tmux
    fi

    case "$mux" in
        herdr) _mux_start_herdr ;;
        tmux)  command -v tmux >/dev/null 2>&1 && _mux_start_tmux ;;
    esac
}

_mux_autostart
unset -f _mux_autostart _mux_start_herdr _mux_start_tmux

# 自動起動の経路では上のガードで防げるが、tmux のペインから手で `herdr` と
# 打つと同じ環境漏れが起きる。常駐サーバに拾われる前にここで剥がす
# (env は関数ではなく PATH 上のバイナリを exec するので再帰しない)。
if command -v herdr >/dev/null 2>&1; then
    herdr() { env -u TMUX -u TMUX_PANE herdr "$@"; }
fi

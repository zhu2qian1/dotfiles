# Auto-start a terminal multiplexer for interactive shells.
#
# Forgetting to start one means a terminal can never be closed without losing
# whatever is running in it, so attach (or create) before anything else. This
# file is loaded early on purpose: the loader blocks here until the multiplexer
# exits, so an attached shell never pays for starship/fzf/asdf init.
#
# 多重化は exec せず子プロセスとして起動する。exec するとシェルが多重化に化けて
# しまい、detach がそのままシェルの終了になる — ssh 越しなら接続まで切れる。
# 子プロセスなら detach した時点で 10-shell.bash 以降が読まれ、素の対話シェルに
# 戻ってくるだけで済む。
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
    # herdr 自身が永続セッションへの attach / 作成を面倒みる。ただしアタッチは
    # 排他で、後から繋いだクライアントが先客から画面を奪う (先客は detach される
    # だけで中身は無事だが、別マシンで作業中なら邪魔でしかない)。先客がいるなら
    # herdr は諦めて tmux に回る。
    if _mux_herdr_busy; then
        command -v tmux >/dev/null 2>&1 && _mux_start_tmux
        return
    fi
    herdr
}

_mux_herdr_busy() {
    # herdr はアタッチ状態を CLI で報告しない (`herdr status` も
    # `herdr session list` も server の running/stopped までしか出さず、
    # socket API のスキーマにも attach 系のフィールドは無い)。
    # クライアント接続そのものは herdr-client.sock 上の established な unix
    # 接続として数えられるので、そこを直接見る。API 用の herdr.sock は CLI が
    # 一瞬繋いで切るだけなので常に 0 で、こちらを見ても意味が無い。
    local dir sock
    dir=${HERDR_CONFIG_PATH:+$(dirname "$HERDR_CONFIG_PATH")}
    sock="${dir:-$HOME/.config/herdr}/herdr-client.sock"

    # ss が無ければ判定できない。従来どおり herdr を起動する側に倒す。
    [ -S "$sock" ] && command -v ss >/dev/null 2>&1 || return 1
    ss -xH state established "src = $sock" 2>/dev/null | grep -q .
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
        tmux attach-session -t "=$target"
    elif printf '%s\n' "$sessions" | grep -q ' main$'; then
        # "main" exists but is attached elsewhere: take a fresh numbered one.
        tmux new-session
    else
        tmux new-session -s main
    fi
}

_mux_autostart() {
    local mux="${DOTFILES_MUX:-herdr}"
    [ "$mux" != none ] && [ "$mux" != 0 ] || return

    # detach 後は同じシェルに戻ってくる。そこで ~/.bashrc を読み直したときに
    # 黙って引き戻されないよう、シェルごとに一度だけ試す (export しない)。
    [ -z "${DOTFILES_MUX_STARTED:-}" ] || return
    DOTFILES_MUX_STARTED=1

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
unset -f _mux_autostart _mux_start_herdr _mux_herdr_busy _mux_start_tmux

# 自動起動の経路では上のガードで防げるが、tmux のペインから手で `herdr` と
# 打つと同じ環境漏れが起きる。常駐サーバに拾われる前にここで剥がす
# (env は関数ではなく PATH 上のバイナリを exec するので再帰しない)。
if command -v herdr >/dev/null 2>&1; then
    herdr() { env -u TMUX -u TMUX_PANE herdr "$@"; }
fi

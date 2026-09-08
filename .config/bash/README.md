# bash config

`~/.bashrc` is only a loader; the real settings live here.
See `~/.profile` for PATH and other variables non-interactive shells need.

## Load order

| order | file | purpose |
| --- | --- | --- |
| 1 | `00-history.bash` | history sizes, timestamps, per-prompt flush |
| 2 | `05-mux.bash` | attach to (or create) a herdr/tmux session and `exec` into it |
| 3 | `10-shell.bash` | `shopt`, `set -o`, bash-completion |
| 4 | `20-aliases.bash` | aliases and small functions |
| 5 | `30-tools.bash` | fzf (Tab 補完の差し替え含む), asdf, tailscale, yazi, lesspipe |
| 6 | `40-prompt.bash` | starship, with a plain PS1 fallback |
| 7 | `50-zoxide.bash` | zoxide (starship より後に init する必要がある) |
| 8 | `os/<os>.bash` | `linux` / `darwin` / `windows` |
| 9 | `host/<hostname>.bash` | one machine only |
| 10 | `local.bash` | secrets and overrides, **not tracked** |

Later files win. Adding a numbered file is enough to enable it, and a missing
file is skipped silently -- so a machine without a given tool still starts clean.

Only `[0-9]*.bash` is globbed, so `README.md` and `local.bash.example` are ignored.

## Multiplexer autostart

`05-mux.bash` starts a multiplexer before anything else and `exec`s into it.
`DOTFILES_MUX` selects which one:

| value | behaviour |
| --- | --- |
| `herdr` (default) | `exec herdr`; falls back to tmux if herdr is not installed, or if another client is already attached |
| `tmux` | attach to a detached `main`, else the most recently used detached session |
| `none` / `0` | start a plain shell |

herdr を既定にしてあるのは順番を固定するため。herdr server は常駐デーモンで、
最初のクライアントの環境をそのまま抱え込んで全ペインへ配るので、tmux の中から
起動すると tmux の動いていないペインにまで `TMUX` / `TMUX_PANE` が漏れ、
`$TMUX` を見て分岐するツール (nvim のクリップボード判定など) が誤爆する。
逆向き (herdr のペインの中で `tmux attach`) は何も漏れないので問題ない。
手で `herdr` と打った場合に備えて、同ファイルが `TMUX` を剥がすラッパ関数も
定義している。

herdr のアタッチは排他で、後から繋いだクライアントが先客から画面を奪う。
先にアタッチしているクライアントがいる場合は herdr を起動せず tmux に回す。
判定は `herdr-client.sock` への established な unix 接続の有無で行う
(`herdr status` も `herdr session list` も server の running/stopped までしか
報告せず、socket API にもアタッチ状態を返すものが無い)。

## Tab 補完

readline は候補一覧を代替スクリーンではなく端末へそのまま書くので、曖昧な `<Tab>`
のたびにスクロールバックが候補で埋まる。`30-tools.bash` は
[fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion) を読み込んで
`<Tab>` を fzf のピッカーに差し替え、`Ctrl-T` と同じように表示が残らないようにする。
bash 本来の programmable completion (git のサブコマンドなど) はそのまま使われる。

    git clone --depth 1 https://github.com/lincheney/fzf-tab-completion \
        ~/.local/share/fzf-tab-completion

clone が無ければ何も bind せず素の補完のままなので、入れていないマシンでも壊れない。
これに合わせて `~/.inputrc` の `show-all-if-ambiguous` は無効にしてある。

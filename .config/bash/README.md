# bash config

`~/.bashrc` is only a loader; the real settings live here.
See `~/.profile` for PATH and other variables non-interactive shells need.

## Load order

| order | file | purpose |
| --- | --- | --- |
| 1 | `00-history.bash` | history sizes, timestamps, per-prompt flush |
| 2 | `10-shell.bash` | `shopt`, `set -o`, bash-completion |
| 3 | `20-aliases.bash` | aliases and small functions |
| 4 | `30-tools.bash` | fzf (Tab 補完の差し替え含む), asdf, tailscale, herdr, yazi, lesspipe |
| 5 | `40-prompt.bash` | starship, with a plain PS1 fallback |
| 6 | `50-zoxide.bash` | zoxide (starship より後に init する必要がある) |
| 7 | `os/<os>.bash` | `linux` / `darwin` / `windows` |
| 8 | `host/<hostname>.bash` | one machine only |
| 9 | `local.bash` | secrets and overrides, **not tracked** |

Later files win. Adding a numbered file is enough to enable it, and a missing
file is skipped silently -- so a machine without a given tool still starts clean.

Only `[0-9]*.bash` is globbed, so `README.md` and `local.bash.example` are ignored.

## Multiplexer

シェル起動時に多重化 (herdr / tmux) を自動で立ち上げることはしない。必要なら
手で `herdr` や `tmux` を起動する。

`30-tools.bash` は `herdr` を `TMUX` / `TMUX_PANE` を剥がすラッパ関数で包む。
herdr server は常駐デーモンで、最初のクライアントの環境をそのまま抱え込んで
全ペインへ配るので、tmux の中から起動すると tmux の動いていないペインにまで
`TMUX` が漏れ、`$TMUX` を見て分岐するツール (nvim のクリップボード判定など) が
誤爆するため。逆向き (herdr のペインの中で `tmux attach`) は何も漏れないので
問題ない。

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

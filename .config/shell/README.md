# shell config (bash / zsh)

`~/.bashrc` and `~/.zshrc` are only loaders; the real settings live here.
See `~/.profile` for PATH and other variables non-interactive shells need.
zsh does not read `~/.profile` by itself -- `~/.zprofile` (login) and `~/.zshenv`
(`ssh host 'cmd'`) hand it over, and `~/.zshrc` picks it up otherwise.

## Which shell reads what

| suffix | read by |
| --- | --- |
| `.sh` | bash and zsh -- keep it to syntax both understand |
| `.bash` | bash only |
| `.zsh` | zsh only |

For every name, the `.sh` file loads first and the shell's own file of the same
name right after it, so the shell-specific half can build on the shared one.
A setting written only in `.bash` or `.zsh` does not reach the other shell:
put anything shareable in `.sh`.

## Load order

| order | file | purpose |
| --- | --- | --- |
| 1 | `00-history.{bash,zsh}` | history sizes, timestamps, flushing after each command |
| 2 | `10-shell.{bash,zsh}` | shell options, completion system (bash-completion / compinit), zsh key bindings |
| 3 | `20-aliases.sh` | aliases and small functions |
| 4 | `30-tools.sh` | herdr wrapper, yazi, lesspipe, man, ripgrep |
|   | `30-tools.{bash,zsh}` | fzf (Tab 補完の差し替え含む), asdf, completions for tailscale / herdr |
| 5 | `40-prompt.sh` | default `STARSHIP_CONFIG` |
|   | `40-prompt.{bash,zsh}` | starship, with a plain prompt fallback |
| 6 | `50-zoxide.{bash,zsh}` | zoxide (starship より後に init する必要がある) |
| 7 | `90-plugins.zsh` | zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search |
| 8 | `os/<os>.{sh,…}` | `linux` / `darwin` / `windows` (`os/linux.sh`: ssh-agent, WSL, alert) |
| 9 | `host/<hostname>.{sh,…}` | one machine only |
| 10 | `local.{sh,…}` | secrets and overrides, **not tracked** |

Later files win. Adding a numbered file is enough to enable it, and a missing
file is skipped silently -- so a machine without a given tool still starts clean.

Only names starting with a digit are globbed, so `README.md` and
`local.sh.example` are ignored.

## zsh plugins

`90-plugins.zsh` loads each plugin from the first place it is found
(`/usr/share/zsh/plugins/<name>/` on Arch/Manjaro, `/usr/share/<name>/` on
Debian/Ubuntu, `$HOMEBREW_PREFIX/share/<name>/`) and skips any that are absent.
It is numbered last because zsh-syntax-highlighting has to load after every
other widget, and zsh-history-substring-search after it. When the latter is
present, Up/Down search for what has been typed anywhere in the line instead of
only at its start.

## Multiplexer

シェル起動時に多重化 (herdr / tmux) を自動で立ち上げることはしない。必要なら
手で `herdr` や `tmux` を起動する。

`30-tools.sh` は `herdr` を `TMUX` / `TMUX_PANE` を剥がすラッパ関数で包む。
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
同じ clone に zsh 版も入っているので、`30-tools.zsh` も zsh の `<Tab>` を同じ
ピッカーにする。

    git clone --depth 1 https://github.com/lincheney/fzf-tab-completion \
        ~/.local/share/fzf-tab-completion

clone が無ければ何も bind せず素の補完のままなので、入れていないマシンでも壊れない。
これに合わせて `~/.inputrc` の `show-all-if-ambiguous` は無効にしてある。

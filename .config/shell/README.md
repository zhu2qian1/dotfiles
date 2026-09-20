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
|   | `30-tools.{bash,zsh}` | fzf (including the Tab completion replacement), asdf, completions for tailscale / herdr |
| 5 | `40-prompt.sh` | default `STARSHIP_CONFIG` |
|   | `40-prompt.{bash,zsh}` | starship, with a plain prompt fallback |
| 6 | `50-zoxide.{bash,zsh}` | zoxide (has to init after starship) |
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

Nothing starts a multiplexer (herdr / tmux) automatically when the shell comes
up. Run `herdr` or `tmux` by hand when you want one.

`30-tools.sh` wraps `herdr` in a function that strips `TMUX` / `TMUX_PANE`.
The herdr server is a long-lived daemon: it keeps the environment of its first
client and hands that out to every pane, so starting it from inside tmux leaks
`TMUX` into panes where no tmux is running, and tools that branch on `$TMUX`
(nvim's clipboard detection, for one) misfire. The other direction
(`tmux attach` inside a herdr pane) leaks nothing and is fine.

## Tab completion

readline writes the candidate list straight to the terminal instead of the
alternate screen, so every ambiguous `<Tab>` fills the scrollback with
candidates. `30-tools.bash` loads
[fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion) to replace
`<Tab>` with an fzf picker, which leaves nothing on screen just like `Ctrl-T`.
bash's own programmable completion (git subcommands and the like) keeps working.
The same clone ships the zsh version, so `30-tools.zsh` puts zsh's `<Tab>` on
the same picker.

    git clone --depth 1 https://github.com/lincheney/fzf-tab-completion \
        ~/.local/share/fzf-tab-completion

Without the clone nothing is bound and plain completion stays, so a machine that
does not have it still works. To match, `show-all-if-ambiguous` in `~/.inputrc`
is left disabled.

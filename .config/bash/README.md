# bash config

`~/.bashrc` is only a loader; the real settings live here.
See `~/.profile` for PATH and other variables non-interactive shells need.

## Load order

| order | file | purpose |
| --- | --- | --- |
| 1 | `00-history.bash` | history sizes, timestamps, per-prompt flush |
| 2 | `10-shell.bash` | `shopt`, `set -o`, bash-completion |
| 3 | `20-aliases.bash` | aliases and small functions |
| 4 | `30-tools.bash` | fzf, zoxide, asdf, tailscale, yazi, lesspipe |
| 5 | `40-prompt.bash` | starship, with a plain PS1 fallback |
| 6 | `os/<os>.bash` | `linux` / `darwin` / `windows` |
| 7 | `host/<hostname>.bash` | one machine only |
| 8 | `local.bash` | secrets and overrides, **not tracked** |

Later files win. Adding a numbered file is enough to enable it, and a missing
file is skipped silently -- so a machine without a given tool still starts clean.

Only `[0-9]*.bash` is globbed, so `README.md` and `local.bash.example` are ignored.

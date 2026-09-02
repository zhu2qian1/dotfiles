# dotfiles

The repo mirrors `$HOME`, so top-level dotfiles are symlinked straight into it.
Both installers are idempotent; an existing real file or a foreign link is moved
aside to `<name>.bak`.

```sh
bash install.sh             # install (Linux / WSL)
bash install.sh --dry-run   # show what would happen, change nothing
bash install.sh --doctor    # report link state, shell wiring and missing tools

pwsh -File install.ps1      # Windows-only config (komorebi etc.)
```

## Layout

| path | linked to | notes |
| --- | --- | --- |
| `.profile`, `.bashrc`, `.zshrc`, `.vimrc`, ... | `~/<name>` | top level, linked wholesale |
| `.config/*` | `~/.config/<name>` | per entry, never the whole `~/.config` |
| `.claude/skills/*` | `~/.claude/skills/<name>` | per entry, coexists with other global skills |
| `.claude/*` | `~/.claude/<name>` | per entry -- `~/.claude` also holds Claude Code's own state |
| `scripts/`, `backup/`, `.vscode/` | -- | not linked; see `IGNORE` in `install.sh` |

`.config/bash/README.md` covers the shell config and its load order.
`~/.profile` holds PATH and anything non-interactive shells need; `~/.bashrc` is
only a loader.

## Claude Code statusline

`.claude/statusline.sh` renders the Claude Code status line. It reads the session
JSON on stdin and prints two lines:

```
[Opus 5 (medium)]  ~/dotfiles  dotfiles  main
5h: 12% (Resets at 2026-09-03 20:46:40), 7d: 30%
```

| field | colour |
| --- | --- |
| path (`$HOME` shortened to `~`) | cyan |
| git worktree, prefixed `⑂` when it is a linked worktree | magenta |
| branch, or `(detached)` | green |

Needs `jq` and `git`. Both are called exactly once; `date` is called only when
the payload carries a reset timestamp, which keeps a render at roughly 11 ms.
`cygpath` is invoked only for Windows-shaped paths, so Linux never forks it.

Wiring it up is manual, because `~/.claude/settings.json` also holds credentials
and machine-local state and is therefore not tracked here. After running
`install.sh`, add:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## Machine-local config

`~/.config/bash/local.bash` holds secrets and per-machine overrides and is
gitignored. Seed it from the example:

```sh
cp ~/.config/bash/local.bash.example ~/.config/bash/local.bash
```

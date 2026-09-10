# dotfiles

The repo mirrors `$HOME`, so top-level dotfiles are symlinked straight into it.
Both installers are idempotent; an existing real file or a foreign link is moved
aside to `<name>.bak`.

```sh
bash install.sh             # install (Linux / WSL)
bash install.sh --dry-run   # show what would happen, change nothing
bash install.sh --doctor    # report link state, shell wiring and missing tools

pwsh -File install.ps1              # install (Windows)
pwsh -File install.ps1 -DryRun      # show what would happen, change nothing
pwsh -File install.ps1 -Doctor      # report link state, profile and missing tools
```

## Layout

| path | linked to | notes |
| --- | --- | --- |
| `.profile`, `.bashrc`, `.zshrc`, `.vimrc`, ... | `~/<name>` | top level, linked wholesale |
| `.config/*` | `~/.config/<name>` | per entry, never the whole `~/.config` |
| `.config/herdr/*` | `~/.config/herdr/<name>` | per entry -- herdr keeps its socket, logs and `session.json` alongside |
| `.config/herdr/config.toml` | `%APPDATA%\herdr\config.toml` | Windows only (`install.ps1`); `HERDR_CONFIG_PATH` wins if set |
| `.claude/skills/*` | `~/.claude/skills/<name>` | per entry, coexists with other global skills |
| `.claude/*` | `~/.claude/<name>` | per entry -- `~/.claude` also holds Claude Code's own state |
| `scripts/`, `backup/`, `.vscode/`, `CLAUDE.md` | -- | not linked; see `IGNORE` in `install.sh` |

`.config/bash/README.md` covers the shell config and its load order.

On Windows, `install.ps1` links the entries actually used there --
`.config/{komorebi,PowerShell,nvim,starship,ghostty,yazi,whkdrc}` and the top-level
`.vimrc`, `.gvimrc`, `.wezterm.lua`, `.psmux.conf` -- and appends a one-line stub
to the CurrentUserAllHosts profile of both PowerShell 7+ and Windows PowerShell
5.1, so the profile body stays in `.config/PowerShell/profile.ps1`.
`komorebi.json` resolves its bar and application configs through
`KOMOREBI_CONFIG_HOME`, which must point at `~/.config/komorebi`; `-Doctor` checks
that. Creating symlinks needs developer mode or an elevated shell.

`~/.profile` holds PATH and anything non-interactive shells need; `~/.bashrc` is
only a loader.

## ghostty

Besides the font settings, `.config/ghostty/config.ghostty` enables the ssh
integration:

```
shell-integration-features = ssh-env,ssh-terminfo
```

ghostty sends `TERM=xterm-ghostty`, but that terminfo entry ships only with the
ghostty package itself, so hosts without ghostty installed do not have it (Ubuntu's
`ncurses-term` does not include it either). When the entry cannot be found, tmux
exits immediately with `missing or unsuitable terminal: xterm-ghostty`.
`ssh-terminfo` pushes the entry to the remote host on connect via `infocmp`/`tic`
(the remote needs `tic`), and if that fails, `ssh-env` falls back to
`TERM=xterm-256color`. Enabling both is ghostty's recommended setup.

For connections where the integration is unavailable, install the entry by hand,
once per host:

```sh
infocmp -x xterm-ghostty | ssh <host> 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo -'
```

`-o ~/.terminfo` matters: without it, linuxbrew's `tic` writes into a versioned
directory under its Cellar, which `brew upgrade ncurses` wipes and the system
ncurses never looks at.

## Claude Code statusline

`.claude/statusline.sh` renders the Claude Code status line. It reads the session
JSON on stdin and prints two lines, plus a third when the prompt cache is warm
or Claude Code is running outside a multiplexer:

```
[Opus 5 (medium)]  ~/dotfiles  dotfiles  main
7d: 30.00% (Resets at 2026-09-07), 5h: 12.00% (Resets at 2026-09-03 20:46:40), ctx: 7.00%
Cache expires at 21:12:05  ⚠ not in herdr/tmux: closing this terminal ends the session
```

| field | colour |
| --- | --- |
| path (`$HOME` shortened to `~`) | cyan |
| git worktree, prefixed `⑂` when it is a linked worktree | magenta |
| branch, or `(detached)` | green |
| prompt cache expiry | blue |
| multiplexer warning | yellow |

The shell no longer starts a multiplexer automatically, so the warning appears
whenever none of `TMUX`, `STY`, `ZELLIJ` or `HERDR_ENV` is set, as a reminder to
start one. The statusline runs as a child of `claude`, so it sees exactly the
environment `claude` was launched from.

Percentages (7d / 5h rate limits and context window usage) are rounded to two
decimals, since the payload sometimes carries values like `7.0000001`. The 7d
reset shows only the date; the 5h reset keeps the time.

The cache expiry comes from `prompt_cache.expires_at` (Claude Code v2.1.251 or
later) and shows only the time, since the TTL is 5 minutes or 1 hour. It is
shown only while `prompt_cache.warm` is true; Claude Code re-renders the status
line at `expires_at`, so it disappears once the cache goes cold without needing
`refreshInterval`.

Needs `jq` and `git`. Both are called exactly once; `date` is called once per
timestamp the payload carries (at most three times), which keeps a render at
roughly 11 ms.
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

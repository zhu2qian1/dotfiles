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
| `.config/herdr/*` | `~/.config/herdr/<name>` | per entry -- ソケット・ログ・`session.json` が同居するため |
| `.config/herdr/config.toml` | `%APPDATA%\herdr\config.toml` | Windows のみ (`install.ps1`)。`HERDR_CONFIG_PATH` があればそちら |
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

`.config/ghostty/config.ghostty` は font 指定のほかに ssh 統合を有効にしている:

```
shell-integration-features = ssh-env,ssh-terminfo
```

ghostty は `TERM=xterm-ghostty` を送るが、この terminfo entry を配っているのは
ghostty 本体のパッケージだけで、ghostty を入れていない接続先には存在しない
(Ubuntu の `ncurses-term` にも入っていない)。entry が引けないと tmux が
`missing or unsuitable terminal: xterm-ghostty` で即終了する。`ssh-terminfo` が接続時に
`infocmp`/`tic` で entry を送り込み (接続先に `tic` が要る)、それが失敗したら
`ssh-env` が `TERM` を `xterm-256color` へ落とす。両方入れるのが ghostty の
推奨構成。

統合を使えない経路のために、手で配る場合は接続先ごとに一度:

```sh
infocmp -x xterm-ghostty | ssh <host> 'mkdir -p ~/.terminfo && tic -x -o ~/.terminfo -'
```

`-o ~/.terminfo` を付けるのは、付けないと linuxbrew の `tic` が Cellar 配下の
バージョン付きディレクトリへ書き込んでしまい、`brew upgrade ncurses` で消える上に
システム側の ncurses からは引けないため。

## Claude Code statusline

`.claude/statusline.sh` renders the Claude Code status line. It reads the session
JSON on stdin and prints two lines, plus a third when Claude Code is running
outside a multiplexer:

```
[Opus 5 (medium)]  ~/dotfiles  dotfiles  main
5h: 12% (Resets at 2026-09-03 20:46:40), 7d: 30%
⚠ not in herdr/tmux: closing this terminal ends the session
```

| field | colour |
| --- | --- |
| path (`$HOME` shortened to `~`) | cyan |
| git worktree, prefixed `⑂` when it is a linked worktree | magenta |
| branch, or `(detached)` | green |
| multiplexer warning | yellow |

シェル起動時に多重化を自動で立ち上げるのはやめたので、起動し忘れに気付けるよう
`TMUX` / `STY` / `ZELLIJ` / `HERDR_ENV` のどれも無いときに警告を出す。statusline
は `claude` の子プロセスなので、`claude` を起動した環境をそのまま見て判定できる。

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

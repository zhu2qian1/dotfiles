# Repository Guidelines

## Project Structure & Module Organization

This repository mirrors `$HOME` and manages personal dotfiles through symlinks.
Top-level files configure shells, Vim, terminals, and multiplexers. Application
settings live in `.config/`, including `nvim/`, `PowerShell/`, `komorebi/`, and
`starship/`. Shared shell modules live in `.config/shell/`; consult its README
for load order. `scripts/` contains Bash and PowerShell helpers, `backup/` holds
historical configurations, and `.claude/` contains skills and a statusline script.
There are no dedicated test or asset directories.

## Build, Test, and Development Commands

There is no build pipeline or configured lint toolchain.

- `bash install.sh --dry-run`: preview Linux/WSL symlink operations.
- `bash install.sh --doctor`: check links, shell startup, and required tools.
- `pwsh -File install.ps1 -DryRun`: preview Windows installation.
- `pwsh -File install.ps1 -Doctor`: check Windows links, profiles, and tools.
- `bash install.sh` or `pwsh -File install.ps1`: install links, backing up conflicts.

Review previews before installing. Linux uses the `IGNORE` exclusion list;
Windows uses the `$Links` allowlist. Check both when changing installation behavior.
Currently, `AGENTS.md` is absent from `IGNORE`, so Linux installation would link
this guide into `$HOME`; account for that before installing.

## Coding Style & Naming Conventions

Follow `.editorconfig`: four-space indentation, LF endings, UTF-8, and a final
newline. Preserve UTF-8 BOMs in `.ps1`, `.psm1`, and `.psd1` files for Windows
PowerShell 5.1 compatibility. Explain non-obvious platform constraints in comments.
Use numbered shell modules such as `20-aliases.sh`; shared `.sh` modules must
work in Bash and zsh, while `.bash` and `.zsh` contain shell-specific code.
Keep `.profile` POSIX-compatible and silent on stdout.

## Testing Guidelines

No testing framework, coverage target, or test naming convention is configured.
For configuration or installer changes, run the relevant dry-run and doctor
commands and report any environment-dependent failures. For shell changes,
inspect the doctor's shell-startup section and exercise affected behavior in
both shells when shared code changes.

## Commit & Pull Request Guidelines

History uses short component-prefixed summaries, such as `nvim: ...` or
`PowerShell: ...`, in Japanese and English. Existing contributor guidance prefers
Japanese summaries around 50 characters without a final period. Keep changes
focused and update `README.md` alongside installer behavior changes.
For pull requests, describe the behavior, affected platforms, and validation;
include screenshots for visual changes and link relevant issues when available.

## Security & Configuration Tips

Keep secrets and machine overrides in ignored `local.{sh,bash,zsh}` or
`env_local.*` files. Use `.config/shell/local.sh.example` as a template.
Do not commit credentials, machine-local Claude settings, or runtime state.

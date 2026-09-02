#!/usr/bin/env bash
# ============================================================
# dotfiles symlink installer (Linux / WSL)
#
# The repo mirrors $HOME, so top-level dotfiles are symlinked straight into
# $HOME. Idempotent. An existing real file or a different link is moved aside
# to <name>.bak.
#
#   bash install.sh             # install
#   bash install.sh --dry-run   # show what would happen, change nothing
#   bash install.sh --doctor    # report link state and missing tools
#
# Windows-only config (komorebi*.json / applications.json / profile.ps1) is
# handled by install.ps1 or by hand; see IGNORE below.
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
DOCTOR=0
case "${1:-}" in
    -n|--dry-run) DRY_RUN=1 ;;
    -d|--doctor)  DOCTOR=1 ;;
    "")           ;;
    *) echo "usage: bash install.sh [--dry-run|--doctor]" >&2; exit 2 ;;
esac

# Top-level entries that are never symlinked into $HOME:
#   - repo bookkeeping / the installer itself / backups
#   - directories handled specially (.config and .claude are linked per entry)
#   - Windows-side config (install.ps1, or manual)
IGNORE=(
    ".git" ".gitignore" "README.md"
    "install.sh" "install.ps1"
    ".editorconfig"
    ".config" ".claude"                 # linked per entry further down
    "init.lua"                          # in-repo symlink (.config/nvim/init.lua)
    ".vscode"                           # would collide with ~/.vscode
    "backup"                            # backup directory
    "scripts"                           # helper scripts
    # ---- Windows side / manual ----
    "komorebi.json" "komorebi.bar.json" "applications.json"
    "profile.ps1" "profile_rust.ps1" "custom_profile.ps1"
)

in_ignore() {
    local x="$1" i
    for i in "${IGNORE[@]}"; do [[ "$x" == "$i" ]] && return 0; done
    return 1
}

# link <src-abs> <dest-abs>
link() {
    local src="$1" dest="$2"
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        printf '  ok      %s\n' "$dest"
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        printf '  backup  %s -> %s.bak\n' "$dest" "$dest"
        (( DRY_RUN )) || mv -f "$dest" "$dest.bak"
    fi
    printf '  link    %s -> %s\n' "$dest" "$src"
    if (( ! DRY_RUN )); then
        mkdir -p "$(dirname "$dest")"
        ln -snf "$src" "$dest"
    fi
}

# ------------------------------------------------------------------ doctor
# Read-only report: what is linked, what tools are missing, whether the
# shell startup files are wired up. Never changes anything.
doctor() {
    local rc=0

    echo "== symlinks =="
    local path name dest
    shopt -s nullglob dotglob
    for path in "$DOTFILES_DIR"/* "$DOTFILES_DIR"/.config/*; do
        name="$(basename "$path")"
        case "$path" in
            "$DOTFILES_DIR"/.config/*) dest="$HOME/.config/$name" ;;
            *) in_ignore "$name" && continue
               [[ "$name" == *.bk || "$name" == *.bk-* ]] && continue
               dest="$HOME/$name" ;;
        esac
        if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$path")" ]]; then
            printf '  ok       %s\n' "$dest"
        elif [[ -e "$dest" || -L "$dest" ]]; then
            printf '  CONFLICT %s (not our link)\n' "$dest"; rc=1
        else
            printf '  MISSING  %s\n' "$dest"; rc=1
        fi
    done
    shopt -u nullglob dotglob

    echo
    echo "== shell startup =="
    local v
    for v in DOTFILES_PROFILE_LOADED DOTFILES_BASHRC_LOADED; do
        if bash -lic "[ -n \"\${$v:-}\" ]" 2>/dev/null; then
            printf '  ok       %s is set in a login shell\n' "$v"
        else
            printf '  MISSING  %s is not set -- run install.sh\n' "$v"; rc=1
        fi
    done
    # PATH must survive a non-interactive shell, which is what .profile buys us.
    if bash -c 'command -v nvim >/dev/null 2>&1'; then
        printf '  ok       PATH reaches non-interactive shells\n'
    else
        printf '  WARN     nvim not on PATH in a non-interactive shell\n'
    fi

    echo
    echo "== tools =="
    # required: things the config assumes; optional: nice to have
    local required=(git bash)
    local optional=(nvim starship fzf zoxide eza tmux lazygit yazi bat batcat delta rg fd)
    local c
    for c in "${required[@]}"; do
        if command -v "$c" >/dev/null 2>&1; then
            printf '  ok       %-10s %s\n' "$c" "$(command -v "$c")"
        else
            printf '  MISSING  %-10s (required)\n' "$c"; rc=1
        fi
    done
    for c in "${optional[@]}"; do
        if command -v "$c" >/dev/null 2>&1; then
            printf '  ok       %-10s %s\n' "$c" "$(command -v "$c")"
        else
            printf '  -        %-10s (optional)\n' "$c"
        fi
    done

    echo
    echo "== machine-local config =="
    if [[ -f "$HOME/.config/bash/local.bash" ]]; then
        echo "  ok       ~/.config/bash/local.bash"
    else
        echo "  -        ~/.config/bash/local.bash not present"
        echo "           cp ~/.config/bash/local.bash.example ~/.config/bash/local.bash"
    fi

    echo
    (( rc == 0 )) && echo "doctor: all good." || echo "doctor: issues found (see above)."
    return $rc
}

if (( DOCTOR )); then
    doctor
    exit $?
fi

echo "dotfiles: $DOTFILES_DIR  (dry-run=$DRY_RUN)"

# 1) top-level dotfiles into $HOME
shopt -s nullglob dotglob
for path in "$DOTFILES_DIR"/*; do
    name="$(basename "$path")"
    in_ignore "$name" && continue
    [[ "$name" == *.bk || "$name" == *.bk-* ]] && continue   # stashed files
    link "$path" "$HOME/$name"
done

# 2) link .config entries individually (never replace all of ~/.config)
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    for path in "$DOTFILES_DIR"/.config/*; do
        link "$path" "$HOME/.config/$(basename "$path")"
    done
fi

# 3) link .claude/skills entries individually (coexist with other global skills)
if [[ -d "$DOTFILES_DIR/.claude/skills" ]]; then
    for path in "$DOTFILES_DIR"/.claude/skills/*; do
        link "$path" "$HOME/.claude/skills/$(basename "$path")"
    done
fi
shopt -u nullglob dotglob

echo "done."
echo
echo "next: cp ~/.config/bash/local.bash.example ~/.config/bash/local.bash"
echo "      bash install.sh --doctor"

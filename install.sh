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
    "CLAUDE.md"                         # このリポジトリ向けの指示。~/CLAUDE.md に
                                        # 置くと $HOME 配下の全プロジェクトに効く
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

# ~/.config 配下で、ディレクトリごとではなく中身をエントリ単位でリンクするもの。
# ~/.claude と同じ理由: 追跡したい設定ファイルと、追跡してはいけないマシン固有の
# 実行時 state が同じディレクトリに同居している。
#   herdr: config.toml は持ち運べるが、同じディレクトリに API ソケット
#          (herdr.sock / herdr-client.sock)、ログ、session.json が置かれる。
#          ディレクトリごとリンクするとそれらが全部リポジトリに流れ込む。
#   systemd/user: `systemctl --user enable` が *.target.wants/ に symlink を作り、
#          snap なども自分のユニットをここで有効化する。ユニットファイルだけを
#          リンクする。入れ子は親も列挙すること (systemd を掘らないと
#          systemd/user まで届かない)。
CONFIG_PER_ENTRY=(
    "herdr"
    "systemd" "systemd/user"
)

in_config_per_entry() {
    local x="$1" i
    for i in "${CONFIG_PER_ENTRY[@]}"; do [[ "$x" == "$i" ]] && return 0; done
    return 1
}

# .config 配下のリンク単位を、.config からの相対パスで 1 行ずつ出す。
# CONFIG_PER_ENTRY のディレクトリは自分自身ではなく中身を再帰的に展開する。
# インストールと doctor で同じ走査を共有するためのもの。呼び出し側で
# nullglob / dotglob を有効にしておくこと。
config_entries() {
    local dir="$DOTFILES_DIR/.config${1:+/$1}" path rel
    for path in "$dir"/*; do
        rel="${path#"$DOTFILES_DIR"/.config/}"
        if in_config_per_entry "$rel"; then
            config_entries "$rel"
        else
            printf '%s\n' "$rel"
        fi
    done
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

# --------------------------------------------------------- sudo's PATH
# sudo throws PATH away and uses secure_path, so /opt/nvim from .profile is
# invisible there and `sudo nvim` dies with "command not found". A symlink in
# /usr/local/bin -- on every secure_path there is -- is the fix.
SUDO_PATH_DIRS=(/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin)
NVIM_SUDO_LINK="/usr/local/bin/nvim"

# Would `sudo <cmd>` find something? Approximates secure_path without needing
# sudo itself (reading /etc/sudoers requires root).
sudo_can_see() {
    local cmd="$1" d
    for d in "${SUDO_PATH_DIRS[@]}"; do
        [[ -x "$d/$cmd" ]] && return 0
    done
    return 1
}

# The one step here that needs root. Guarded accordingly: never prompts for a
# password (sudo -n only), never touches an existing /usr/local/bin/nvim that
# is not ours, and prints the command to run by hand when it cannot act.
nvim_sudo_link() {
    local src
    src="$(command -v nvim 2>/dev/null)" || true
    if [[ -z "$src" ]]; then
        printf '  -       nvim not installed, skipping %s\n' "$NVIM_SUDO_LINK"
        return 0
    fi
    if [[ -L "$NVIM_SUDO_LINK" && "$(readlink -f "$NVIM_SUDO_LINK")" == "$(readlink -f "$src")" ]]; then
        printf '  ok      %s\n' "$NVIM_SUDO_LINK"
        return 0
    fi
    if [[ -e "$NVIM_SUDO_LINK" || -L "$NVIM_SUDO_LINK" ]]; then
        printf '  CONFLICT %s exists and is not our link -- left alone\n' "$NVIM_SUDO_LINK"
        return 0
    fi
    if sudo_can_see nvim; then
        printf '  ok      nvim already reachable from sudo PATH\n'
        return 0
    fi
    printf '  link    %s -> %s (needs root)\n' "$NVIM_SUDO_LINK" "$src"
    (( DRY_RUN )) && return 0
    if sudo -n ln -snf "$src" "$NVIM_SUDO_LINK" 2>/dev/null; then
        printf '  ok      %s\n' "$NVIM_SUDO_LINK"
    else
        printf '  SKIP    no cached sudo credentials; run:\n'
        printf '          sudo ln -snf %s %s\n' "$src" "$NVIM_SUDO_LINK"
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
    # CONFIG_PER_ENTRY のディレクトリは、それ自身ではなく中身が検査対象になる。
    local config_paths=() rel
    while IFS= read -r rel; do
        config_paths+=("$DOTFILES_DIR/.config/$rel")
    done < <(config_entries)
    for path in "$DOTFILES_DIR"/* ${config_paths[@]+"${config_paths[@]}"} \
                "$DOTFILES_DIR"/.claude/skills/* "$DOTFILES_DIR"/.claude/*; do
        name="$(basename "$path")"
        case "$path" in
            "$DOTFILES_DIR"/.config/*/*) dest="$HOME/.config/${path#"$DOTFILES_DIR"/.config/}" ;;
            "$DOTFILES_DIR"/.config/*) dest="$HOME/.config/$name" ;;
            "$DOTFILES_DIR"/.claude/skills/*) dest="$HOME/.claude/skills/$name" ;;
            "$DOTFILES_DIR"/.claude/*)
               [[ "$name" == skills ]] && continue      # linked per entry above
               dest="$HOME/.claude/$name" ;;
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
    # zsh never reads ~/.profile itself; .zprofile and .zshrc hand it over.
    # Check that wiring the same way as bash's. </dev/null: an interactive zsh
    # must not sit waiting on the terminal if something in the rc files prompts.
    if command -v zsh >/dev/null 2>&1; then
        for v in DOTFILES_PROFILE_LOADED DOTFILES_ZSHRC_LOADED; do
            if zsh -lic "[[ -n \${$v:-} ]]" </dev/null >/dev/null 2>&1; then
                printf '  ok       %s is set in a zsh login shell\n' "$v"
            else
                printf '  MISSING  %s is not set in zsh -- run install.sh\n' "$v"; rc=1
            fi
        done
    fi

    # ~/.bash_profile and ~/.bash_login shadow ~/.profile: bash reads only the
    # first of the three it finds in a login shell. Neither is managed here, so
    # the symlink report above cannot see them -- it only walks the repo.
    local stray found=0
    for stray in .bash_profile .bash_login; do
        if [[ -e "$HOME/$stray" || -L "$HOME/$stray" ]]; then
            printf '  CONFLICT ~/%s shadows ~/.profile in a login shell\n' "$stray"
            found=1; rc=1
        fi
    done
    (( found )) || printf '  ok       no ~/.bash_profile or ~/.bash_login shadowing ~/.profile\n'

    # .profile is read by any POSIX login shell, not just bash, and it must stay
    # silent on stdout or it breaks scp/sftp/rsync. Check both in one shot.
    local prof_out prof_err prof_rc=0
    prof_err="$(sh -c '. "$HOME/.profile"' 2>&1 >/dev/null)" || prof_rc=$?
    prof_out="$(sh -c '. "$HOME/.profile"' 2>/dev/null || true)"
    if (( prof_rc != 0 )) || [[ -n "$prof_err" ]]; then
        printf '  FAIL     ~/.profile is not clean under sh (rc=%s)\n' "$prof_rc"; rc=1
        [[ -n "$prof_err" ]] && printf '           %s\n' "$prof_err"
    elif [[ -n "$prof_out" ]]; then
        printf '  FAIL     ~/.profile writes to stdout (breaks scp/rsync)\n'; rc=1
        printf '           %s\n' "$prof_out"
    else
        printf '  ok       ~/.profile sources cleanly under sh, stdout silent\n'
    fi

    echo
    echo "== sudo =="
    if sudo_can_see nvim; then
        printf '  ok       nvim reachable from sudo PATH\n'
    elif command -v nvim >/dev/null 2>&1; then
        printf '  MISSING  nvim not on sudo PATH -- run install.sh, or:\n'
        printf '           sudo ln -snf %s %s\n' "$(command -v nvim)" "$NVIM_SUDO_LINK"
        rc=1
    else
        printf '  -        nvim not installed\n'
    fi
    # sudoedit is the recommended path: it edits as us and writes back as root.
    if bash -lic '[ -n "${SUDO_EDITOR:-}" ] && [ -x "$SUDO_EDITOR" ]' 2>/dev/null; then
        printf '  ok       SUDO_EDITOR set for sudoedit\n'
    else
        printf '  MISSING  SUDO_EDITOR not usable in a login shell -- see ~/.profile\n'; rc=1
    fi

    echo
    echo "== tools =="
    # required: things the config assumes; optional: nice to have
    local required=(git bash)
    local optional=(zsh nvim starship fzf zoxide eza herdr tmux lazygit yazi bat batcat delta rg fd jq)
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
    local lf found_local=0
    for lf in local.sh local.bash local.zsh; do
        if [[ -f "$HOME/.config/shell/$lf" ]]; then
            echo "  ok       ~/.config/shell/$lf"
            found_local=1
        fi
    done
    if (( ! found_local )); then
        echo "  -        no ~/.config/shell/local.{sh,bash,zsh}"
        echo "           cp ~/.config/shell/local.sh.example ~/.config/shell/local.sh"
    fi
    # Left over from when the shell config lived in .config/bash. git moves only
    # tracked files, so an untracked local.bash stays behind there and nothing
    # reads it any more -- the secrets in it silently stop being loaded.
    if [[ -e "$DOTFILES_DIR/.config/bash" || -L "$HOME/.config/bash" ]]; then
        echo "  WARN     leftover .config/bash from before the move to .config/shell"
        echo "           move local.bash into ~/.config/shell/ (as local.sh if bash-neutral),"
        echo "           then delete $DOTFILES_DIR/.config/bash and the ~/.config/bash link"
        rc=1
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

# 2) link .config entries individually (never replace all of ~/.config).
#    CONFIG_PER_ENTRY のディレクトリは掘り下げて中身だけをリンクする。
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    while IFS= read -r rel; do
        link "$DOTFILES_DIR/.config/$rel" "$HOME/.config/$rel"
    done < <(config_entries)
fi

# 3) link .claude entries individually: ~/.claude also holds Claude Code's own
#    state (sessions, history, settings.json), so never link the directory itself.
if [[ -d "$DOTFILES_DIR/.claude" ]]; then
    for path in "$DOTFILES_DIR"/.claude/skills/*; do
        link "$path" "$HOME/.claude/skills/$(basename "$path")"
    done
    for path in "$DOTFILES_DIR"/.claude/*; do
        [[ "$(basename "$path")" == skills ]] && continue
        link "$path" "$HOME/.claude/$(basename "$path")"
    done
fi
shopt -u nullglob dotglob

# 4) make nvim visible to sudo (see nvim_sudo_link above)
nvim_sudo_link

echo "done."
echo
echo "next: cp ~/.config/shell/local.sh.example ~/.config/shell/local.sh"
echo "      bash install.sh --doctor"

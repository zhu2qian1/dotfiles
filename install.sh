#!/usr/bin/env bash
# ============================================================
# dotfiles symlink installer (Linux / WSL)
#
# リポジトリ構成は $HOME をミラーしているので、トップレベルの dotfile を
# $HOME 直下へ symlink する。冪等。既存の実体/別リンクは <name>.bak に退避。
#
#   bash install.sh             # 実行
#   bash install.sh --dry-run   # 変更せず、何が起きるか表示
#
# Windows 専用設定 (komorebi*.json / applications.json / profile.ps1) は
# install.ps1 または手動。ここでは扱わない (下の IGNORE 参照)。
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
case "${1:-}" in
    -n|--dry-run) DRY_RUN=1 ;;
    "")           ;;
    *) echo "usage: bash install.sh [--dry-run]" >&2; exit 2 ;;
esac

# $HOME 直下へは symlink しないトップレベル項目
#   - リポジトリ管理用ファイル / スクリプト自身 / バックアップ
#   - 特別扱いするディレクトリ (.config, .claude は中身を個別リンク)
#   - Windows 側で扱う設定 (install.ps1 / 手動)
IGNORE=(
    ".git" ".gitignore" "README.md"
    "install.sh" "install.ps1"
    ".config" ".claude"                 # 中身を個別リンク (後段で処理)
    "init.lua"                          # repo 内シンボリックリンク (.config/nvim/init.lua)
    ".vscode"                           # ~/.vscode と衝突しうるので既定では張らない
    # ---- Windows 側 / 手動 ----
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

echo "dotfiles: $DOTFILES_DIR  (dry-run=$DRY_RUN)"

# 1) トップレベルの dotfile を $HOME へ
shopt -s nullglob dotglob
for path in "$DOTFILES_DIR"/*; do
    name="$(basename "$path")"
    in_ignore "$name" && continue
    [[ "$name" == *.bk || "$name" == *.bk-* ]] && continue   # 退避ファイル
    link "$path" "$HOME/$name"
done

# 2) .config 配下は個別にリンク (.config 全体は置き換えない)
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    for path in "$DOTFILES_DIR"/.config/*; do
        link "$path" "$HOME/.config/$(basename "$path")"
    done
fi

# 3) .claude/skills 配下は個別リンク (他のグローバル skill と共存させる)
if [[ -d "$DOTFILES_DIR/.claude/skills" ]]; then
    for path in "$DOTFILES_DIR"/.claude/skills/*; do
        link "$path" "$HOME/.claude/skills/$(basename "$path")"
    done
fi
shopt -u nullglob dotglob

echo "done."
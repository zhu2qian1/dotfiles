#!/usr/bin/env bash
# ============================================================
# Clone the shell add-ons the config can use but no installer provides
#
# The shell config loads each of these only if it is present, so a machine
# without them still starts cleanly -- it just quietly loses <Tab> through fzf,
# command highlighting and so on. Distros package them unevenly (Arch has all
# the zsh ones, Ubuntu lacks zsh-history-substring-search and zsh-completions,
# nobody packages fzf-tab-completion), so this clones them into
# ${XDG_DATA_HOME:-~/.local/share} instead. No sudo. Idempotent.
#
#   bash install-extra-tools.sh             # clone what is missing
#   bash install-extra-tools.sh --update    # also fast-forward existing clones
#   bash install-extra-tools.sh --dry-run   # show what would happen, change nothing
#
# A zsh plugin the OS package already provides is skipped: 90-plugins.zsh
# prefers the package, so a clone next to it would never be read.
# ============================================================
set -euo pipefail

DRY_RUN=0
UPDATE=0
case "${1:-}" in
    -n|--dry-run) DRY_RUN=1 ;;
    -u|--update)  UPDATE=1 ;;
    "")           ;;
    *) echo "usage: bash install-extra-tools.sh [--dry-run|--update]" >&2; exit 2 ;;
esac

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
# Mirrors Arch's /usr/share/zsh/plugins/<name>/ so the layout reads the same.
ZSH_PLUGIN_DIR="$DATA_DIR/zsh/plugins"

# <clone dir> <repository>. The paths are what the shell config looks for:
#   fzf-tab-completion       30-tools.{bash,zsh}
#   zsh/plugins/zsh-*        90-plugins.zsh (fallback after the OS package)
#   zsh-completions/src      10-shell.zsh puts it on fpath before compinit
TOOLS=(
    "$DATA_DIR/fzf-tab-completion"                  https://github.com/lincheney/fzf-tab-completion
    "$ZSH_PLUGIN_DIR/zsh-autosuggestions"           https://github.com/zsh-users/zsh-autosuggestions
    "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"       https://github.com/zsh-users/zsh-syntax-highlighting
    "$ZSH_PLUGIN_DIR/zsh-history-substring-search"  https://github.com/zsh-users/zsh-history-substring-search
    "$ZSH_PLUGIN_DIR/zsh-completions"               https://github.com/zsh-users/zsh-completions
)

# Print where the OS already provides <name>, or fail. The plugin paths are
# the same list 90-plugins.zsh walks; keep the two in step.
system_copy() {
    local name="$1" dir
    case "$name" in
        zsh-completions)
            # Arch and Homebrew drop its functions straight into a directory
            # that is on fpath already, so there is no plugin file to find.
            if command -v pacman >/dev/null 2>&1 && pacman -Qq zsh-completions >/dev/null 2>&1; then
                echo "pacman package zsh-completions"; return 0
            fi
            if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
                echo "$HOMEBREW_PREFIX/share/zsh-completions"; return 0
            fi
            return 1 ;;
        zsh-*)
            for dir in /usr/share/zsh/plugins/"$name" /usr/share/"$name" \
                       ${HOMEBREW_PREFIX:+"$HOMEBREW_PREFIX/share/$name"}; do
                if [[ -r "$dir/$name.zsh" ]]; then
                    echo "$dir"; return 0
                fi
            done
            return 1 ;;
        *)  return 1 ;;
    esac
}

if ! command -v git >/dev/null 2>&1; then
    echo "git is required" >&2
    exit 1
fi

rc=0
for (( i = 0; i < ${#TOOLS[@]}; i += 2 )); do
    dest="${TOOLS[i]}"
    repo="${TOOLS[i+1]}"
    name="$(basename "$dest")"

    if [[ -d "$dest/.git" ]]; then
        if (( UPDATE )); then
            echo "  update  $dest"
            # --ff-only: a clone with local commits is left for a human to sort out.
            (( DRY_RUN )) || git -C "$dest" pull --ff-only --quiet || {
                echo "          pull failed, left as is" >&2; rc=1; }
        else
            echo "  ok      $dest"
        fi
    elif [[ -e "$dest" ]]; then
        # Something else sits where the clone should go; never move it aside.
        echo "  SKIP    $dest exists but is not a git clone" >&2; rc=1
    elif from="$(system_copy "$name")"; then
        echo "  skip    $name (provided by $from)"
    else
        echo "  clone   $repo -> $dest"
        if (( ! DRY_RUN )); then
            mkdir -p "$(dirname "$dest")"
            git clone --depth 1 --quiet "$repo" "$dest" || {
                echo "          clone failed" >&2; rc=1; }
        fi
    fi
done

(( DRY_RUN )) && echo "(dry run: nothing changed)"
echo "Open a new shell to pick them up."
exit $rc

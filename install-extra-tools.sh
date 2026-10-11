#!/usr/bin/env bash
# ============================================================
# Install the add-ons the config can use but no installer provides
#
# The shell config loads each of these only if it is present, so a machine
# without them still starts cleanly -- it just quietly loses <Tab> through fzf,
# command highlighting and so on. Distros package them unevenly (Arch has all
# the zsh ones, Ubuntu lacks zsh-history-substring-search and zsh-completions,
# nobody packages fzf-tab-completion), so this clones them into
# ${XDG_DATA_HOME:-~/.local/share} instead. No sudo. Idempotent.
#
# It also installs the tree-sitter CLI, which nvim-treesitter (IDE profile,
# lua/ide/plugins/treesitter.lua) needs to build its parsers. See
# install_tree_sitter below for why it is not left to the distro.
#
#   bash install-extra-tools.sh             # install what is missing
#   bash install-extra-tools.sh --update    # also fast-forward existing clones
#                                           # and refresh our own tree-sitter copy
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

# nvim-treesitter's main branch refuses anything older (see its README), and
# it does not support the npm package. Distro packages lag far behind -- Ubuntu
# 24.04 ships 0.20 -- so an existing copy is checked by version, not presence.
TREE_SITTER_MIN=0.26.1
# Where our own copy goes when Homebrew is not around. ~/.profile prepends it
# to PATH, so it also shadows an outdated distro package in /usr/bin.
TREE_SITTER_LOCAL="$HOME/.local/bin/tree-sitter"

# Print the version of the tree-sitter on PATH ("tree-sitter 0.27.1 (...)").
tree_sitter_version() {
    tree-sitter --version 2>/dev/null | awk '{ print $2; exit }'
}

# true if $1 >= $2 in version order.
version_ge() {
    [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}

# Fetch the prebuilt single-binary release (tree-sitter-<os>-<arch>.gz) into
# TREE_SITTER_LOCAL. releases/latest/download/ redirects to the newest tag, so
# no GitHub API call (and no jq) is needed.
download_tree_sitter() {
    local os arch url tmp
    case "$(uname -s)" in
        Linux)  os=linux ;;
        Darwin) os=macos ;;
        *) echo "          no prebuilt tree-sitter for $(uname -s)" >&2; return 1 ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)  arch=x64 ;;
        aarch64|arm64) arch=arm64 ;;
        armv7l|armv6l) arch=arm ;;
        i?86)          arch=x86 ;;
        *) echo "          no prebuilt tree-sitter for $(uname -m)" >&2; return 1 ;;
    esac
    url="https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-$os-$arch.gz"
    echo "  fetch   $url -> $TREE_SITTER_LOCAL"
    (( DRY_RUN )) && return 0
    if ! command -v curl >/dev/null 2>&1 || ! command -v gzip >/dev/null 2>&1; then
        echo "          curl and gzip are required" >&2; return 1
    fi
    mkdir -p "$(dirname "$TREE_SITTER_LOCAL")"
    # Write next to the target and rename, so a failed download never leaves a
    # truncated binary where the old working one was.
    tmp="$(mktemp "$TREE_SITTER_LOCAL.XXXXXX")"
    if curl -fsSL "$url" | gzip -dc > "$tmp" && chmod +x "$tmp"; then
        mv -f "$tmp" "$TREE_SITTER_LOCAL"
    else
        rm -f "$tmp"
        echo "          download failed" >&2; return 1
    fi
}

install_tree_sitter() {
    local have path
    have="$(tree_sitter_version)"
    path="$(command -v tree-sitter 2>/dev/null || true)"

    if [[ -n "$have" ]] && version_ge "$have" "$TREE_SITTER_MIN"; then
        if (( UPDATE )) && [[ "$path" == "$TREE_SITTER_LOCAL" ]]; then
            download_tree_sitter || return 1
        else
            # A brew / distro copy is upgraded by its package manager, not here.
            echo "  ok      tree-sitter $have ($path)"
        fi
    else
        [[ -n "$have" ]] && echo "  old     tree-sitter $have ($path) < $TREE_SITTER_MIN"
        if command -v brew >/dev/null 2>&1; then
            # Prefer Homebrew where it exists, so `brew upgrade` keeps it current.
            echo "  brew    install tree-sitter-cli"
            (( DRY_RUN )) || brew install --quiet tree-sitter-cli || {
                echo "          brew install failed" >&2; return 1; }
        else
            download_tree_sitter || return 1
        fi
    fi

    # The CLI shells out to a C compiler to build each parser; without one
    # nvim-treesitter fails at "tree-sitter build" all the same.
    if ! command -v cc >/dev/null 2>&1 && ! command -v gcc >/dev/null 2>&1 \
        && ! command -v clang >/dev/null 2>&1; then
        echo "  WARN    no C compiler (cc/gcc/clang): tree-sitter cannot build parsers" >&2
        echo "          e.g. sudo apt install build-essential" >&2
    fi
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

install_tree_sitter || rc=1

(( DRY_RUN )) && echo "(dry run: nothing changed)"
echo "Open a new shell to pick them up."
exit $rc

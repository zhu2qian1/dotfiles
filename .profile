# ~/.profile: read by login shells. Keep it POSIX sh compatible.
#
# This file holds only what non-interactive shells also need: PATH, EDITOR, locale.
# .bashrc returns early when non-interactive, so PATH set there is invisible to
#   ssh host 'cmd' / cron / systemd user units / VSCode Remote / git's core.editor
# Drawing that line is the whole reason this file exists.
#
# Constraint: never write to stdout (it breaks scp/sftp/rsync).

# Guard against double loading (.bashrc may source us; see the pairing at the bottom).
[ -n "${DOTFILES_PROFILE_LOADED:-}" ] && return 0
DOTFILES_PROFILE_LOADED=1

# ------------------------------------------------------------- PATH helpers
# No-op if already present; skip directories that do not exist.
# Keeps PATH from growing when this file is re-sourced.
path_append() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$PATH:$1" ;;
    esac
}
path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1:$PATH" ;;
    esac
}

# -------------------------------------------------------------------- XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ---------------------------------------------------------------- Homebrew
# One loop covers macOS (Apple Silicon / Intel) and Linuxbrew.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -x "$_brew" ]; then
        eval "$("$_brew" shellenv)"
        break
    fi
done
unset _brew

# ------------------------------------------------------------- Toolchains
# rustup. Puts cargo/bin at the front so it overrides a system rustc.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# env file dropped by uv / rye, if present
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# SDKMAN. It rewrites PATH, so it belongs here rather than in interactive
# config -- this is what makes `ssh host 'java -version'` and cron jobs work.
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$SDKMAN_DIR/bin/sdkman-init.sh"

# -------------------------------------------------------------- User PATH
# Later prepends win. User-owned directories take precedence.
path_prepend "/opt/nvim"          # nvim tarball, binary placed directly
path_prepend "/opt/nvim/bin"      # nvim tarball, with a bin/ subdir
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# ----------------------------------------------------------------- EDITOR
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
elif command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi
export VISUAL="$EDITOR"

# ------------------------------------------------- Hand off to interactive
# For an interactive bash, also read .bashrc (matches the Ubuntu default).
# .bashrc sources us when we have not run, so both entry points are covered here.
if [ -n "${BASH_VERSION:-}" ] && [ -n "${PS1:-}" ] && [ -z "${DOTFILES_BASHRC_LOADED:-}" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

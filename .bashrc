# ~/.bashrc: interactive bash.
#
# This file is just a loader. The actual settings live in ~/.config/bash/*.bash.
# Environment variables and PATH belong in ~/.profile, not here, because
# non-interactive shells need them too.

# --------------------------------------------- Environment (before the guard)
# For `ssh host 'cmd'` bash reads .bashrc even when non-interactive (Debian
# build default) but never reads .profile, so pick it up here or PATH is unset.
# _ATTEMPTED is set before sourcing so that a foreign .profile (Ubuntu's ships
# one that unconditionally sources .bashrc) cannot bounce us into a loop.
DOTFILES_BASHRC_LOADED=1
if [ -z "${DOTFILES_PROFILE_LOADED:-}" ] && [ -z "${DOTFILES_PROFILE_ATTEMPTED:-}" ] \
   && [ -f "$HOME/.profile" ]; then
    DOTFILES_PROFILE_ATTEMPTED=1
    . "$HOME/.profile"
fi

# Stop here when non-interactive. Everything below is interactive-only.
case $- in
    *i*) ;;
      *) return;;
esac

# ------------------------------------------------------------------- Loader
# Load order:
#   1. [0-9]*.bash        numbered (00 history -> 10 shell -> 20 aliases
#                         -> 30 tools -> 40 prompt)
#   2. os/<os>.bash       per-OS (linux / darwin / windows)
#   3. host/<host>.bash   per-machine
#   4. local.bash         machine-only secrets and overrides (not in git)
# Later files win. Adding a file is enough to enable it; a missing one is fine.
_bash_conf="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

case "$OSTYPE" in
    linux*)         _bash_os=linux ;;
    darwin*)        _bash_os=darwin ;;
    msys*|cygwin*)  _bash_os=windows ;;
    *)              _bash_os=other ;;
esac

for _bash_f in \
    "$_bash_conf"/[0-9]*.bash \
    "$_bash_conf/os/$_bash_os.bash" \
    "$_bash_conf/host/${HOSTNAME%%.*}.bash" \
    "$_bash_conf/local.bash"
do
    [ -r "$_bash_f" ] && . "$_bash_f"
done

unset _bash_conf _bash_os _bash_f

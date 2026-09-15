# ~/.bashrc: interactive bash.
#
# This file is just a loader. The actual settings live in ~/.config/shell/,
# most of them shared with zsh (see its README.md for the load order).
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
# At each step the shared *.sh (read by zsh too) loads first, then the
# bash-only *.bash of the same name:
#   1. [0-9]*.{sh,bash}       numbered (00 history -> 10 shell -> 20 aliases
#                             -> 30 tools -> 40 prompt -> 50 zoxide)
#   2. os/<os>.{sh,bash}      per-OS (linux / darwin / windows)
#   3. host/<host>.{sh,bash}  per-machine
#   4. local.{sh,bash}        machine-only secrets and overrides (not in git)
# Later files win. Adding a file is enough to enable it; a missing one is fine.
_shell_conf="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

case "$OSTYPE" in
    linux*)         _shell_os=linux ;;
    darwin*)        _shell_os=darwin ;;
    msys*|cygwin*)  _shell_os=windows ;;
    *)              _shell_os=other ;;
esac

# A glob that matches nothing stays literal, ends in neither suffix, and is skipped.
for _shell_f in "$_shell_conf"/[0-9]*; do
    case "$_shell_f" in
        *.sh)   . "$_shell_f"
                [ -r "${_shell_f%.sh}.bash" ] && . "${_shell_f%.sh}.bash" ;;
        *.bash) [ -e "${_shell_f%.bash}.sh" ] || . "$_shell_f" ;;  # else done with its .sh
    esac
done

for _shell_f in \
    "$_shell_conf/os/$_shell_os" \
    "$_shell_conf/host/${HOSTNAME%%.*}" \
    "$_shell_conf/local"
do
    [ -r "$_shell_f.sh" ]   && . "$_shell_f.sh"
    [ -r "$_shell_f.bash" ] && . "$_shell_f.bash"
done

unset _shell_conf _shell_os _shell_f

# ~/.zshrc: interactive zsh.
#
# Like ~/.bashrc, this file is just a loader. Settings live in ~/.config/shell/,
# most of them shared with bash (see its README.md for the load order).
# Environment variables and PATH belong in ~/.profile, which zsh never reads by
# itself: ~/.zprofile (login) and ~/.zshenv (`ssh host 'cmd'`) hand it over.
#
# SDKMAN is initialised from ~/.profile for both shells. If its installer
# appends its "MUST BE AT THE END OF THE FILE" snippet here again, drop it.

# --------------------------------------------------------------- Environment
# A terminal emulator usually starts a non-login shell, so neither file above
# ran unless the desktop session read ~/.profile already. Pick it up here, the
# same way the top of ~/.bashrc does.
DOTFILES_ZSHRC_LOADED=1
if [[ -z ${DOTFILES_PROFILE_LOADED:-} && -f $HOME/.profile ]]; then
    . "$HOME/.profile"
fi

# -------------------------------------------------------------------- Loader
# Same order as ~/.bashrc. At each step the shared *.sh loads first, then the
# zsh-only *.zsh of the same name:
#   1. [0-9]*.{sh,zsh}      numbered (00 history -> 10 shell -> 20 aliases
#                           -> 30 tools -> 40 prompt -> 50 zoxide -> 90 plugins)
#   2. os/<os>.{sh,zsh}     per-OS (linux / darwin / windows)
#   3. host/<host>.{sh,zsh} per-machine
#   4. local.{sh,zsh}       machine-only secrets and overrides (not in git)
# Later files win. Adding a file is enough to enable it; a missing one is fine.
_shell_conf="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

case "$OSTYPE" in
    linux*)         _shell_os=linux ;;
    darwin*)        _shell_os=darwin ;;
    msys*|cygwin*)  _shell_os=windows ;;
    *)              _shell_os=other ;;
esac

# (N): expand to nothing instead of erroring when nothing matches.
for _shell_f in "$_shell_conf"/[0-9]*(N); do
    case "$_shell_f" in
        *.sh)  . "$_shell_f"
               [[ -r ${_shell_f%.sh}.zsh ]] && . "${_shell_f%.sh}.zsh" ;;
        *.zsh) [[ -e ${_shell_f%.zsh}.sh ]] || . "$_shell_f" ;;  # else done with its .sh
    esac
done

for _shell_f in \
    "$_shell_conf/os/$_shell_os" \
    "$_shell_conf/host/${HOST%%.*}" \
    "$_shell_conf/local"
do
    [[ -r $_shell_f.sh ]]  && . "$_shell_f.sh"
    [[ -r $_shell_f.zsh ]] && . "$_shell_f.zsh"
done

unset _shell_conf _shell_os _shell_f

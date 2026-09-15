# ~/.zprofile: login zsh.
#
# zsh never reads ~/.profile, which is where PATH, EDITOR and locale live for
# every shell (see its header), so hand it over here. /etc/zsh/zprofile runs
# just before this file (Arch: emulate sh -c 'source /etc/profile'), so our
# PATH prepends still land in front of the system ones.
#
# Sourced natively rather than under `emulate sh`: sh emulation switches on
# ksh-style arrays and word splitting for everything sourced from .profile,
# including sdkman-init.sh and brew's shellenv output, which branch on
# ZSH_VERSION and expect zsh's own semantics.
[[ -f $HOME/.profile ]] && . "$HOME/.profile"

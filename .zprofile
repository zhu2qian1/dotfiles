# ~/.zprofile: login zsh.
#
# zsh never reads /etc/profile either. Arch's /etc/zsh/zprofile sources it, but
# Ubuntu's is comments only, so /etc/profile.d/ (im-config_wayland.sh, which
# starts fcitx5 on GNOME Wayland; apps-bin-path.sh, ...) was skipped. Source it
# here when the system zprofile doesn't, ahead of ~/.profile so our PATH
# prepends still land in front of the system ones.
if [[ ! -r /etc/zsh/zprofile ]] || ! grep -q '^[^#]*/etc/profile' /etc/zsh/zprofile; then
    emulate sh -c '. /etc/profile'
fi

# zsh never reads ~/.profile, which is where PATH, EDITOR and locale live for
# every shell (see its header), so hand it over here.
#
# Sourced natively rather than under `emulate sh`: sh emulation switches on
# ksh-style arrays and word splitting for everything sourced from .profile,
# including sdkman-init.sh and brew's shellenv output, which branch on
# ZSH_VERSION and expect zsh's own semantics.
[[ -f $HOME/.profile ]] && . "$HOME/.profile"

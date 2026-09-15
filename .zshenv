# ~/.zshenv: read by every zsh, scripts included -- keep it to this one job.
#
# `ssh host 'cmd'` runs a zsh that is neither login nor interactive, and this
# is the only file it reads. Without ~/.profile, PATH is the bare system one and
# `ssh host nvim` or git over ssh to a brew-installed git fails.
# bash has the same hole and fills it at the top of ~/.bashrc, which bash reads
# in that situation only when started by sshd. Mirror that condition --
# SSH_CONNECTION set, SHLVL 1 -- instead of taxing every zsh script with it.
if [[ ! -o login && ! -o interactive && -n ${SSH_CONNECTION:-} && ${SHLVL:-0} -le 1 ]] \
   && [[ -z ${DOTFILES_PROFILE_LOADED:-} && -f $HOME/.profile ]]; then
    . "$HOME/.profile"
fi

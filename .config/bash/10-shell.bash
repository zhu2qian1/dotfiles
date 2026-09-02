# Shell behaviour itself.

# Re-read the window size after every command
shopt -s checkwinsize

# ** for recursive globbing
shopt -s globstar

# Fix typos in cd arguments (dowload -> download)
shopt -s cdspell dirspell

# Guard against clobbering files with > (use >| to force)
set -o noclobber

# bash-completion. Must load before anything that registers completions (tailscale).
if ! shopt -oq posix; then
    for _bc in \
        /usr/share/bash-completion/bash_completion \
        /etc/bash_completion \
        "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
    do
        [ -r "$_bc" ] && { . "$_bc"; break; }
    done
    unset _bc
fi

# zsh-only plugins with no bash counterpart. Each is optional; a machine
# without the package just skips it.
#
# Numbered last on purpose: zsh-syntax-highlighting has to load after every
# other widget is defined (fzf, fzf-tab-completion, zoxide), and
# zsh-history-substring-search after zsh-syntax-highlighting. The list below is
# in that order.
#
# Sourced at top level, not from a helper function: variables a plugin declares
# without -g would otherwise become locals of that function and vanish.
#
#   Arch / Manjaro   /usr/share/zsh/plugins/<name>/<name>.zsh
#   Debian / Ubuntu  /usr/share/<name>/<name>.zsh
#   Homebrew         $HOMEBREW_PREFIX/share/<name>/<name>.zsh
for _zsh_plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search; do
    for _zsh_plugin_dir in \
        /usr/share/zsh/plugins/$_zsh_plugin \
        /usr/share/$_zsh_plugin \
        ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/$_zsh_plugin}
    do
        if [[ -r $_zsh_plugin_dir/$_zsh_plugin.zsh ]]; then
            . "$_zsh_plugin_dir/$_zsh_plugin.zsh"
            break
        fi
    done
done
unset _zsh_plugin _zsh_plugin_dir

# Up/Down: match what is typed anywhere in the line, replacing the prefix
# search bound in 10-shell.zsh.
if (( ${+functions[history-substring-search-up]} )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[OA' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OB' history-substring-search-down
fi

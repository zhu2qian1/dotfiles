# Shell behaviour for zsh -- the counterpart of 10-shell.bash.
# checkwinsize and globstar (**) are always on in zsh. cdspell/dirspell have no
# real equivalent (setopt correct fixes command names, which is something else).

# Treat `# ...` typed at the prompt as a comment, as bash does. zsh's default
# makes it a syntax error, which bites when pasting commented snippets.
setopt interactive_comments

# Guard against clobbering files with > (use >| to force)
setopt noclobber

# ------------------------------------------------------------ completion
# Must run before anything that registers completions (tailscale, herdr,
# fzf-tab-completion) -- the counterpart of bash-completion in 10-shell.bash.
# -i: skip insecure directories silently. Without it compinit stops to ask y/n,
#     which hangs non-interactive callers such as `install.sh --doctor`.
# The dump goes under XDG_CACHE_HOME instead of littering $HOME with .zcompdump.
_zcompdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcompdump_dir ]] || mkdir -p "$_zcompdump_dir"
autoload -Uz compinit
compinit -i -d "$_zcompdump_dir/zcompdump-$ZSH_VERSION"
unset _zcompdump_dir

# ~/.inputrc's completion-ignore-case and colored-stats.
# LS_COLORS is set later by 20-aliases.sh, so list-colors is evaluated (-e) at
# completion time rather than now, when it would still be empty.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle -e ':completion:*' list-colors 'reply=("${(s.:.)LS_COLORS}")'

# ---------------------------------------------------------- key bindings
# zsh picks the vi keymap on its own when EDITOR/VISUAL contains "vi", and
# ~/.profile sets EDITOR=nvim. Pin emacs, readline's default, to match bash.
bindkey -e

# Up/Down search history for lines starting with what is already typed --
# ~/.inputrc's history-search-backward/forward. 90-plugins.zsh swaps these for
# substring search when zsh-history-substring-search is installed.
bindkey '^[[A' history-beginning-search-backward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OB' history-beginning-search-forward

# readline gets these from /etc/inputrc; zsh's emacs keymap lacks some of them
# (an unbound Delete inserts a literal `~`).
bindkey '^[[H'    beginning-of-line     # Home
bindkey '^[OH'    beginning-of-line
bindkey '^[[1~'   beginning-of-line
bindkey '^[[F'    end-of-line           # End
bindkey '^[OF'    end-of-line
bindkey '^[[4~'   end-of-line
bindkey '^[[3~'   delete-char           # Delete
bindkey '^[[1;5D' backward-word         # Ctrl-Left
bindkey '^[[1;5C' forward-word          # Ctrl-Right

# zsh's ^U kills the whole line; readline's kills only up to the cursor.
bindkey '^U' backward-kill-line

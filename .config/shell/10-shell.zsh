# Shell behaviour for zsh -- the counterpart of 10-shell.bash.
# checkwinsize and globstar (**) are always on in zsh. cdspell/dirspell have no
# real equivalent (setopt correct fixes command names, which is something else).

# Treat `# ...` typed at the prompt as a comment, as bash does. zsh's default
# makes it a syntax error, which bites when pasting commented snippets.
setopt interactive_comments

# Guard against clobbering files with > (use >| to force)
setopt noclobber

# The rest of Manjaro's stock options (manjaro-zsh-config), kept so a Manjaro
# machine behaves as it did before this config replaced that one. The history
# ones are in 00-history.zsh. rcexpandparam is deliberately left out: it changes
# what `x${array}y` expands to for every function that does not reset options,
# including the ones fzf, starship and the plugins define.
setopt auto_cd              # a bare directory name cds into it
setopt extended_glob        # ^ ~ # are glob operators -- quote `HEAD^` for git
setopt no_case_glob         # globs ignore case
setopt numeric_glob_sort    # file2 before file10
setopt correct              # offer to fix a mistyped command name
setopt no_check_jobs        # exit without complaining about background jobs
setopt no_beep

# Ctrl-W and Alt-Backspace stop at / and &, so they eat one path component
# instead of the whole path. The same two characters Manjaro removed.
WORDCHARS=${WORDCHARS//[\/&]}

# ------------------------------------------------------------ completion
# Must run before anything that registers completions (tailscale, herdr,
# fzf-tab-completion) -- the counterpart of bash-completion in 10-shell.bash.
# -i: skip insecure directories silently. Without it compinit stops to ask y/n,
#     which hangs non-interactive callers such as `install.sh --doctor`.
# The dump goes under XDG_CACHE_HOME instead of littering $HOME with .zcompdump.
_zcompdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $_zcompdump_dir ]] || mkdir -p "$_zcompdump_dir"

# Extra completion functions (zsh-completions). Arch's package puts them in
# site-functions, which is on fpath already; elsewhere install-extra-tools.sh
# clones them. Appended, so a definition zsh itself ships still wins.
_zsh_completions="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-completions/src"
[[ -d $_zsh_completions ]] && fpath+=("$_zsh_completions")
unset _zsh_completions

autoload -Uz compinit
compinit -i -d "$_zcompdump_dir/zcompdump-$ZSH_VERSION"

# Cache completers that support it (apt, dpkg, ...) next to the dump.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$_zcompdump_dir/compcache"
unset _zcompdump_dir

# ~/.inputrc's completion-ignore-case and colored-stats.
# LS_COLORS is set later by 20-aliases.sh, so list-colors is evaluated (-e) at
# completion time rather than now, when it would still be empty.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle -e ':completion:*' list-colors 'reply=("${(s.:.)LS_COLORS}")'

# From Manjaro's stock config. menu select only shows when fzf-tab-completion
# is absent, since that replaces <Tab> with fzf (30-tools.zsh).
zstyle ':completion:*' menu select              # move through candidates with arrows
zstyle ':completion:*' rehash true              # see newly installed commands at once
zstyle ':completion:*' accept-exact '*(N)'      # skip the slow path on an exact match

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

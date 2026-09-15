# History for zsh -- the counterpart of 00-history.bash, same sizes and filters.
# Multi-line commands are kept as one entry natively, so there is no cmdhist.

# The file Manjaro's stock zsh config used, so existing history carries over.
HISTFILE="$HOME/.zhistory"
HISTSIZE=100000
SAVEHIST=200000

# Record when each command ran (and how long it took) -- bash: HISTTIMEFORMAT
setopt extended_history

# Drop duplicates and lines starting with a space -- bash: ignoreboth:erasedups
setopt hist_ignore_space hist_ignore_all_dups

# Write each command to the file once it finishes -- bash: histappend plus
# `history -a` at every prompt. Deliberately not share_history: as in bash,
# another terminal's commands do not appear here until a new shell starts.
setopt inc_append_history_time

# Not worth recording -- bash: HISTIGNORE. zsh applies it only when writing the
# file, so such a command stays in this session's history until exit.
HISTORY_IGNORE='(ls|ll|la|l|lla|llai|z|z -|cd|cd -|pwd|exit|clear|cl|history|sb)'

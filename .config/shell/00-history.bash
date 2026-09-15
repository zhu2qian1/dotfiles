# History. We hop between machines, so keep it long and timestamped.

# Drop duplicates and lines starting with a space
HISTCONTROL=ignoreboth:erasedups

# Append instead of overwriting (several terminals can be open at once)
shopt -s histappend

# Keep a multi-line command as one entry, newlines intact
shopt -s cmdhist lithist

HISTSIZE=100000
HISTFILESIZE=200000

# Record when each command ran -- useful when reading another machine's history
HISTTIMEFORMAT='%F %T  '

# Not worth recording
HISTIGNORE='ls:ll:la:l:lla:llai:z:z -:cd:cd -:pwd:exit:clear:cl:history:sb'

# Flush history to the file at every prompt. Without this, with several
# terminals open only the last one to exit keeps its history.
# starship and zoxide also use PROMPT_COMMAND, so prepend rather than overwrite.
case "$PROMPT_COMMAND" in
    *history\ -a*) ;;
    "")  PROMPT_COMMAND='history -a' ;;
    *)   PROMPT_COMMAND="history -a;$PROMPT_COMMAND" ;;
esac

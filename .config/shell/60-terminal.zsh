# Terminal title and working-directory reports for zsh -- what Manjaro's stock
# config (manjaro-zsh-config) did, so a Manjaro machine keeps them. Nothing here
# prints unless the terminal asked for a prompt, so non-interactive use is safe.

if [[ $TERM != (dumb|linux) ]]; then
    autoload -Uz add-zsh-hook

    # ----------------------------------------------------------- title
    # At the prompt: user@host: cwd, as the plain-prompt fallback used to set.
    _term_title_precmd() {
        print -Pn '\e]2;%n@%m: %~\a'
    }

    # While a command runs: its command line, so a tab busy with a long job
    # says what it is. The line goes through print -r, never -P: with
    # prompt_subst (starship turns it on) -P would expand $(...) in it.
    _term_title_preexec() {
        emulate -L zsh
        local line=${1//[[:cntrl:]]/ }      # one line, no stray escapes
        (( ${#line} > 100 )) && line="${line[1,97]}..."
        print -rn -- $'\e]2;'"$line"$'\a'
    }

    add-zsh-hook precmd  _term_title_precmd
    add-zsh-hook preexec _term_title_preexec

    # ----------------------------------------------------------- OSC 7
    # Tell the terminal the cwd as a file:// URL, so a new tab or split opens
    # in the same directory. Sent from precmd rather than chpwd: a function
    # that cds without -q would otherwise have the sequence in its output.
    _term_osc7() {
        emulate -L zsh
        # LC_ALL=C: walk the path byte by byte, so multibyte names come out
        # as the per-byte %XX the URL spec wants.
        local LC_ALL=C c url=
        for c in ${(s::)PWD}; do
            if [[ $c == [A-Za-z0-9/._~-] ]]; then
                url+=$c
            else
                url+=%${(l:2::0:)$(( [##16] #c ))}
            fi
        done
        print -rn -- $'\e]7;file://'"$HOST$url"$'\e\\'
    }

    add-zsh-hook precmd _term_osc7
fi

# Auto-start tmux for interactive shells.
#
# Forgetting to start tmux means a terminal can never be closed without losing
# whatever is running in it, so attach (or create) before anything else. This
# file is loaded early on purpose: the outer shell exec's away, and doing so
# before starship/fzf/asdf initialise saves that work.
#
# Opt out with DOTFILES_TMUX_AUTOSTART=0 (in local.bash, host/<host>.bash, or
# per-shell: `DOTFILES_TMUX_AUTOSTART=0 bash`).

_tmux_autostart() {
    [ "${DOTFILES_TMUX_AUTOSTART:-1}" = 1 ] || return
    # Already multiplexed, or inside something that does its own thing.
    [ -z "$TMUX" ] && [ -z "$STY" ] && [ -z "$ZELLIJ" ] || return
    [ -z "$INSIDE_EMACS" ] || return
    # Needs a real terminal; TERM=dumb means a caller that cannot drive tmux.
    [ -t 0 ] && [ -t 1 ] && [ "$TERM" != dumb ] || return
    command -v tmux >/dev/null 2>&1 || return

    local sessions target
    sessions=$(tmux list-sessions -F '#{session_attached} #{session_activity} #{session_name}' 2>/dev/null)

    # Prefer a detached "main"; otherwise the detached session used most
    # recently. Attached ones are left alone -- another machine is on them and
    # sharing a session mirrors every window switch to both ends.
    target=$(printf '%s\n' "$sessions" | awk '$1 == 0 && $3 == "main" { print $3 }')
    [ -n "$target" ] || target=$(printf '%s\n' "$sessions" \
        | awk '$1 == 0 { print $2, $3 }' | sort -rn | head -n1 | cut -d' ' -f2-)

    if [ -n "$target" ]; then
        exec tmux attach-session -t "=$target"
    elif printf '%s\n' "$sessions" | grep -q ' main$'; then
        # "main" exists but is attached elsewhere: take a fresh numbered one.
        exec tmux new-session
    else
        exec tmux new-session -s main
    fi
}

_tmux_autostart
unset -f _tmux_autostart

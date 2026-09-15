# Default starship config for both shells; local.* loads later and can override
# it (starship re-reads STARSHIP_CONFIG on every render, so a later change sticks).
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship/gruvbox-rainbow.toml}"

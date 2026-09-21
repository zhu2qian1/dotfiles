# vi:se bomb:
if (-not (Get-Command 'wezterm.exe' -ErrorAction SilentlyContinue)) {
    return
}

wezterm.exe shell-completion --shell power-shell | Out-String | Invoke-Expression

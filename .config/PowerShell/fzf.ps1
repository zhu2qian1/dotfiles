# fzf
if (-not(Get-Command "fzf" -ErrorAction SilentlyContinue)) {
    return;
}
function Invoke-MyFzf { fzf -e $args }
Set-Alias f  Invoke-MyFzf
Set-Alias ff fzf

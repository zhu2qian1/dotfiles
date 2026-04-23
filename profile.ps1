# vi:se et:

$Env:Editor='gvim'

if (Get-Command Enable-PsFzfAliases -ErrorAction SilentlyContinue) { Enable-PsFzfAliases }
# if (-not (Get-Module ZLocation)) { Install-Module -Name PSFzf -Scope CurrentUser }

function Add-TodayPrefix ($Str, [switch] $NoSep) {
    if ($NoSep) {
        return "$(Get-Date -Format 'yyyyMMdd')$str"
    } else {
        return "$(Get-Date -Format 'yyyyMMdd')-$str"
    }
}
Set-Alias atp Add-TodayPrefix

function Import-CustomSettings() {
    $ProfilePath = Split-Path ($PROFILE) -Parent
    $CustomProfilePath = "$ProfilePath\custom_profile.ps1"
    if (Test-Path ($CustomProfilePath)) {
        . $CustomProfilePath
        return 0
    }
    return 1
}
Import-CustomSettings | Out-Null

function Prompt() {
    Write-Host ""
    Write-Host -NoNewLine -ForegroundColor Blue "$env:username@$env:computername"
    Write-Host " $(Convert-Path $PWD)"
    return "PS> "
}
Set-Alias el explorer.exe

if (Get-Command "eza" -ErrorAction SilentlyContinue) {
    function Invoke-EzaLla { eza --all --icons --long --header --time-style long-iso $args }
    Set-Alias lla Invoke-EzaLla
    function Invoke-EzaLl  { eza       --icons --long --header --time-style long-iso $args }
    Set-Alias ll Invoke-EzaLl
}

if (Get-Command "fzf" -ErrorAction SilentlyContinue) {
    function Invoke-MyFzf { fzf -e $args }
    Set-Alias f  Invoke-MyFzf
    Set-Alias ff fzf
}


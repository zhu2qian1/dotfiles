# builtin exe aliases
Set-Alias el explorer.exe

# my functions
function Add-TodayPrefix ($Str, [switch] $NoSep) {
    if ($NoSep) { return "$(Get-Date -Format 'yyyyMMdd')$Str" }
    else { return "$(Get-Date -Format 'yyyyMMdd')-$Str" }
}

function Add-TodayPostfix($Str, [switch] $NoSep) {
    if ($NoSep) { return "$Str$(Get-Date -Format 'yyyyMMdd')" }
    else { return "$Str-$(Get-Date -Format 'yyyyMMdd')" }
}

function Add-DateAffix($Str, [switch] $Prefix, [switch] $NoSep) {
    if (-not $Prefix) { return "$Str$(('-', '')[$NoSep -eq $True])$(Get-Date -Format 'yyyyMMdd')" }
    return "$(Get-Date -Format 'yyyyMMdd')$(('-', '')[$NoSep -eq $True])$Str"
}
Set-Alias adax Add-DateAffix

function Add-DateTimeAffix($Str, [switch] $Prefix, [switch] $NoSep) {
    $DatetimeFormat = 'yyyyMMdd.hhmmss'
    if (-not $Prefix) { return "$Str$(('.', '')[$NoSep -eq $True])$(Get-Date -Format $DatetimeFormat)" }
    return "$(Get-Date -Format $DatetimeFormat)$(('.', '')[$NoSep -eq $True])$Str"
}
Set-Alias adtax Add-DateTimeAffix

function Add-Extension([Parameter(Mandatory)] $Path, [Parameter(Mandatory)]$Ext) {
    return "$Path.$Ext"
}
Set-Alias aext Add-Extension

function Copy-TimestampedBackup($Path) {
    if (-not (Test-Path $Path)) {
        throw [System.IO.FileNotFoundException]::new("missing: $Path")
    }
    Copy-Item $Path ( Add-Extension ( Add-DateTimeAffix "$Path" ) "bk" )
}
Set-Alias ctsb Copy-TimestampedBackup

function Edit-SshConfig () {
    if (Test-Path "$HOME\.ssh\config" -Type Leaf) {
        & $Env:editor "$HOME\.ssh\config"
    }
}
Set-Alias edssh Edit-SshConfig

# zoxide
# if (-not (Get-Module ZLocation)) { Install-Module -Name PSFzf -Scope CurrentUser }

# eza
if (Get-Command "eza" -ErrorAction SilentlyContinue) {
    function ll   { eza --long       --icons=auto --header --classify=auto --time-style relative              $Args }
    function lla  { eza --long --all --icons=auto --header --classify=auto --time-style relative              $Args }
    function lli  { eza --long       --icons=auto --header --classify=auto --time-style relative --git-ignore $Args }
    function llai { eza --long --all --icons=auto --header --classify=auto --time-style relative --git-ignore $Args }
}

# git
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    Set-Alias g git
}

# lazygit
if (Get-Command "lazygit" -ErrorAction SilentlyContinue) {
    Set-Alias lg lazygit
}


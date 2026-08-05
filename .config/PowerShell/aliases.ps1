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


# fzf
if (Get-Command Enable-PsFzfAliases -ErrorAction SilentlyContinue) { Enable-PsFzfAliases }

if (Get-Command "fzf" -ErrorAction SilentlyContinue) {
    function Invoke-MyFzf { fzf -e $args }
    Set-Alias f  Invoke-MyFzf
    Set-Alias ff fzf
}

# zoxide
# if (-not (Get-Module ZLocation)) { Install-Module -Name PSFzf -Scope CurrentUser }

# eza
if (Get-Command "eza" -ErrorAction SilentlyContinue) {
    function Invoke-EzaLla { eza --all --icons --long --header --time-style long-iso $args }
    Set-Alias lla Invoke-EzaLla
    function Invoke-EzaLl  { eza       --icons --long --header --time-style long-iso $args }
    Set-Alias ll Invoke-EzaLl
}

# git
if (Get-Command "git" -ErrorAction SilentlyContinue) {
    Set-Alias g git
}

# lazygit
if (Get-Command "lazygit" -ErrorAction SilentlyContinue) {
    Set-Alias lg lazygit
}

# nvim
if (Get-Command "nvim" -ErrorAction SilentlyContinue) {
    $env:NVIM_PROFILE='lite';
    Set-Alias v nvim

    function Set-Nvim-Profile($Mode, [switch] $NoOutput) {
        if ($Mode -imatch '^i.{0,2}$') {
            $env:NVIM_PROFILE='ide';
        } elseif ($Mode -imatch '^l.{0,3}$') {
            $env:NVIM_PROFILE='lite';
        } else {
            Write-Warning "Accepted values: '^i.{0,2}$',  '^l.{0,3}$'";
        }

        if (-not $NoOutput) {
            Write-Host "env:NVIM_PROFILE=$env:NVIM_PROFILE";
        }

        return;
    }

    function Start-Nvim-Ide  { $env:NVIM_PROFILE="ide"; nvim $Args }
    Set-Alias vide Start-Nvim-Ide

    function Start-Nvim-Lite { $env:NVIM_PROFILE="lite"; nvim $Args }
    Set-Alias vli Start-Nvim-Lite
}

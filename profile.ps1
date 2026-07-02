# vi:se et:

$Env:Editor='gvim'

# Yazi-related
function Set-YaziFileOneSetting() {
    # file.exe specify
    if (-not $IsWindows) {
        Write-Debug "Set-YaziFileOneSetting: OS is not Windwos. Skipping.";
        return; # abort when OS is not Windows
    }
    if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Debug "Set-YaziFileOneSetting: git is not found. Skipping.";
        return; # if git is not found, abort
    }

    $GitPath = Get-Command 'git' | Resolve-Path;
    $GitBase = $GitPath | Split-Path | Split-Path;
    $FileExe = Join-Path $GitBase 'usr/bin/file.exe';
    if (-not (Test-Path $FileExe)) {
        Write-Debug "Set-YaziFileOneSetting: file.exe is not found. Skipping.";
        return; # file.exe not found
    }

    $Env:YAZI_FILE_ONE = $FileExe
}

if (Get-Command 'yazi' -ErrorAction SilentlyContinue) {
    Set-YaziFileOneSetting

    function y {
        $tmp = (New-TemporaryFile).FullName
        yazi.exe @args --cwd-file="$tmp"
        $cwd = Get-Content -Path $tmp -Encoding UTF8
        if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
            Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
        }
        Remove-Item -Path $tmp
    }
}

if (Get-Command Enable-PsFzfAliases -ErrorAction SilentlyContinue) { Enable-PsFzfAliases }
# if (-not (Get-Module ZLocation)) { Install-Module -Name PSFzf -Scope CurrentUser }

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

function Edit-SshConfig () {
    if (Test-Path "$HOME\.ssh\config" -Type Leaf) {
        & $Env:editor "$HOME\.ssh\config"
    }
}
Set-Alias edssh Edit-SshConfig

if (Get-Command "git" -ErrorAction SilentlyContinue) {
    Set-Alias g git
}

if (Get-Command "lazygit" -ErrorAction SilentlyContinue) {
    Set-Alias lg lazygit
}

if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
    $OmpConf = "$HOME\.ompconf.json"
    if (Test-Path $OmpConf) {
        oh-my-posh init pwsh --config $OmpConf | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

if ((Get-Command "komorebic" -ErrorAction SilentlyContinue) -and (Get-Command "whkd" -ErrorAction SilentlyContinue)) {
    function Start-Komorebi-My {
        komorebic start --bar --whkd
    }
    function Stop-Komorebi-My {
        komorebic stop --bar --whkd
    }
}

if (Get-Command "nvim" -ErrorAction SilentlyContinue) {
    function Start-Nvim-Ide {
        $env:NVIM_PROFILE="ide"; nvim $Args
    }
    Set-Alias vide Start-Nvim-Ide

    function Start-Nvim-Lite {
        $env:NVIM_PROFILE="lite"; nvim $Args
    }
    Set-Alias v Start-Nvim-Lite
}


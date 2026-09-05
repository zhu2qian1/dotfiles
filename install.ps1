<#
.SYNOPSIS
    dotfiles symlink installer (Windows)

.DESCRIPTION
    Windows 専用設定ファイルを所定の場所へ symlink する。冪等。
    既存の実体/別リンクは <name>.bak に退避する。

    対象 (下の $Links を編集すれば増減できる):
      - .config\komorebi   -> $KOMOREBI_CONFIG_HOME (既定 ~\.config\komorebi)
      - .config\PowerShell -> ~\.config\PowerShell  (profile.ps1 の読み込み先)

    どちらもディレクトリ単位でリンクする。komorebi.json が
    $KOMOREBI_CONFIG_HOME/komorebi.bar.0.json のように配下を参照し、
    profile.ps1 が ~\.config\PowerShell\*.ps1 を dot-source するため、
    ファイル単位で並べるより実態に合う。

    profile.ps1 (本体は .config\PowerShell\profile.ps1) は PowerShell の
    エディションやホストで配置先 ($PROFILE) が変わるため、このスクリプトでは
    扱わない。末尾に現在の $PROFILE パスを表示するので、手動でリンクすること。

    シンボリックリンク作成には「開発者モード」有効化、または管理者権限が必要。

.EXAMPLE
    pwsh -File install.ps1
    pwsh -File install.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot

# komorebi の設定ホーム: 環境変数 KOMOREBI_CONFIG_HOME があればそれ、
# 無ければ ~\.config\komorebi (リポジトリの構成に合わせた既定)。
$KomorebiHome = if ($Env:KOMOREBI_CONFIG_HOME) {
    $Env:KOMOREBI_CONFIG_HOME
} else {
    Join-Path $HOME '.config\komorebi'
}

# source (リポジトリ内) -> target (配置先) の対応表。必要に応じて編集する。
$Links = [ordered]@{
    '.config\komorebi'   = $KomorebiHome
    '.config\PowerShell' = Join-Path $HOME '.config\PowerShell'
}

# パス比較用の正規化。ディレクトリの symlink は .Target が末尾 \ 付きで返るため、
# そのまま比較すると常に不一致になり、既存の正しいリンクを張り直してしまう。
function Get-NormalizedPath {
    param([string]$Path)
    [IO.Path]::GetFullPath($Path).TrimEnd('\')
}

# ディレクトリごとリンクするので、ホーム直下のような広い場所を target に
# 取らせない。KOMOREBI_CONFIG_HOME に旧構成の %USERPROFILE% が残っていると
# ホームごと .bak へ退避しかねないため。
$Forbidden = @($HOME, $Env:USERPROFILE) |
    Where-Object { $_ } |
    ForEach-Object { Get-NormalizedPath $_ }

function New-DotLink {
    param([string]$Source, [string]$Target)

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "  skip    source not found: $Source"
        return
    }

    if ($Forbidden -contains (Get-NormalizedPath $Target)) {
        Write-Warning "  REFUSE  target is a home directory, not linking: $Target"
        return
    }

    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    # .Target は PowerShell 5.1 では文字列コレクションで返るため 1 要素目を取る。
    if ($null -ne $item -and $item.LinkType -eq 'SymbolicLink' -and
        (Get-NormalizedPath (@($item.Target)[0])) -ieq (Get-NormalizedPath $Source)) {
        Write-Host "  ok      $Target"
        return
    }

    if ($null -ne $item) {
        Write-Host "  backup  $Target -> $Target.bak"
        if (-not $DryRun) { Move-Item -LiteralPath $Target -Destination "$Target.bak" -Force }
    }

    Write-Host "  link    $Target -> $Source"
    if (-not $DryRun) {
        $parent = Split-Path -Parent $Target
        if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
    }
}

Write-Host "dotfiles: $DotfilesDir  (dry-run=$DryRun)"

foreach ($name in $Links.Keys) {
    New-DotLink -Source (Join-Path $DotfilesDir $name) -Target $Links[$name]
}

Write-Host ''
if (-not $Env:KOMOREBI_CONFIG_HOME) {
    Write-Host 'KOMOREBI_CONFIG_HOME が未設定。komorebi.json は $KOMOREBI_CONFIG_HOME 配下を'
    Write-Host '参照するので、ユーザー環境変数に設定すること:'
    Write-Host "  [Environment]::SetEnvironmentVariable('KOMOREBI_CONFIG_HOME', '$KomorebiHome', 'User')"
    Write-Host ''
}
Write-Host 'profile.ps1 は手動でリンクすること (エディション/ホストで配置先が変わるため):'
Write-Host "  source : $(Join-Path $DotfilesDir '.config\PowerShell\profile.ps1')"
Write-Host "  target : $PROFILE"
Write-Host '  例: New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Join-Path $DotfilesDir ''.config\PowerShell\profile.ps1'') -Force'
Write-Host ''
Write-Host 'done.'

<#
.SYNOPSIS
    dotfiles symlink installer (Windows)

.DESCRIPTION
    Windows 専用設定ファイルを所定の場所へ symlink する。冪等。
    既存の実体/別リンクは <name>.bak に退避する。

    対象 (下の $Links を編集すれば増減できる):
      - komorebi.json / komorebi.bar.json / applications.json -> komorebi の設定ホーム

    profile.ps1 は OneDrive の有無で配置先 ($PROFILE) が変わるため、このスクリプトでは
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

# komorebi の設定ホーム: 環境変数 KOMOREBI_CONFIG_HOME があればそれ、無ければ %USERPROFILE%
$KomorebiHome = if ($Env:KOMOREBI_CONFIG_HOME) { $Env:KOMOREBI_CONFIG_HOME } else { $Env:USERPROFILE }

# source (リポジトリ内) -> target (配置先) の対応表。必要に応じて編集する。
$Links = [ordered]@{
    'komorebi.json'     = Join-Path $KomorebiHome 'komorebi.json'
    'komorebi.bar.json' = Join-Path $KomorebiHome 'komorebi.bar.json'
    'applications.json' = Join-Path $KomorebiHome 'applications.json'
    # 'profile.ps1'     = $PROFILE   # OneDrive 有無で変わるため手動 (下部の案内参照)
}

function New-DotLink {
    param([string]$Source, [string]$Target)

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "  skip    source not found: $Source"
        return
    }

    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($null -ne $item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Source) {
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
Write-Host 'profile.ps1 は手動でリンクすること (OneDrive 有無で配置先が変わるため):'
Write-Host "  source : $(Join-Path $DotfilesDir 'profile.ps1')"
Write-Host "  target : $PROFILE"
Write-Host '  例: New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Join-Path $DotfilesDir ''profile.ps1'') -Force'
Write-Host ''
Write-Host 'done.'
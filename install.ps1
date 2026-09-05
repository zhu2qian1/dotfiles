<#
.SYNOPSIS
    dotfiles symlink installer (Windows)

.DESCRIPTION
    Windows 専用設定ファイルを所定の場所へ symlink する。冪等。
    既存の実体/別リンクは <name>.bak (既にあれば <name>.bk-<日時>) に退避する。

    対象 (下の $Links を編集すれば増減できる):
      - .config\komorebi   -> $KOMOREBI_CONFIG_HOME (既定 ~\.config\komorebi)
      - .config\PowerShell -> ~\.config\PowerShell  (profile.ps1 の読み込み先)

    どちらもディレクトリ単位でリンクする。komorebi.json が
    $KOMOREBI_CONFIG_HOME/komorebi.bar.0.json のように配下を参照し、
    profile.ps1 が ~\.config\PowerShell\*.ps1 を dot-source するため、
    ファイル単位で並べるより実態に合う。

    プロファイルは PowerShell 7+ / Windows PowerShell 5.1 の CurrentUserAllHosts に
    dot-source 1 行の stub を追記する (symlink は張らない)。本体は
    .config\PowerShell\profile.ps1 の 1 箇所。

    シンボリックリンク作成には「開発者モード」有効化、または管理者権限が必要。

.EXAMPLE
    pwsh -File install.ps1
    pwsh -File install.ps1 -DryRun
    pwsh -File install.ps1 -Doctor
#>
[CmdletBinding()]
param(
    [switch]$DryRun,

    # 何も変更せず、リンク・プロファイル・ツールの状態だけ報告する。
    [switch]$Doctor,

    # 配置先のルート。既定は $HOME で、通常は指定しない。テストのために
    # 一時ディレクトリを渡せるようにしてある ($HOME は自動変数なので
    # $env:HOME を書き換えても変わらず、環境変数では差し替えられない)。
    [string]$TargetRoot = $HOME
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot

# komorebi の設定ホーム: 環境変数 KOMOREBI_CONFIG_HOME があればそれ、
# 無ければ <TargetRoot>\.config\komorebi (リポジトリの構成に合わせた既定)。
# -TargetRoot を明示したときは、テストが実環境の環境変数に引きずられない
# よう KOMOREBI_CONFIG_HOME を見ない。
$KomorebiHome = if ($Env:KOMOREBI_CONFIG_HOME -and -not $PSBoundParameters.ContainsKey('TargetRoot')) {
    $Env:KOMOREBI_CONFIG_HOME
} else {
    Join-Path $TargetRoot '.config\komorebi'
}

# source (リポジトリ内) -> target (配置先) の対応表。必要に応じて編集する。
$Links = [ordered]@{
    # ~\.config 配下 (Windows で使うものだけ。bash / zellij / lazygit は
    # WSL 側で使うので install.sh が扱う)
    '.config\komorebi'   = $KomorebiHome
    '.config\PowerShell' = Join-Path $TargetRoot '.config\PowerShell'
    '.config\nvim'       = Join-Path $TargetRoot '.config\nvim'
    '.config\starship'   = Join-Path $TargetRoot '.config\starship'
    '.config\yazi'       = Join-Path $TargetRoot '.config\yazi'
    '.config\whkdrc'     = Join-Path $TargetRoot '.config\whkdrc'

    # ~ 直下
    '.vimrc'             = Join-Path $TargetRoot '.vimrc'
    '.gvimrc'            = Join-Path $TargetRoot '.gvimrc'
    '.wezterm.lua'       = Join-Path $TargetRoot '.wezterm.lua'
    '.psmux.conf'        = Join-Path $TargetRoot '.psmux.conf'
}

# プロファイルは symlink ではなく dot-source 1 行の stub を置く。$PROFILE は
# OneDrive のリダイレクトを解決済みだが、配置先は PowerShell 7+ と Windows
# PowerShell 5.1 で分かれる。stub なら両方に置いても中身は .config\PowerShell
# の 1 箇所で済み、symlink の権限も要らない。
$ProfileStub = '. $HOME\.config\PowerShell\profile.ps1'

$Documents = [Environment]::GetFolderPath('MyDocuments')
$ProfilePaths = [ordered]@{
    'PowerShell 7+'          = Join-Path $Documents 'PowerShell\profile.ps1'
    'Windows PowerShell 5.1' = Join-Path $Documents 'WindowsPowerShell\profile.ps1'
}

# パス比較用の正規化。ディレクトリの symlink は .Target が末尾 \ 付きで返るため、
# そのまま比較すると常に不一致になり、既存の正しいリンクを張り直してしまう。
# 手で張られた相対リンク (例 .\dotfiles\.vimrc) はリンク自身の位置が基準なので、
# プロセスの作業ディレクトリで解決しないよう -BaseDirectory を渡す。
function Get-NormalizedPath {
    param([string]$Path, [string]$BaseDirectory)

    if ($BaseDirectory -and -not [IO.Path]::IsPathRooted($Path)) {
        $Path = Join-Path $BaseDirectory $Path
    }
    [IO.Path]::GetFullPath($Path).TrimEnd('\')
}

# 退避先。既存の <name>.bak を上書きすると前回の退避を失うので、既にあれば
# 日時付きの <name>.bk-yyyyMMddHHmmss に逃がす。
function Get-BackupPath {
    param([string]$Target)
    $bak = "$Target.bak"
    if ($null -eq (Get-Item -LiteralPath $bak -Force -ErrorAction SilentlyContinue)) { return $bak }
    "$Target.bk-$(Get-Date -Format 'yyyyMMddHHmmss')"
}

# symlink を作れる状態か。管理者権限があるか、開発者モードが有効なら作れる。
# 事前に確認しないと、退避だけ済んで link で権限エラー、という中途半端な
# 状態で止まる。
function Test-SymlinkAllowed {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { return $true }

    $unlockKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    $unlock = Get-ItemProperty -Path $unlockKey -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
    ($null -ne $unlock) -and ($unlock.AllowDevelopmentWithoutDevLicense -eq 1)
}

# ディレクトリごとリンクするので、ホーム直下のような広い場所を target に
# 取らせない。KOMOREBI_CONFIG_HOME に旧構成の %USERPROFILE% が残っていると
# ホームごと .bak へ退避しかねないため。
$Forbidden = @($TargetRoot, $HOME, $Env:USERPROFILE) |
    Where-Object { $_ } |
    ForEach-Object { Get-NormalizedPath $_ }

# 処理できなかった項目数。1 件でもあれば終了コード 1 で終わる。リンク対象の
# 消滅のような不整合が、成功扱いのまま見過ごされないようにするため。
$Failures = 0

# リンクの状態: nosource / refuse / ok / missing / conflict。install と doctor で
# 同じ判定を使うため切り出してある。
function Get-LinkState {
    param([string]$Source, [string]$Target)

    if (-not (Test-Path -LiteralPath $Source)) { return 'nosource' }
    if ($Forbidden -contains (Get-NormalizedPath $Target)) { return 'refuse' }

    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return 'missing' }

    # .Target は PowerShell 5.1 では文字列コレクションで返るため 1 要素目を取る。
    $linked = Get-NormalizedPath (@($item.Target)[0]) -BaseDirectory (Split-Path -Parent $Target)
    if ($item.LinkType -eq 'SymbolicLink' -and $linked -ieq (Get-NormalizedPath $Source)) { return 'ok' }

    'conflict'
}

function New-DotLink {
    param([string]$Source, [string]$Target)

    switch (Get-LinkState -Source $Source -Target $Target) {
        'nosource' {
            Write-Warning "  skip    source not found: $Source"
            $script:Failures++
            return
        }
        'refuse' {
            Write-Warning "  REFUSE  target is a home directory, not linking: $Target"
            $script:Failures++
            return
        }
        'ok' {
            Write-Host "  ok      $Target"
            return
        }
    }

    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue

    # 退避と作成をまとめて try で囲む。途中で落ちたときに、退避だけ済んで
    # 設定が消えたように見える状態を残さないため。
    $bak = $null
    try {
        if ($null -ne $item) {
            $bak = Get-BackupPath $Target
            Write-Host "  backup  $Target -> $bak"
            if (-not $DryRun) { Move-Item -LiteralPath $Target -Destination $bak -Force }
        }

        Write-Host "  link    $Target -> $Source"
        if (-not $DryRun) {
            $parent = Split-Path -Parent $Target
            if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        }
    } catch {
        Write-Warning "  FAIL    $Target : $($_.Exception.Message)"
        # 退避が済んでいて target が空いているときだけ戻す。
        $bakItem = if ($null -ne $bak) { Get-Item -LiteralPath $bak -Force -ErrorAction SilentlyContinue } else { $null }
        $targetItem = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
        if ($null -ne $bakItem -and $null -eq $targetItem) {
            Move-Item -LiteralPath $bak -Destination $Target -Force
            Write-Warning "  restore $bak -> $Target"
        }
        $script:Failures++
    }
}

# 既に stub があれば何もしない。無ければ末尾に 1 行足す。プロファイルは
# 他のツール (starship, conda 等) も書き込む場所なので、退避せず追記する。
function Install-ProfileStub {
    param([string]$Path)

    $content = if (Test-Path -LiteralPath $Path) { Get-Content -LiteralPath $Path -Raw } else { '' }
    if ($null -eq $content) { $content = '' }

    if ($content -like "*$ProfileStub*") {
        Write-Host "  ok      $Path"
        return
    }

    Write-Host "  append  $Path"
    if ($DryRun) { return }
    try {
        $parent = Split-Path -Parent $Path
        if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        if ($content -ne '' -and -not $content.EndsWith([Environment]::NewLine)) { Add-Content -LiteralPath $Path -Value '' -Encoding utf8 }
        Add-Content -LiteralPath $Path -Value $ProfileStub -Encoding utf8
    } catch {
        Write-Warning "  FAIL    $Path : $($_.Exception.Message)"
        $script:Failures++
    }
}

# 読み取り専用のレポート。何も変更しない (install.sh --doctor の Windows 版)。
function Invoke-Doctor {
    Write-Host '== symlinks =='
    foreach ($name in $Links.Keys) {
        $target = $Links[$name]
        $source = Join-Path $DotfilesDir $name
        switch (Get-LinkState -Source $source -Target $target) {
            'ok'       { Write-Host "  ok       $target" }
            'missing'  { Write-Warning "  MISSING  $target"; $script:Failures++ }
            'conflict' { Write-Warning "  CONFLICT $target (not our link)"; $script:Failures++ }
            'refuse'   { Write-Warning "  REFUSE   $target (home directory)"; $script:Failures++ }
            'nosource' { Write-Warning "  NOSOURCE $source"; $script:Failures++ }
        }
    }

    Write-Host ''
    Write-Host '== profile =='
    foreach ($edition in $ProfilePaths.Keys) {
        $path = $ProfilePaths[$edition]
        $content = if (Test-Path -LiteralPath $path) { Get-Content -LiteralPath $path -Raw } else { $null }
        if ($null -ne $content -and $content -like "*$ProfileStub*") {
            Write-Host "  ok       $path"
        } elseif ($edition -eq 'Windows PowerShell 5.1' -and -not (Test-Path -LiteralPath (Split-Path -Parent $path))) {
            Write-Host "  -        $edition は未使用"
        } else {
            Write-Warning "  MISSING  $path に stub が無い"
            $script:Failures++
        }
    }

    Write-Host ''
    Write-Host '== komorebi =='
    if (-not $Env:KOMOREBI_CONFIG_HOME) {
        Write-Warning '  MISSING  KOMOREBI_CONFIG_HOME が未設定'
        $script:Failures++
    } elseif ((Get-NormalizedPath $Env:KOMOREBI_CONFIG_HOME) -ieq (Get-NormalizedPath $KomorebiHome)) {
        Write-Host "  ok       KOMOREBI_CONFIG_HOME = $Env:KOMOREBI_CONFIG_HOME"
    } else {
        Write-Warning "  WARN     KOMOREBI_CONFIG_HOME がリンク先と違う: $Env:KOMOREBI_CONFIG_HOME"
    }

    Write-Host ''
    Write-Host '== symlink 権限 =='
    if (Test-SymlinkAllowed) {
        Write-Host '  ok       symlink を作成できる'
    } else {
        Write-Warning '  MISSING  開発者モードも管理者権限も無い'
        $script:Failures++
    }

    Write-Host ''
    Write-Host '== tools =='
    $required = @('git', 'pwsh')
    $optional = @('nvim', 'komorebic', 'whkd', 'starship', 'yazi', 'fzf', 'zoxide', 'eza', 'bat', 'rg', 'fd', 'lazygit', 'delta')
    foreach ($tool in $required) {
        $cmd = Get-Command $tool -ErrorAction SilentlyContinue
        if ($cmd) { Write-Host ('  ok       {0,-10} {1}' -f $tool, $cmd.Source) }
        else { Write-Warning ('  MISSING  {0,-10} (required)' -f $tool); $script:Failures++ }
    }
    foreach ($tool in $optional) {
        $cmd = Get-Command $tool -ErrorAction SilentlyContinue
        if ($cmd) { Write-Host ('  ok       {0,-10} {1}' -f $tool, $cmd.Source) }
        else { Write-Host ('  -        {0,-10} (optional)' -f $tool) }
    }

    Write-Host ''
    if ($Failures -eq 0) { Write-Host 'doctor: all good.' }
    else { Write-Warning "doctor: $Failures 件の問題あり (上を参照)" }
}

if ($Doctor) {
    Invoke-Doctor
    exit ($(if ($Failures -gt 0) { 1 } else { 0 }))
}

if (-not (Test-SymlinkAllowed)) {
    Write-Warning 'シンボリックリンクを作成できない。次のいずれかが必要:'
    Write-Warning '  - 開発者モードを有効にする (設定 > システム > 開発者向け)'
    Write-Warning '  - 管理者権限の PowerShell で実行する'
    if (-not $DryRun) { exit 1 }
    Write-Warning '  (-DryRun なので続行する)'
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
# 5.1 側はディレクトリがある環境だけ (使っていない環境に空の階層を作らない)。
foreach ($edition in $ProfilePaths.Keys) {
    $path = $ProfilePaths[$edition]
    if ($edition -eq 'Windows PowerShell 5.1' -and -not (Test-Path -LiteralPath (Split-Path -Parent $path))) {
        Write-Host "  -       $edition は未使用のため skip"
        continue
    }
    Install-ProfileStub -Path $path
}

Write-Host ''
if ($Failures -gt 0) {
    Write-Warning "done with $Failures problem(s) -- 上の skip / REFUSE を確認すること。"
    exit 1
}
Write-Host 'done.'

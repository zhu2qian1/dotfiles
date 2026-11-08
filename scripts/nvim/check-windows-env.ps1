<#
.SYNOPSIS
    Windows で dotfiles の Neovim 設定が必要とする環境が揃っているか調べる

.DESCRIPTION
    何も変更しない。結果を表示し、必須項目が欠けていれば終了コード 1 を返す。

      1. Neovim 本体     : バージョン、設定ディレクトリが dotfiles を指しているか
      2. 共通            : git (lazy.nvim の取得) / curl / tar
      3. tree-sitter     : CLI のバージョン・npm の shim でないか / C コンパイラ /
                           ビルド済みパーサ (IDE プロファイル)
      4. 任意のツール    : mason が LSP サーバを入れるのに使うランタイム、
                           telescope / lazygit / yazi / claudecode.nvim / IME 切替

    手順と、各項目がなぜ要るかは doc\nvim-treesitter-windows.md を参照。
    install.ps1 -Doctor はツールの有無しか見ないが、こちらはバージョンと
    「実際に動くか」まで確かめる。

.EXAMPLE
    pwsh -File scripts\nvim\check-windows-env.ps1
    powershell -File scripts\nvim\check-windows-env.ps1   # Windows PowerShell 5.1 でも動く
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 最低バージョン。
#   Neovim      : lua/ide/plugins/lsp.lua が 0.12 の vim.lsp.config / vim.lsp.enable 前提。
#   tree-sitter : nvim-treesitter main の README に合わせる (install-extra-tools.sh の
#                 TREE_SITTER_MIN と揃えること)。
$NvimMin       = [version]'0.12.0'
$TreeSitterMin = [version]'0.26.1'

$DotfilesDir = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$TreesitterSpec = Join-Path $DotfilesDir '.config\nvim\lua\ide\plugins\treesitter.lua'

$script:Failures = 0

function Write-Ok($name, $msg)      { Write-Host ('  ok       {0,-12} {1}' -f $name, $msg) }
function Write-Info($name, $msg)    { Write-Host ('  -        {0,-12} {1}' -f $name, $msg) }
function Write-Warn($name, $msg)    { Write-Warning ('  WARN     {0,-12} {1}' -f $name, $msg) }
function Write-Missing($name, $msg) { Write-Warning ('  MISSING  {0,-12} {1}' -f $name, $msg); $script:Failures++ }
function Write-Hint($msg)           { Write-Host ('           {0,-12} -> {1}' -f '', $msg) }

# テキストから最初の x.y.z を [version] で返す。"NVIM v0.12.0-dev-12+gabc" や
# "tree-sitter 0.26.3 (1a2b3c)" のように前後に余計なものが付くので正規表現で拾う。
function Get-Version([string]$text) {
    if ($text -match '(\d+)\.(\d+)\.(\d+)') {
        return [version]("{0}.{1}.{2}" -f $Matches[1], $Matches[2], $Matches[3])
    }
    return $null
}

# ネイティブコマンドを実行して stdout+stderr を 1 本の文字列で返す。起動に失敗したら
# $null。$ErrorActionPreference = 'Stop' のままだと、5.1 では stderr への出力
# (java -version など) が NativeCommandError として例外になるので局所的に緩める。
function Invoke-Capture([string]$exe, [string[]]$arguments) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $exe @arguments 2>&1 | ForEach-Object { "$_" }
        return [pscustomobject]@{ Code = $LASTEXITCODE; Text = ($out -join "`n") }
    } catch {
        return $null
    } finally {
        $ErrorActionPreference = $prev
    }
}

function Get-Exe([string]$name) {
    return Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
}

# ---------------------------------------------------------------------------
Write-Host "dotfiles: $DotfilesDir"
Write-Host ''
Write-Host '== Neovim =='

$nvim = Get-Exe 'nvim'
$NvimPaths = $null
if (-not $nvim) {
    Write-Missing 'nvim' '(required)'
    Write-Hint 'winget install Neovim.Neovim'
} else {
    $res = Invoke-Capture $nvim.Source @('--version')
    $ver = if ($res) { Get-Version $res.Text } else { $null }
    if (-not $ver) {
        Write-Missing 'nvim' "バージョンを読めない: $($nvim.Source)"
    } elseif ($ver -lt $NvimMin) {
        Write-Missing 'nvim' "$ver < $NvimMin ($($nvim.Source))"
    } else {
        Write-Ok 'nvim' "$ver  $($nvim.Source)"
    }

    # 設定・データの置き場所は nvim 自身に聞く。Windows の既定は
    # %LOCALAPPDATA%\nvim だが、install.ps1 は ~\.config\nvim にリンクするので
    # XDG_CONFIG_HOME などで向きを変えていないと dotfiles の設定が読まれない。
    # -u NONE で設定を読まずに stdpath() だけを出力させる。
    $lua = "lua io.stdout:write(vim.fn.stdpath('config') .. '\n' .. vim.fn.stdpath('data'))"
    $res = Invoke-Capture $nvim.Source @('--headless', '-u', 'NONE', '-i', 'NONE', '--cmd', $lua, '--cmd', 'qa!')
    if ($res -and $res.Code -eq 0) {
        $lines = @($res.Text -split "`r?`n" | Where-Object { $_ })
        if ($lines.Count -ge 2) {
            $NvimPaths = [pscustomobject]@{ Config = $lines[0]; Data = $lines[1] }
        }
    }
    if (-not $NvimPaths) {
        Write-Warn 'stdpath' 'nvim --headless から stdpath() を取れなかった'
    } else {
        $expected = Join-Path $HOME '.config\nvim'
        $marker = Join-Path $NvimPaths.Config 'lua\ide\plugins\treesitter.lua'
        if (Test-Path -LiteralPath $marker) {
            Write-Ok 'config' $NvimPaths.Config
        } else {
            Write-Missing 'config' "$($NvimPaths.Config) に dotfiles の設定が無い"
            if (Test-Path -LiteralPath (Join-Path $expected 'init.lua')) {
                Write-Hint "設定は $expected にある。XDG_CONFIG_HOME=$HOME\.config をユーザー環境変数に設定する"
            } else {
                Write-Hint 'pwsh -File install.ps1 で ~\.config\nvim をリンクする'
            }
        }
        Write-Info 'data' $NvimPaths.Data
    }

    if ($Env:NVIM_APPNAME) {
        Write-Warn 'NVIM_APPNAME' "$Env:NVIM_APPNAME が設定されている (設定ディレクトリ名が変わる)"
    }
    $profileName = if ($Env:NVIM_PROFILE) { $Env:NVIM_PROFILE } else { '(未設定 = lite)' }
    Write-Info 'NVIM_PROFILE' "$profileName  IDE プロファイルは vide / NVIM_PROFILE=ide"
}

# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '== 共通 (lazy.nvim / nvim-treesitter / mason) =='

$git = Get-Exe 'git'
if ($git) { Write-Ok 'git' $git.Source }
else { Write-Missing 'git' '(required) lazy.nvim とプラグインの取得に使う'; Write-Hint 'winget install Git.Git' }

$curl = Get-Exe 'curl'
if ($curl) { Write-Ok 'curl' $curl.Source }
else { Write-Missing 'curl' '(required) nvim-treesitter がパーサのソースを落とすのに使う' }

# Git for Windows / MSYS2 の GNU tar が System32 の bsdtar より先に見つかると、
# GNU tar は "C:\..." の "C:" をリモートホストと解釈して展開に失敗する。
$tar = Get-Exe 'tar'
if (-not $tar) {
    Write-Missing 'tar' '(required) nvim-treesitter がパーサのソースを展開するのに使う'
} else {
    $res = Invoke-Capture $tar.Source @('--version')
    if ($res -and $res.Text -match 'GNU tar') {
        Write-Warn 'tar' "GNU tar が先に見つかる: $($tar.Source)"
        Write-Hint 'C:\Windows\System32 が先に来るよう PATH を並べ替える (C: をホスト名と解釈して失敗する)'
    } else {
        Write-Ok 'tar' $tar.Source
    }
}

# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '== tree-sitter (IDE プロファイル) =='

# npm 版は tree-sitter.cmd / .ps1 の shim で、本体の tree-sitter.exe を落とし損ねても
# shim だけ残る。nvim-treesitter は npm 版に非対応なので、PATH 上の候補を全部見て
# shim が先に来ていないかも確かめる。
$tsAll = @(Get-Command 'tree-sitter' -All -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandType -in 'Application', 'ExternalScript' })
if ($tsAll.Count -eq 0) {
    Write-Missing 'tree-sitter' "(required) CLI $TreeSitterMin 以降"
    Write-Hint 'doc\nvim-treesitter-windows.md の「1. tree-sitter CLI」'
} else {
    $ts = $tsAll[0]
    $isShim = ($ts.Source -notmatch '\.exe$') -or ($ts.Source -match '\\node_modules\\|\\npm\\')
    $res = Invoke-Capture $ts.Source @('--version')
    $ver = if ($res -and $res.Code -eq 0) { Get-Version $res.Text } else { $null }
    if ($isShim) {
        Write-Missing 'tree-sitter' "npm の shim が使われる: $($ts.Source)"
        Write-Hint 'npm rm -g tree-sitter-cli して GitHub release の tree-sitter.exe を入れる'
    } elseif (-not $ver) {
        Write-Missing 'tree-sitter' "--version が失敗する: $($ts.Source)"
    } elseif ($ver -lt $TreeSitterMin) {
        Write-Missing 'tree-sitter' "$ver < $TreeSitterMin ($($ts.Source))"
    } else {
        Write-Ok 'tree-sitter' "$ver  $($ts.Source)"
    }
    foreach ($other in $tsAll | Select-Object -Skip 1) {
        Write-Info '' "(PATH の後ろにもある: $($other.Source))"
    }
}

# C コンパイラ。tree-sitter build は $CC があればそれを、無ければ MSVC の cl.exe を
# vswhere で探して使う。treesitter.lua の事前チェックは vswhere.exe の存在しか
# 見ないので、ここでは C++ ワークロードと Windows SDK まで確かめる。
if ($Env:CC) {
    $ccName = ($Env:CC -split '\s+' | Where-Object { $_ } | Select-Object -First 1)
    $cc = Get-Exe $ccName
    if ($cc) { Write-Ok 'CC' "$Env:CC  ($($cc.Source))" }
    else { Write-Missing 'CC' "`$env:CC = '$Env:CC' だが $ccName が PATH に無い" }
} else {
    $vswhere = Join-Path ${Env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    $vcComponent = if ($Env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
        'Microsoft.VisualStudio.Component.VC.Tools.ARM64'
    } else {
        'Microsoft.VisualStudio.Component.VC.Tools.x86.x64'
    }
    $vsPath = $null
    if (Test-Path -LiteralPath $vswhere) {
        $res = Invoke-Capture $vswhere @('-latest', '-products', '*', '-requires', $vcComponent, '-property', 'installationPath')
        if ($res -and $res.Code -eq 0 -and $res.Text.Trim()) { $vsPath = $res.Text.Trim() }
    }
    $cl = Get-Exe 'cl'
    if ($vsPath) {
        Write-Ok 'MSVC' $vsPath
    } elseif ($cl) {
        Write-Ok 'MSVC' "cl.exe on PATH: $($cl.Source)"
    } elseif (Test-Path -LiteralPath $vswhere) {
        Write-Missing 'MSVC' 'Visual Studio Installer はあるが C++ ビルドツールが無い'
        Write-Hint 'Installer の「変更」で「C++ によるデスクトップ開発」を追加する'
    } else {
        Write-Missing 'MSVC' 'C コンパイラが無い ($env:CC も未設定)'
        Write-Hint 'doc\nvim-treesitter-windows.md の「2. C コンパイラ」'
    }

    # cl.exe があっても SDK が無いと stdio.h が見つからずにビルドが失敗する。
    if ($vsPath -or $cl) {
        $kits = Join-Path ${Env:ProgramFiles(x86)} 'Windows Kits\10\Include'
        $sdk = $null
        if (Test-Path -LiteralPath $kits) {
            $sdk = Get-ChildItem -LiteralPath $kits -Directory |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'ucrt\stdio.h') } |
                Sort-Object Name -Descending | Select-Object -First 1
        }
        if ($sdk) { Write-Ok 'Windows SDK' $sdk.Name }
        else { Write-Missing 'Windows SDK' 'ucrt\stdio.h が無い。Installer から Windows SDK を追加する' }
    }
}

# ビルド済みパーサ。対象言語は treesitter.lua の `local langs = { ... }` から読む
# (ここに二重に書くとずれるため)。
if ($NvimPaths -and (Test-Path -LiteralPath $TreesitterSpec)) {
    $spec = Get-Content -LiteralPath $TreesitterSpec -Raw -Encoding UTF8
    if ($spec -match 'local langs = \{([^}]*)\}') {
        $langs = @([regex]::Matches($Matches[1], "'([^']+)'") | ForEach-Object { $_.Groups[1].Value })
        $parserDir = Join-Path $NvimPaths.Data 'site\parser'
        # 拡張子は nvim-treesitter の版によって .so / .dll があり得るので問わない
        $missing = @($langs | Where-Object { -not (Test-Path -Path (Join-Path $parserDir "$_.*")) })
        if ($missing.Count -eq 0) {
            Write-Ok 'parsers' "$($langs.Count) 個すべてビルド済み ($parserDir)"
        } else {
            # 道具が揃っていれば次の IDE 起動で入るので失敗には数えない
            Write-Warn 'parsers' "未ビルド: $($missing -join ', ')"
            Write-Hint '上が揃っていれば vide の次回起動でビルドされる (:checkhealth nvim-treesitter)'
        }
    }
}

# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '== 任意 (無ければその機能だけ動かない) =='

# 名前, 用途。mason は LSP サーバをこれらのランタイム経由で入れるので、無いと
# 該当サーバのインストールだけが失敗する (lua/ide/plugins/lsp.lua の servers)。
$optional = @(
    @('node',     'mason: ts_ls / jsonls / yamlls / pyright / emmet_language_server'),
    @('npm',      'mason: 同上 (npm パッケージとして入れる)'),
    @('go',       'mason: gopls / delve (go install で入れる)'),
    @('java',     'mason: jdtls (JDK 21 以降)'),
    @('python',   'mason: ruff (pypi パッケージとして入れる)'),
    @('make',     'telescope-fzf-native のビルド (無ければ使わない)'),
    @('rg',       'telescope live_grep / grep_string'),
    @('fd',       'telescope find_files の高速化'),
    @('lazygit',  'snacks.nvim の lazygit (<leader>gg)'),
    @('yazi',     'yazi.nvim (<leader>ey)'),
    @('claude',   'claudecode.nvim (<leader>ac)'),
    @('zenhan',   'InsertLeave で IME をオフにする (lua/config/platform.lua)')
)
foreach ($item in $optional) {
    $name, $purpose = $item
    $cmd = Get-Exe $name
    if (-not $cmd) {
        Write-Info $name "(無し) $purpose"
        continue
    }
    # python は Microsoft Store のエイリアス (WindowsApps\python.exe、実体 0 バイト) だと
    # 実行するとストアが開くだけで venv を作れない。
    if ($name -eq 'python' -and $cmd.Source -match '\\WindowsApps\\') {
        $res = Invoke-Capture $cmd.Source @('--version')
        if (-not $res -or $res.Code -ne 0 -or -not (Get-Version $res.Text)) {
            Write-Warn $name "Microsoft Store のエイリアスしか無い: $($cmd.Source)"
            Write-Hint '設定 > アプリ > アプリ実行エイリアス で無効にし、Python 本体を入れる'
            continue
        }
    }
    Write-Ok $name $cmd.Source
}

# ---------------------------------------------------------------------------
Write-Host ''
if ($script:Failures -eq 0) { Write-Host 'check: all good.' }
else { Write-Warning "check: $($script:Failures) 件の問題あり (上を参照)" }
exit ($(if ($script:Failures -gt 0) { 1 } else { 0 }))

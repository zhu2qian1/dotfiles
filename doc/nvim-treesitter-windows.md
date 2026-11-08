# Windows での Neovim tree-sitter セットアップ

IDE プロファイル (`NVIM_PROFILE=ide nvim`、PowerShell では `vide`) が使う
nvim-treesitter (main ブランチ) のパーサを Windows でビルドできるようにする手順。
設定の本体は `.config/nvim/lua/ide/plugins/treesitter.lua`、なぜ treesitter を
入れているかは README の "Neovim tree-sitter" 節を参照。

Linux / WSL では `bash install-extra-tools.sh` が tree-sitter CLI を入れるが、
`install.ps1` には相当する処理が無い。Windows では以下を手で揃える。
揃ったかどうかは次のスクリプトでまとめて確かめられる (何も変更しない):

```powershell
pwsh -File scripts\nvim\check-windows-env.ps1   # Windows PowerShell 5.1 でも動く
```

Neovim のバージョンと設定ディレクトリ、`git` / `curl` / `tar`、tree-sitter CLI
(バージョンと npm の shim でないか)、C コンパイラ (C++ ワークロードと Windows SDK
まで)、ビルド済みパーサ、mason が使うランタイム (node / go / java / python) などの
任意ツールを順に調べ、必須項目が欠けていれば終了コード 1 を返す。

## 必要なもの

nvim-treesitter の main ブランチはパーサを配布せず、手元でソースを落として
ビルドする。そのため次の 4 つが `nvim` から見える必要がある。

| もの | 条件 | Windows での入手先 |
| --- | --- | --- |
| Neovim | 0.12 以降 (`lsp.lua` が前提) | `winget install Neovim.Neovim` など |
| `curl` / `tar` | PATH 上にあること | Windows 10 1803 以降は `C:\Windows\System32` に同梱 |
| tree-sitter CLI | **0.26.1 以降**。npm 版は不可 | GitHub release のバイナリ (下記) |
| C コンパイラ | `cl.exe` (MSVC) か `$env:CC` で指定したもの | Visual Studio Build Tools (下記) |

足りないものがあると、IDE プロファイルの起動時に

```
tree-sitter CLI が動かないのでパーサを入れられない: svelte, typescript, ...
```

または `C コンパイラが無いので…` という警告が 1 行出て、パーサのビルドは
試みられない (起動自体は普通にできる)。

## 1. tree-sitter CLI

GitHub の [releases](https://github.com/tree-sitter/tree-sitter/releases) から
`tree-sitter-windows-x64.gz` (ARM なら `-arm64.gz`) を取り、展開した
`tree-sitter.exe` を PATH の通った場所に置く。`.gz` は tar アーカイブではなく
実行ファイルを単体で gzip したものなので、`tar -xf` では展開できない。
PowerShell だけで済ませるなら:

```powershell
$dir = Join-Path $env:LOCALAPPDATA 'Programs\tree-sitter'
New-Item -ItemType Directory -Force $dir | Out-Null
$gz  = Join-Path $env:TEMP 'tree-sitter-windows-x64.gz'
Invoke-WebRequest -Uri 'https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-windows-x64.gz' -OutFile $gz

$in  = [IO.File]::OpenRead($gz)
$out = [IO.File]::Create((Join-Path $dir 'tree-sitter.exe'))
try {
    $unzip = [IO.Compression.GZipStream]::new($in, [IO.Compression.CompressionMode]::Decompress)
    $unzip.CopyTo($out)
} finally { $out.Dispose(); $in.Dispose() }
Remove-Item $gz

# ユーザー PATH に追加 (未登録のときだけ)。反映は新しく開いたシェルから。
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $dir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
}
```

更新するときも同じ手順で上書きすればよい (nvim が起動していても CLI は掴まれて
いない)。

他の入れ方の注意:

- **npm (`npm i -g tree-sitter-cli`) は使わない**。nvim-treesitter が非対応なうえ、
  postinstall で本体の `tree-sitter.exe` を落とし損ねても `tree-sitter.cmd` の shim
  だけが残り、`executable('tree-sitter')` が真になってしまう。`treesitter.lua` が
  `tree-sitter --version` を実際に実行して判定しているのはこのため。
  既に入れてしまったなら `npm rm -g tree-sitter-cli` で消しておく (PATH 上で
  先に見つかると、正しく入れた方が使われない)。
- `cargo install --locked tree-sitter-cli` でも入る。ただしビルドに MSVC が要るので、
  次節の C コンパイラを先に入れることになる。
- scoop / winget のパッケージを使う場合は、入ったものが 0.26.1 以降かを
  `tree-sitter --version` で確かめること。

## 2. C コンパイラ

tree-sitter CLI はパーサを DLL にビルドするとき、`$env:CC` が設定されていれば
それを、無ければ MSVC の `cl.exe` を使う。`cl.exe` が PATH に無くても
(= Developer PowerShell から起動していなくても) Visual Studio の場所を
`vswhere.exe` で自分で探すので、普段のシェルからそのまま動く。

### MSVC (推奨)

Visual Studio 本体は要らない。Build Tools の C++ ワークロードだけ入れる:

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

既に Visual Studio / Build Tools があるなら、Visual Studio Installer の
「変更」から **「C++ によるデスクトップ開発」** (Build Tools では
「C++ Build Tools」) が入っているか確認する。

`treesitter.lua` の事前チェックは `cl` が PATH にあるか、`vswhere.exe` が存在するか
しか見ていない。Installer だけ入っていて C++ ワークロードが無い状態でもチェックは
通るので、その場合は警告ではなくビルドエラーとして表に出る
(後述の「トラブルシューティング」)。

### gcc / clang を使う場合

MinGW の gcc や LLVM の clang を使うなら、`CC` にそのコマンドを入れておく。
nvim はそれを起動したシェルの環境を引き継ぐので、ユーザー環境変数にするのが
確実:

```powershell
[Environment]::SetEnvironmentVariable('CC', 'clang', 'User')   # gcc なら 'gcc'
```

マシン固有の設定なので、dotfiles 側 (`.config/PowerShell/`) には書かない。
`treesitter.lua` は `$env:CC` を空白で区切った先頭語が実行できるかだけを確かめ、
`CC` が設定されていれば MSVC の有無は見ない。

## 3. ビルドと確認

1. **新しく開いた** PowerShell で道具が見えるか確かめる:

   ```powershell
   pwsh -File scripts\nvim\check-windows-env.ps1   # MISSING が無ければよい
   ```

2. IDE プロファイルで nvim を起動する (`vide`)。未インストールのパーサが
   バックグラウンドでビルドされる。初回は lazy.nvim によるプラグイン取得も
   重なるので数十秒かかる。
3. ビルドが終わったらバッファを開き直す (`:e`)。初回起動時はビルド完了前に
   `FileType` が来るので、そのとき開いていたバッファは従来のハイライトのまま。
4. `:checkhealth nvim-treesitter` で CLI のバージョン・コンパイラ・各パーサの
   状態を確認する。

パーサは `stdpath('data')/site/parser/` (既定では
`%LOCALAPPDATA%\nvim-data\site\parser\`) に置かれる。対象言語は
`treesitter.lua` の `langs` で、追加したら次回起動時に差分だけがビルドされる。
手動で入れ直すなら `:TSInstall! <lang>`、全体の更新は `:TSUpdate`
(lazy.nvim でプラグインを更新したときにも `build = ':TSUpdate'` で走る)。

## トラブルシューティング

**起動のたびに「tree-sitter CLI が動かない」と出る**
: nvim から見た PATH に `tree-sitter.exe` が無いか、npm の shim を掴んでいる。
  `:echo exepath('tree-sitter')` で実際に使われるパスを確かめる。PATH を
  変えた後は、nvim だけでなく親のターミナル (WezTerm など) も開き直す。

**「C コンパイラが無い」と出る**
: `$env:CC` を設定しているならその先頭語が PATH に無い。設定していないなら
  `cl.exe` も `vswhere.exe` も見つかっていない (Build Tools 未導入)。

**チェックは通るがビルドが失敗する (`cl.exe` や `link.exe` が見つからない、
`stdio.h` が無い など)**
: Visual Studio Installer はあるが C++ ワークロードか Windows SDK が無い。
  Installer から追加する。`:checkhealth nvim-treesitter` と `:messages` に
  コンパイラの出力が残る。

**ソースの展開で `tar` が失敗する (`Cannot connect to C: resolve failed` など)**
: PATH 上で Git for Windows / MSYS2 の GNU tar が `C:\Windows\System32\tar.exe`
  より先に見つかっている可能性がある。GNU tar は `C:` をリモートホスト指定と
  解釈する。`:echo exepath('tar')` で確認し、System32 の bsdtar が先に来るよう
  PATH の順序を直す。

**`:TSUpdate` でパーサの上書きに失敗する**
: Windows では読み込み中の DLL を上書きできない。そのパーサを使っている
  バッファを開いた nvim (他のウィンドウのものも含む) を全部閉じてから、
  新しい nvim で `:TSUpdate` をやり直す。

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリについて

個人の dotfiles。ビルド・テスト・lint のツールチェーンは無い。成果物は 2 つの
インストーラ (`install.sh` / `install.ps1`) と、それらが `$HOME` へ symlink する
設定ファイル群。**リポジトリのディレクトリ構成が `$HOME` の構成をそのまま写している**
のが基本設計で、トップレベルの dotfile は `~/<name>`、`.config/*` は `~/.config/<name>`
に対応する。

## 検証コマンド

変更後は必ず対応するインストーラの dry-run と doctor で確認する。どちらも
副作用が無い。

```sh
bash install.sh --dry-run     # 何が起きるかだけ表示
bash install.sh --doctor      # リンク状態 / シェル起動 / sudo / ツールの有無を報告

pwsh -File install.ps1 -DryRun
pwsh -File install.ps1 -Doctor
```

`install.ps1` は `-TargetRoot <dir>` で配置先を差し替えられる (`$HOME` は自動変数で
環境変数からは変えられないため、テスト用に用意されている引数)。一時ディレクトリを
渡せば実環境を壊さずにリンク処理を通しで試せる。`-TargetRoot` 指定時は
`KOMOREBI_CONFIG_HOME` を意図的に無視する。

シェル設定を触ったら `bash install.sh --doctor` の "shell startup" セクションを見る。
`~/.profile` が `sh` で動くこと・stdout に何も書かないこと (scp/rsync が壊れる) を
そこで検査している。

## インストーラの構造

2 つのインストーラは対象の選び方が対称になっていない。片方を変えたらもう片方の
扱いも確認すること。

- **`install.sh` (Linux/WSL) は除外リスト方式**。`IGNORE` 配列に無いトップレベル
  エントリを全部リンクする。新しい dotfile を足すと自動的に対象になる。
  `.config` と `.claude` はディレクトリごとではなくエントリ単位でリンクする
  (`~/.claude` には Claude Code 自身の state があるため)。
  `.config` 配下でも同じ問題を抱えるディレクトリは `CONFIG_PER_ENTRY` に列挙すると
  さらに一段掘り下げて中身だけをリンクする (`herdr` は config.toml の隣に API
  ソケット・ログ・`session.json` が置かれる)。
- **`install.ps1` (Windows) は許可リスト方式**。`$Links` (ordered hashtable) に
  書いたものだけを扱う。Windows で使う設定は WSL 側と重ならないので、
  `.config\{komorebi,PowerShell,nvim,starship,yazi,whkdrc}` と一部のトップレベル
  ファイルに限定してある。komorebi と PowerShell は配下を相対参照するので
  **ディレクトリ単位**でリンクする。herdr だけは `.config\herdr\config.toml` を
  `%APPDATA%\herdr\config.toml` (または `HERDR_CONFIG_PATH`) へ**ファイル単位**で
  リンクする — Windows では設定の置き場所が `~\.config` ではなく、そこに herdr 自身が
  ログと `session.json` を書くため。
- 既存の実体や別リンクは `<name>.bak` へ退避 (PowerShell 側は `.bak` が既にあれば
  `<name>.bk-<日時>`)。`*.bak` と `*.bk-*` は gitignore 済みで、リンク対象からも除外される。
- `install.ps1` はホーム直下など広すぎるパスを target に取ることを `$Forbidden` で
  拒否する。ディレクトリごとリンクするため、誤った `KOMOREBI_CONFIG_HOME` で
  ホームごと退避する事故を防ぐ目的。
- PowerShell プロファイルだけは symlink ではなく **dot-source 1 行の stub** を
  PowerShell 7+ / Windows PowerShell 5.1 の CurrentUserAllHosts プロファイルに追記する。
  本体は `.config\PowerShell\profile.ps1` の 1 箇所に集約する。

## シェル設定のレイヤ

`~/.profile` と `~/.bashrc` の役割分担がこの構成の要点:

- **`.profile`**: PATH・EDITOR・locale など**非対話シェルにも必要なもの**だけ。
  POSIX sh 互換を保つこと (dash で読まれる)。stdout に出力してはいけない。
- **`.bashrc`**: ローダーのみ。対話判定より前に `.profile` を拾う
  (`ssh host 'cmd'` は `.bashrc` を読むが `.profile` は読まないため)。
  二重読み込みは `DOTFILES_PROFILE_LOADED` / `DOTFILES_PROFILE_ATTEMPTED` で防ぐ。
- 実体は `.config/bash/` に分割。読み込み順は `[0-9]*.bash` (番号順) →
  `os/<os>.bash` → `host/<hostname>.bash` → `local.bash` (gitignore)。
  後勝ち。ファイルを置くだけで有効になり、無ければ黙って飛ばす。
  詳細は `.config/bash/README.md`。
- `local.bash` / `env_local.bash` は machine-local な秘密情報用でコミットしない。
  雛形は `local.bash.example`。

## Neovim

`init.lua` は `NVIM_PROFILE` で切り替わる 2 プロファイル構成:

- `lite` (既定): プラグイン無し。`lua/config/*` のみ読む。起動 1 秒未満。
- `ide` (`NVIM_PROFILE=ide nvim`): `lua/ide/` 配下で lazy.nvim をブートストラップし
  `lua/ide/plugins/*.lua` を spec として読む。lockfile も
  `lua/ide/lazy-lock.json` に隔離してあり、これは gitignore 済み。

`lua/config/*` は両プロファイル共通。プラグインに依存する設定を書かないこと。
`lua/config/platform.lua` に Windows / WSL / SSH+tmux でのクリップボード分岐が
まとまっており、なぜその実装なのかがコメントで詳述されている — 触る前に読むこと。

## Claude Code の設定

`.claude/skills/*` と `.claude/statusline.sh` はインストーラが `~/.claude/` 配下へ
エントリ単位でリンクする。`~/.claude/settings.json` は認証情報とマシン固有の状態を
含むため**追跡していない**。したがって statusline の有効化は手動:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## コミット規約

既存履歴に合わせる (`.claude/skills/commit-staged/SKILL.md` に詳細):

- 日本語。1 行サマリは 50 文字程度、末尾に句点は付けない。
- 単一ファイルに閉じる変更は `install.ps1: -Doctor を追加し README を実態に合わせる`
  のように `<ファイル名>: <要約>` 形式。
- README とインストーラの記述は乖離させない。リンク対象や挙動を変えたら
  `README.md` の該当箇所も同じコミットで直す (履歴上そうしている)。
- 特段の指示が無い限り `main` へ直接コミットしてよい (個人 dotfiles なので
  ブランチを切る必要は無い)。ブランチが要るときはユーザーがそう言う。

## 編集時の注意

- `.editorconfig`: LF・UTF-8・スペース 4・末尾空白除去 (Markdown は除く)。
  Windows 側のファイルでも CRLF にしない。
- `install.sh` は `set -euo pipefail`、`install.ps1` は `Set-StrictMode -Version Latest`
  と `$ErrorActionPreference = 'Stop'` で動く。
- 両スクリプトのコメントは「なぜそう書いてあるか」を残す形で書かれている
  (sudo の secure_path、`.profile` の stdout 制約、symlink の権限、パス正規化など)。
  同じ水準で書き足すこと。

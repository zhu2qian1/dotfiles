# Neovim

`init.lua` は `NVIM_PROFILE` で切り替わる 2 プロファイル構成:

- `lite` (既定): プラグイン無し。`lua/config/*` のみ読む。起動 1 秒未満。
- `ide` (`NVIM_PROFILE=ide nvim`): `lua/ide/` 配下で lazy.nvim をブートストラップし
  `lua/ide/plugins/*.lua` を spec として読む。lockfile も
  `lua/ide/lazy-lock.json` に隔離してあり、これは gitignore 済み。
  lite で起動した後に `:EnableIde` でも読める (既存バッファには `BufReadPre` /
  `FileType` を再発火して遅延読み込みを拾わせる)。`lua/ide/` 側の spec は起動後に
  setup されても動くように書くこと。

`lua/config/*` は両プロファイル共通。プラグインに依存する設定を書かないこと。
`lua/config/platform.lua` に Windows / WSL / SSH+tmux でのクリップボード分岐が
まとまっており、なぜその実装なのかがコメントで詳述されている — 触る前に読むこと。

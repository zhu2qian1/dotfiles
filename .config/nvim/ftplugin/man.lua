-- man ページのヘッダー/フッターが何行にも折り返る問題の回避 (buffer-local)
--
-- g:man_hardwrap = 0 とシェル側の MANWIDTH=999 により man は 999 桁で整形する。
-- nroff はヘッダー/フッターを左・中央・右へ両端揃えするので、`LS(1)` と
-- `User Commands` の間に数百個の空白が入り、ソフトラップで何行にも割れる。
--
-- 組み込みの man.lua も同じ問題を抱えていて、read_page() (`:Man` / `K` /
-- man:// の `:e`) では 199 個以上続く空白を 10 個に縮めている。ところが
-- $MANPAGER (`nvim +Man!`) から呼ばれる init_pager() はこの置換をしないので、
-- シェルから `man ls` したときだけヘッダーがズレ、`:e` で read_page() 経路に
-- 乗ると直る、という挙動になる。ここで同じ置換を当てて経路差を埋める。
--
-- init_pager() / read_page() とも最後に set_options() で filetype=man を
-- 設定するので、この ftplugin はバッファの中身が入った後に走る。read_page()
-- 経路では置換済みなので何もマッチせず無害。
local bo = vim.bo
local modifiable = bo.modifiable
-- :s はカーソルを最後に置換した行 (= フッター) へ動かす。keepjumps は
-- ジャンプリストを守るだけでカーソルは戻さないので、init_pager() /
-- read_page() が先頭に置いた位置をビューごと退避して戻す。
local view = vim.fn.winsaveview()
bo.modifiable = true
vim.cmd([[silent! keeppatterns keepjumps %s/\s\{199,}/\=repeat(' ', 10)/g]])
vim.fn.winrestview(view)
bo.modifiable = modifiable
-- 置換で立った modified を戻さないと、q (<C-W>q) で閉じるときに E37 になる
bo.modified = false

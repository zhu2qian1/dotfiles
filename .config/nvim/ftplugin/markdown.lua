-- General markdown settings (buffer-local)
vim.opt_local.conceallevel = 2
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

-- 見出し単位の fold。markdown パーサは Neovim 同梱なので lite プロファイルでも効く
-- (見出しのほかコードブロック・リストも fold になる)。foldmethod は window-local
-- なので、[0][0] (このウィンドウでこのバッファを表示している間) に限って設定し、
-- 同じウィンドウで別の filetype を開いたときに expr が残らないようにする。
-- foldlevel を上げておかないと、開いた直後に全部閉じた状態になる。
vim.wo[0][0].foldmethod = 'expr'
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldlevel = 99

-- todo.md specific keymaps
if vim.fn.expand("%:t"):lower() == "todo.md" then
  require("todo").setup(0)
end

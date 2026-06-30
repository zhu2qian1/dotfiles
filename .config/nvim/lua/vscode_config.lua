-- ============================================
-- VS Code (vscode-neovim) specific settings
-- ============================================
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.shortmess:append("a")
vim.opt.shortmess:append("A")
vim.opt.shortmess:append("s")
vim.opt.shortmess:append("m")
vim.opt.report = 999999
-- Undo/Redo 時のメッセージを抑制するためのハック
vim.api.nvim_create_autocmd({ "TextYankPost", "BufWritePost" }, {
    callback = function()
        vim.opt.report = 999999
    end,
})
vim.opt.cmdheight = 0

-- General markdown settings (buffer-local)
vim.opt_local.conceallevel = 2
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

-- todo.md specific keymaps
if vim.fn.expand("%:t"):lower() == "todo.md" then
  require("todo").setup(0)
end

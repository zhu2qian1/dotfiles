vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'default', 'cp932' }

-- Skip default settings
vim.g.vim_skip_defaults = 1

-- Leader key
vim.g.mapleader = " "

-- ============================================
-- Config modules (lua/config/*.lua)
-- ============================================
require('config.options')
require('config.autocmds')
require('config.commands')
require('config.keymaps')
require('config.platform')

if vim.g.vscode then
    require('vscode_config')
end

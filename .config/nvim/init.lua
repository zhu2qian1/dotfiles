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

-- ============================================
-- Profile switch
--   lite (default) : 軽量。プラグインなし。閲覧/quick memo 用 (<1s)
--   ide            : NVIM_PROFILE=ide nvim で起動。LSP/補完等を読む(起動遅延OK)
-- 共通設定(config/*)は上で常に読み込み済み。ここはIDE機能の追加のみ。
-- ============================================
local profile = vim.env.NVIM_PROFILE or 'lite'

if profile == 'ide' and not vim.g.vscode then
    require('ide')
end

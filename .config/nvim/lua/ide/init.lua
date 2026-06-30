-- ============================================
-- IDE profile entry point  (NVIM_PROFILE=ide)
-- lazy.nvim をブートストラップし、lua/ide/plugins/ 以下の spec を読み込む。
-- 起動時間より機能を優先するプロファイル。
-- ============================================

-- 1. lazy.nvim を自動取得 (初回のみ git clone)
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local repo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({
        'git', 'clone', '--filter=blob:none', '--branch=stable', repo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
        }, true, {})
        return
    end
end
vim.opt.rtp:prepend(lazypath)

-- 2. プラグイン読み込み (lua/ide/plugins/*.lua を spec として展開)
require('lazy').setup({
    spec = {
        { import = 'ide.plugins' },
    },
    -- lockfile も IDE プロファイル配下に隔離しておく
    lockfile = vim.fn.stdpath('config') .. '/lua/ide/lazy-lock.json',
    install = { colorscheme = { 'desert' } },
    change_detection = { notify = false },
})

-- 3. IDE プロファイル専用の追加 keymap / setting はここに
--    (lite と共通のものは config/keymaps.lua へ)
require('ide.config')

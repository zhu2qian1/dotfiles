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
--                    lite で起動した後に :EnableIde でも読める (無効化は不可、戻すなら再起動)
-- 共通設定(config/*)は上で常に読み込み済み。ここはIDE機能の追加のみ。
-- ============================================
local profile = vim.env.NVIM_PROFILE or 'lite'

if profile == 'ide' and not vim.g.vscode then
    vim.g.ide_enabled = true
    require('ide')
elseif not vim.g.vscode then
    vim.api.nvim_create_user_command('EnableIde', function()
        if vim.g.ide_enabled then
            vim.notify('IDE profile is already enabled', vim.log.levels.INFO)
            return
        end
        vim.g.ide_enabled = true
        require('ide')

        -- 既に開いているバッファは BufReadPre / FileType を通過済みなので、
        -- event / ft で遅延読み込みする spec (lsp.lua, markdown.lua など) が
        -- 発火しないまま取り残される。ファイルを持つ通常バッファにだけ再発火して拾わせる。
        -- (FileType の再発火で ftplugin も再実行され、手動 setlocal は上書きされうる)
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf)
                and vim.bo[buf].buftype == ''
                and vim.api.nvim_buf_get_name(buf) ~= '' then
                vim.api.nvim_exec_autocmds('BufReadPre', { buffer = buf, modeline = false })
                if vim.bo[buf].filetype ~= '' then
                    vim.api.nvim_exec_autocmds('FileType', { buffer = buf, modeline = false })
                end
            end
        end
    end, { desc = 'Load the IDE profile (lua/ide) into a running lite session' })
end

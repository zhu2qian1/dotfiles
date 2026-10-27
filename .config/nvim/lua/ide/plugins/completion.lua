-- ============================================
-- Intellisense (補完エンジン)  ※AI inline-suggestion は含めない
-- blink.cmp : LSP/スニペット/パス/バッファ 由来の補完
-- ============================================

-- 散文を書く filetype では補完ポップアップが入力の邪魔になるので既定で切る。
-- <leader>ta でバッファ単位に戻せる。
local prose_filetypes = { 'markdown' }

return {
    {
        'saghen/blink.cmp',
        event = { 'InsertEnter', 'CmdlineEnter' },
        version = '*', -- リリース版バイナリを使用 (build不要)
        dependencies = {
            'rafamadriz/friendly-snippets',
        },
        -- opts.enabled で filetype を見て false を返す方式は使わない。blink は
        -- vim.b.completion == true による上書きを enabled() が真のときしか認めないため、
        -- トグルで再有効化できなくなる。代わりに blink が尊重する vim.b.completion を
        -- FileType で false にする。blink 本体は InsertEnter まで読まれず、その時点で
        -- FileType は発火済みなので、autocmd は config ではなく init (起動時) で張る。
        -- (:EnableIde 時は FileType が再発火されるので既存バッファも拾える)
        -- cmdline 補完は blink 側で vim.b.completion より先に分岐するので影響しない。
        init = function()
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('ide_completion_prose', { clear = true }),
                pattern = prose_filetypes,
                callback = function(ev)
                    if vim.b[ev.buf].completion == nil then vim.b[ev.buf].completion = false end
                end,
            })
        end,
        keys = {
            {
                '<leader>ta',
                function()
                    -- nil (未設定) は有効扱い
                    vim.b.completion = vim.b.completion == false
                    vim.notify('completion: ' .. (vim.b.completion and 'on' or 'off'))
                end,
                desc = 'toggle autocompletion (buffer)',
            },
        },
        opts = {
            keymap = {
                preset = 'default', -- <C-y>確定 / <C-space>表示 / <C-n>,<C-p>選択
                ['<CR>'] = { 'accept', 'fallback' },
                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
            },
            appearance = { nerd_font_variant = 'mono' },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            signature = { enabled = true },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
    },
}

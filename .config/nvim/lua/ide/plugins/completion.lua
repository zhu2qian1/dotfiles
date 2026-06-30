-- ============================================
-- Intellisense (補完エンジン)  ※AI inline-suggestion は含めない
-- blink.cmp : LSP/スニペット/パス/バッファ 由来の補完
-- ============================================

return {
    {
        'saghen/blink.cmp',
        event = { 'InsertEnter', 'CmdlineEnter' },
        version = '*', -- リリース版バイナリを使用 (build不要)
        dependencies = {
            'rafamadriz/friendly-snippets',
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

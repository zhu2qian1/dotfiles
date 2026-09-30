-- ============================================
-- File explorer : nvim-tree.lua
-- [GitHub](https://github.com/nvim-tree/nvim-tree.lua)
-- 左ペインにディレクトリツリーを表示する。
-- ============================================

return {
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        cmd = { 'NvimTreeToggle', 'NvimTreeFocus' },
        keys = {
            { '<leader>et', '<cmd>NvimTreeToggle<cr>', desc = 'nvim-tree: toggle' },
        },
        opts = {
            on_attach = function(bufnr)
                local api = require('nvim-tree.api')
                api.config.mappings.default_on_attach(bufnr)

                -- 既定の <C-t> は新しいタブページで開いてそちらへ移る (api.node.open.tab)。
                -- 上端の tabline にはバッファを並べて切り替える運用なので、タブページは作らず
                -- 同じタブ内のウィンドウにバッファとして開く (<CR> と同じ動作)。
                vim.keymap.set('n', '<C-t>', api.node.open.edit, {
                    buffer = bufnr, noremap = true, silent = true, nowait = true,
                    desc = 'nvim-tree: Open (current tab)',
                })
            end,
            view = {
                side = 'left',
            },
            actions = {
                open_file = {
                    resize_window = false,
                },
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = false,
            },
        },
    },
}

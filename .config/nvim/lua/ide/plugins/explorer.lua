-- ============================================
-- File explorer : nvim-tree.lua / yazi.nvim
-- [GitHub](https://github.com/nvim-tree/nvim-tree.lua)
-- [GitHub](https://github.com/mikavilpas/yazi.nvim)
-- nvim-tree は左ペインに常駐するツリー、yazi はフローティングで開いて選んだら
-- 閉じるファイラー。用途が違うので併用し、<leader>et / <leader>ey で使い分ける。
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
                -- 表示中の最長行に合わせて幅を自動調整する。
                width = {
                    min = 30,
                    max = -1,
                    padding = 1,
                },
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
    {
        -- 要: `yazi` CLI (PATH 上)。設定は ~/.config/yazi をそのまま読む。
        -- yazi.toml の opener (edit = nvim %s) は yazi.nvim が --chooser-file で
        -- 「開く」を横取りするので効かず、nvim が入れ子で起動することは無い。
        'mikavilpas/yazi.nvim',
        version = '*',
        dependencies = {
            { 'nvim-lua/plenary.nvim', lazy = true },
        },
        cmd = { 'Yazi' },
        keys = {
            { '<leader>ey', '<cmd>Yazi<cr>', desc = 'yazi: open at current file' },
            { '<leader>eY', '<cmd>Yazi cwd<cr>', desc = 'yazi: open at cwd' },
        },
        opts = {
            -- nvim . は従来どおり netrw に任せる (lite プロファイルと挙動を揃える)。
            open_for_directories = false,
            keymaps = {
                -- 既定の <C-t> は新しいタブページで開く。nvim-tree 側と同じ理由
                -- (tabline はバッファ切り替えに使っている) でタブページは作らない。
                open_file_in_tab = false,
            },
        },
    },
}

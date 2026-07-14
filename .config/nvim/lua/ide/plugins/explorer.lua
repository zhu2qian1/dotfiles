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

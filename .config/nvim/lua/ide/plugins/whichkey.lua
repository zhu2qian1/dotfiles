-- ============================================
-- Keymap ガイド : which-key.nvim
-- https://github.com/folke/which-key.nvim
-- プレフィックス (<leader>, g, z, ", <C-w> など) を押して少し待つと、
-- 続けて押せるキーと割り当て先をポップアップ表示する。
-- 各 keymap の desc をそのまま表示するので、desc の無いマッピングは rhs が出る。
-- ============================================

return {
    {
        'folke/which-key.nvim',
        -- UIEnter 後に読む。:EnableIde で後から setup() しても lazy 側が
        -- VeryLazy を即時発火するので同じように動く。
        event = 'VeryLazy',
        keys = {
            {
                '<leader>?',
                function() require('which-key').show({ global = false }) end,
                desc = 'which-key: buffer-local keymaps',
            },
        },
        opts = {
            -- 'helix' は右下に縦長で出す。'classic' は画面下部に横長。
            preset = 'helix',
            -- ポップアップが出るまでの待ち時間 (ms)。キー自体は待たずに効く。
            delay = 400,
            -- config/keymaps.lua の <Esc><Esc> (hls トグル) があると <Esc> が
            -- プレフィックス扱いになり、normal mode で Esc を 1 回押すたびに
            -- ポップアップが出て次のキー待ちになる。<Esc> 始まりは which-key の
            -- 管理対象から外し、Vim 標準の timeoutlen 待ちに任せる。
            filter = function(mapping)
                return not vim.keycode(mapping.lhs):find('^\27')
            end,
            -- プレフィックスにグループ名を付ける。個々のキーの説明は
            -- 各 keymap の desc (lua/config/keymaps.lua や lua/ide/plugins/*.lua) 側に書く。
            spec = {
                { '<leader>a', group = 'AI/Claude Code' },
                { '<leader>c', group = 'code (LSP)' },
                { '<leader>e', group = 'explorer' },
                { '<leader>f', group = 'find (telescope)' },
                { '<leader>M', group = 'man' },
                { '<leader>t', group = 'toggle' },
                { '<leader>;', group = '日時挿入' },
            },
        },
    },
}

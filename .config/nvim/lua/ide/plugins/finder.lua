-- ============================================
-- Fuzzy finder : telescope.nvim
-- 要: ripgrep (`rg`) — live_grep / grep_string 用。なければ検索系だけ動かない。
--     fd (任意) — files のリストアップが速くなる。なければ内蔵 find にフォールバック。
--     make + C コンパイラ (任意) — fzf-native を入れるとソートが高速化する。
-- 起動は遅延 (:Telescope コマンドと下記 keys で初めて読み込む)。
-- ============================================

return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        cmd = 'Telescope',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                -- ネイティブソータ。ビルドできる環境でだけ有効化する。
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function() return vim.fn.executable('make') == 1 end,
            },
        },
        keys = {
            -- ファイル/バッファ系 (f = find)
            { '<C-p>',      function() require('telescope.builtin').find_files() end,           desc = 'telescope: files' },
            { '<leader>ff', function() require('telescope.builtin').find_files() end,           desc = 'telescope: files' },
            { '<leader>fg', function() require('telescope.builtin').git_files() end,            desc = 'telescope: git files' },
            { '<leader>fb', function() require('telescope.builtin').buffers() end,              desc = 'telescope: buffers' },
            { '<leader>fo', function() require('telescope.builtin').oldfiles() end,             desc = 'telescope: recent files' },
            { '<leader>fr', function() require('telescope.builtin').resume() end,               desc = 'telescope: resume last' },

            -- 検索系 (grep / lines)
            { '<leader>fG', function() require('telescope.builtin').live_grep() end,            desc = 'telescope: live grep' },
            { '<leader>fw', function() require('telescope.builtin').grep_string() end,          desc = 'telescope: grep word' },
            { '<leader>fl', function() require('telescope.builtin').current_buffer_fuzzy_find() end, desc = 'telescope: buffer lines' },
            {
                '<leader>fw',
                function()
                    -- ビジュアル選択を抜けてからレジスタ経由で選択文字列を取る
                    vim.cmd('noautocmd normal! "vy')
                    require('telescope.builtin').grep_string({ search = vim.fn.getreg('v') })
                end,
                desc = 'telescope: grep selection',
                mode = 'v',
            },

            -- Vim/LSP 情報
            { '<leader>fh', function() require('telescope.builtin').help_tags() end,            desc = 'telescope: help tags' },
            { '<leader>fk', function() require('telescope.builtin').keymaps() end,              desc = 'telescope: keymaps' },
            { '<leader>fc', function() require('telescope.builtin').commands() end,             desc = 'telescope: commands' },
            { '<leader>fd', function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, desc = 'telescope: diagnostics' },
            { '<leader>fs', function() require('telescope.builtin').lsp_document_symbols() end, desc = 'telescope: doc symbols' },
        },
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')

            telescope.setup({
                defaults = {
                    -- ターミナル UI 寄りの控えめなレイアウト
                    layout_strategy = 'flex',
                    layout_config = {
                        width = 0.85,
                        height = 0.85,
                        prompt_position = 'top',
                    },
                    sorting_strategy = 'ascending',
                    path_display = { 'truncate' },
                    mappings = {
                        i = {
                            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist, -- 全件 quickfix へ
                            ['<C-d>'] = actions.results_scrolling_down,
                            ['<C-u>'] = actions.results_scrolling_up,
                            ['<Esc>'] = actions.close, -- insert から一発で閉じる
                        },
                        n = {
                            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
                        },
                    },
                },
                pickers = {
                    find_files = { hidden = true },
                    buffers = {
                        sort_lastused = true,
                        mappings = { i = { ['<C-x>'] = actions.delete_buffer } },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = 'smart_case',
                    },
                },
            })

            pcall(telescope.load_extension, 'fzf')
        end,
    },
}

-- ============================================
-- Fuzzy finder : fzf-lua (fzf の Lua ラッパー)
-- 要: `fzf` バイナリ (PATH 上)。なければ git grep/builtin で一部代替されるが、
--     基本は fzf を入れておくこと (winget install junegunn.fzf / apt install fzf 等)。
-- 起動は遅延 (コマンド :FzfLua と下記 keys で初めて読み込む)。
-- ============================================

return {
    {
        'ibhagwan/fzf-lua',
        cmd = 'FzfLua',
        keys = {
            -- ファイル/バッファ系 (f = find)
            { '<C-p>',       function() require('fzf-lua').files() end,        desc = 'fzf: files' },
            { '<leader>ff',  function() require('fzf-lua').files() end,        desc = 'fzf: files' },
            { '<leader>fg',  function() require('fzf-lua').git_files() end,    desc = 'fzf: git files' },
            { '<leader>fb',  function() require('fzf-lua').buffers() end,      desc = 'fzf: buffers' },
            { '<leader>fo',  function() require('fzf-lua').oldfiles() end,     desc = 'fzf: recent files' },
            { '<leader>fr',  function() require('fzf-lua').resume() end,       desc = 'fzf: resume last' },

            -- 検索系 (grep / lines)
            { '<leader>fG',  function() require('fzf-lua').live_grep() end,    desc = 'fzf: live grep' },
            { '<leader>fw',  function() require('fzf-lua').grep_cword() end,   desc = 'fzf: grep word' },
            { '<leader>fl',  function() require('fzf-lua').blines() end,       desc = 'fzf: buffer lines' },
            { '<leader>fw',  function() require('fzf-lua').grep_visual() end,  desc = 'fzf: grep selection', mode = 'v' },

            -- Vim/LSP 情報
            { '<leader>fh',  function() require('fzf-lua').help_tags() end,    desc = 'fzf: help tags' },
            { '<leader>fk',  function() require('fzf-lua').keymaps() end,      desc = 'fzf: keymaps' },
            { '<leader>fc',  function() require('fzf-lua').commands() end,     desc = 'fzf: commands' },
            { '<leader>fd',  function() require('fzf-lua').diagnostics_document() end, desc = 'fzf: diagnostics' },
            { '<leader>fs',  function() require('fzf-lua').lsp_document_symbols() end, desc = 'fzf: doc symbols' },
        },
        opts = {
            -- ターミナル UI 寄りの控えめなレイアウト
            winopts = {
                height  = 0.85,
                width   = 0.85,
                preview = { layout = 'flex' },
            },
            keymap = {
                -- fzf プロセス側 (insert 中) のキー
                fzf = {
                    ['ctrl-q'] = 'select-all+accept', -- 全選択して quickfix へ
                    ['ctrl-d'] = 'half-page-down',
                    ['ctrl-u'] = 'half-page-up',
                },
            },
        },
    },
}

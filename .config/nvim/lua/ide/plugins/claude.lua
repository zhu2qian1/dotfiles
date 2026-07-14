-- ============================================
-- Claude Code 連携 : coder/claudecode.nvim
-- https://github.com/coder/claudecode.nvim
-- Neovim を Claude Code CLI の IDE として接続する (WebSocket MCP)。
-- 要: `claude` CLI (PATH 上)。folke/snacks.nvim をターミナル UI として利用。
-- 起動は遅延 (:ClaudeCode 系コマンド / 下記 keys で初めて読み込む)。
-- ============================================

return {
    {
        'coder/claudecode.nvim',
        dependencies = { 'folke/snacks.nvim' },
        config = true,
        cmd = {
            'ClaudeCode',
            'ClaudeCodeFocus',
            'ClaudeCodeSelectModel',
            'ClaudeCodeAdd',
            'ClaudeCodeSend',
            'ClaudeCodeTreeAdd',
            'ClaudeCodeStatus',
            'ClaudeCodeStart',
            'ClaudeCodeStop',
            'ClaudeCodeOpen',
            'ClaudeCodeClose',
            'ClaudeCodeDiffAccept',
            'ClaudeCodeDiffDeny',
            'ClaudeCodeCloseAllDiffs',
        },
        keys = {
            -- a = AI/Claude Code 系のプレフィックス
            { '<leader>a',  nil,                              desc = 'AI/Claude Code' },
            { '<leader>ac', '<cmd>ClaudeCode<cr>',            desc = 'Claude: toggle' },
            { '<leader>af', '<cmd>ClaudeCodeFocus<cr>',       desc = 'Claude: focus' },
            { '<leader>ar', '<cmd>ClaudeCode --resume<cr>',   desc = 'Claude: resume' },
            { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Claude: continue' },
            { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Claude: select model' },
            { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>',       desc = 'Claude: add current buffer' },
            { '<leader>as', '<cmd>ClaudeCodeSend<cr>',        mode = 'v', desc = 'Claude: send selection' },
            { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>',  desc = 'Claude: accept diff' },
            { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>',    desc = 'Claude: deny diff' },
        },
        opts = {
            diff_split_width_percentage = 0.20,
        }
    },
}

-- ============================================
-- Git : gitsigns.nvim / snacks.nvim (lazygit)
-- https://github.com/lewis6991/gitsigns.nvim
-- サインカラムに追加/変更/削除行を表示し、hunk 単位の移動・stage・reset・blame を行う。
-- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md
-- lazygit をフローティングで開く。要: `lazygit` (PATH 上)。
-- ============================================

return {
    {
        'lewis6991/gitsigns.nvim',
        -- :EnableIde 時は init.lua 側で既存バッファに BufReadPre を再発火するので拾える。
        -- attach 前に開いていたバッファにも setup() 時点で attach される。
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            on_attach = function(bufnr)
                local gs = require('gitsigns')
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'gitsigns: ' .. desc })
                end

                -- ]c / [c は diff モードでは Vim 標準の差分移動なので、そのときだけ標準に譲る。
                map('n', ']c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']c', bang = true })
                    else
                        gs.nav_hunk('next')
                    end
                end, 'next hunk')
                map('n', '[c', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[c', bang = true })
                    else
                        gs.nav_hunk('prev')
                    end
                end, 'prev hunk')

                -- stage_hunk は stage 済みの hunk に対して呼ぶと unstage になる (トグル)。
                map('n', '<leader>hs', gs.stage_hunk, 'stage hunk (toggle)')
                map('n', '<leader>hr', gs.reset_hunk, 'reset hunk')
                map('v', '<leader>hs', function()
                    gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, 'stage selected lines')
                map('v', '<leader>hr', function()
                    gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                end, 'reset selected lines')
                map('n', '<leader>hS', gs.stage_buffer, 'stage buffer')
                map('n', '<leader>hR', gs.reset_buffer, 'reset buffer')
                map('n', '<leader>hp', gs.preview_hunk, 'preview hunk')
                map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'blame line')
                map('n', '<leader>hd', gs.diffthis, 'diff against index')
                map('n', '<leader>tb', gs.toggle_current_line_blame, 'toggle line blame')

                -- ih : hunk をテキストオブジェクトとして選択 (vih / dih など)
                map({ 'o', 'x' }, 'ih', gs.select_hunk, 'select hunk')
            end,
        },
    },
    {
        -- snacks.nvim は claude.lua でも claudecode.nvim の依存として読んでいる。
        -- lazy.nvim は同名の spec をマージするので、opts はここに足すだけで両方に効く。
        -- lazygit モジュールは setup が VimEnter 後 (keys で遅延読み込み / :EnableIde) でも動く。
        'folke/snacks.nvim',
        keys = {
            { '<leader>gg', function() Snacks.lazygit() end,          desc = 'lazygit' },
            { '<leader>gf', function() Snacks.lazygit.log_file() end, desc = 'lazygit: current file log' },
        },
        opts = {
            -- configure (既定 true) で今のカラースキームを lazygit のテーマに流し込み、
            -- lazygit の e (edit) をこの Neovim インスタンスで開くように設定する。
            lazygit = {
                config = {
                    gui = {
                        -- snacks は既定で nerdFontsVersion = "3" (アイコン表示) にするが、
                        -- config/options.lua の setcellwidths で Nerd Font アイコンを幅 2 に
                        -- しているため、Neovim の :terminal 上ではアイコンが 2 セルを占める。
                        -- lazygit 側 (go-runewidth) は 1 セルとして描くので行が 1 セルずつ
                        -- 右へずれ、Commits / Stash 欄に描き残しが出る。アイコンを切って揃える。
                        nerdFontsVersion = '',
                    },
                },
            },
        },
    },
}

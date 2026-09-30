-- ============================================
-- Statusline : vim-airline
-- https://github.com/vim-airline/vim-airline
-- config/options.lua の素の 'statusline' を IDE プロファイルでだけ置き換える
-- (lite はプラグイン無しの方針なので、そちらは従来の statusline のまま)。
-- gitsigns の hunk 数・LSP 診断数は airline の extension が自動で拾う。
-- ============================================

return {
    {
        'vim-airline/vim-airline',
        -- statusline は起動直後から必要なので遅延させない。
        -- :EnableIde で後から読んだ場合も、plugin/airline.vim が読み込み時に
        -- 全ウィンドウの statusline を張り替える。
        lazy = false,
        -- g:airline_* はプラグイン読み込み前に確定している必要があるので init で設定する。
        init = function()
            -- completion.lua (blink.cmp) と同じく Nerd Font 前提。区切りに powerline 記号を使う。
            vim.g.airline_powerline_fonts = 1
            -- 開いているバッファをタブライン代わりに上端へ並べる
            vim.g['airline#extensions#tabline#enabled'] = 1
        end,
        config = function()
            -- モードは airline が左端に出すので、コマンドライン側の -- INSERT -- は冗長
            vim.opt.showmode = false
        end,
    },
}

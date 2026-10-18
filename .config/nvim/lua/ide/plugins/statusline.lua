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
            -- Nerd Font / powerline 記号に頼らず、区切り文字も置かない素の見た目にする。
            -- powerline_fonts = 0 だけだと utf-8 環境では ㏑ や ᚠ などの装飾記号が
            -- 出るので、symbols_ascii で RO / ln: などのプレーンな表記に寄せる
            -- (ascii モードでは区切り文字の既定値も空になる)。
            vim.g.airline_powerline_fonts = 0
            vim.g.airline_symbols_ascii = 1
            -- 開いているバッファをタブライン代わりに上端へ並べる
            vim.g['airline#extensions#tabline#enabled'] = 1
            -- tabline は powerline_fonts = 0 のとき独自に ' ' と '|' を既定にするので
            -- '|' は明示的に空にする。left_sep は空白のまま残す: バッファ名の前の空白は
            -- 直前とハイライトグループが変わる位置 (アクティブなバッファの先頭など) で
            -- 省かれ、left_sep が代わりに埋める前提になっているため、空にすると詰まる。
            vim.g['airline#extensions#tabline#left_sep'] = ' '
            vim.g['airline#extensions#tabline#left_alt_sep'] = ''
        end,
        config = function()
            -- モードは airline が左端に出すので、コマンドライン側の -- INSERT -- は冗長
            vim.opt.showmode = false
        end,
    },
}

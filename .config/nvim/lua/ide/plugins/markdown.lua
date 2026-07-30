-- ============================================
-- Markdown 表示
-- render-markdown.nvim: バッファ内で見出し・リスト・コードブロック等を装飾表示する
-- (ブラウザ不要。SSH 越しの利用でも完結する)
-- ============================================

return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown' },
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            -- 見出しの sign アイコン。デフォルトは末尾に空白付きの '󰫎 ' だが、
            -- config/options.lua の setcellwidths で Nerd Font アイコンを幅 2 に
            -- 固定しているため合計 3 セルになり nvim_buf_set_extmark が
            -- "Invalid 'sign_text'" で失敗する (sign_text は 1〜2 セル必須)。
            -- 空白を落として 2 セルに収める。
            heading = { signs = { '󰫎' } },
        },
    },
}

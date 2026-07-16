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
        opts = {},
    },
}

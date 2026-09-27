-- ============================================
-- カラーコードのプレビュー : nvim-highlight-colors
-- https://github.com/brenoprata10/nvim-highlight-colors
-- #rgb / #rrggbb / rgb() / hsl() などを見つけ、その色の記号を行末に表示する。
-- starship のパレット定義 (starship/crampack.toml) のように色コードが並ぶ
-- ファイルで、実際の色を確認するために入れている。
-- ============================================

return {
    {
        'brenoprata10/nvim-highlight-colors',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            -- 'background' は文字の背景を塗るので、色によってはコードが読めなくなる。
            -- 仮想テキストなら元の文字列に手を加えずに済む。
            render = 'virtual',
            virtual_symbol = '■',
            -- 'inline' は文字列の直後に挿入するため桁がずれてカーソル移動が
            -- 見た目と合わなくなる。行末ならテキストの位置は変わらない。
            virtual_symbol_position = 'eol',
            virtual_symbol_prefix = '',
            virtual_symbol_suffix = '',
            -- 名前付きの色 (red, lime など) まで拾うと、crampack.toml の
            -- `fg:lime` のようなパレット名や英単語にも反応してうるさい。
            enable_named_colors = false,
            enable_tailwind = false,
        },
    },
}

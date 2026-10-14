-- ============================================
-- カラーコードのプレビュー : nvim-highlight-colors
-- https://github.com/brenoprata10/nvim-highlight-colors
-- #rgb / #rrggbb / rgb() / hsl() などを見つけ、その色の記号をコードの直後に表示する。
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
            -- 'eow' はカラーコードの直後に挿入する。行末 ('eol') と違ってどのコードの色かが
            -- 一目で分かる代わりに、記号の分だけ右側の表示桁がずれ、桁揃えも崩れる。
            -- ('inline' は直前に挿入するので、コードの先頭が記号に押されて読みにくい)
            virtual_symbol_position = 'eow',
            -- 隙間は空けない。前後どちらに空けても仮想テキストの幅が増えるぶん、
            -- カーソル移動が見た目と合わない違和感が大きくなる (suffix だと間延びもする)。
            virtual_symbol_prefix = '',
            virtual_symbol_suffix = '',
            -- 名前付きの色 (red, lime など) まで拾うと、crampack.toml の
            -- `fg:lime` のようなパレット名や英単語にも反応してうるさい。
            enable_named_colors = false,
            enable_tailwind = false,
        },
    },
}

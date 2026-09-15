-- ============================================
-- 対応ハイライト / 移動 : vim-matchup
-- https://github.com/andymass/vim-matchup
-- 組み込みの matchparen / matchit を置き換え、括弧に加えて HTML / JSX の
-- 開始タグ・終了タグや if / end などのキーワード対応をハイライトする。
-- %  g%  [%  ]%  z% で対応先へ移動し、i% / a% でテキストオブジェクトとして選択できる。
--
-- Neovim では組み込みの vim.treesitter を直接使う (nvim-treesitter 本体は不要)。
-- ただし html / javascript / tsx などのパーサは Neovim に同梱されていないため、
-- 入っていない言語では ftplugin の b:match_words による正規表現マッチで動く。
-- HTML / JSX (javascriptreact / typescriptreact) のタグ対応はこちらでも実用になる。
-- パーサを後から入れれば設定変更なしで treesitter 側に切り替わる。
-- ============================================

return {
    {
        'andymass/vim-matchup',
        -- README が event 指定による遅延読み込みを非推奨としているので起動時に読む
        -- (起動時に読むコード自体は最小限)。:EnableIde で後から読んでも、
        -- matchparen の置き換えは読み込み時点で行われる。
        lazy = false,
        -- opts は setup() で vim.g.matchup_<mod>_<key> に展開される。
        -- 読み込み前に確定している必要がある遅延系の値もここで渡せる。
        opts = {
            matchparen = {
                -- 対応先が画面外のとき、既定の 'status' は statusline を一時的に
                -- 乗っ取って表示する。浮動ウィンドウで画面上端に出す方が邪魔にならない。
                offscreen = { method = 'popup' },
            },
        },
    },
}

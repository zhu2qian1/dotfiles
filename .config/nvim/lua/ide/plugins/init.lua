-- ============================================
-- IDE plugins (lazy.nvim spec)
-- このファイル(と同階層の *.lua)が return する spec が読み込まれる。
-- カテゴリごとにファイルを分けると見通しが良い:
--   lua/ide/plugins/lsp.lua
--   lua/ide/plugins/completion.lua
--   lua/ide/plugins/treesitter.lua
--   lua/ide/plugins/finder.lua
--   など
-- 下は雛形。実プラグインは後で追加する。
-- ============================================

return {
    -- 例) treesitter を入れる場合:
    -- {
    --     'nvim-treesitter/nvim-treesitter',
    --     build = ':TSUpdate',
    --     event = { 'BufReadPost', 'BufNewFile' },
    --     config = function() ... end,
    -- },
}

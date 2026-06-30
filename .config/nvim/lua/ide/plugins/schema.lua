-- ============================================
-- JSON / YAML schema カタログ
-- SchemaStore.nvim はライブラリ。lsp.lua の jsonls/yamlls 設定から参照する。
--   require('schemastore').json.schemas()
--   require('schemastore').yaml.schemas()
-- ============================================

return {
    {
        'b0o/SchemaStore.nvim',
        lazy = true, -- lsp.lua から require された時に読み込まれる
        version = false,
    },
}

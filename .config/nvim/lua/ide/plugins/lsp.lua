-- ============================================
-- LSP : nvim-lspconfig + mason (+ mason-lspconfig)
-- 対象: TypeScript / JSON / YAML / TOML / Lua / Python
-- Neovim 0.12 の vim.lsp.config / vim.lsp.enable を使用。
-- ============================================

return {
    -- mason: LSPサーバ本体の取得・管理 (:Mason)
    { 'mason-org/mason.nvim', cmd = 'Mason', opts = {} },

    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'mason-org/mason-lspconfig.nvim', dependencies = 'mason-org/mason.nvim' },
            'saghen/blink.cmp',
            'b0o/SchemaStore.nvim',
        },
        config = function()
            -- lspconfig名 でサーバを指定
            local servers = {
                ts_ls = {},   -- TypeScript / JavaScript (typescript-language-server)
                jsonls = {},  -- JSON  (vscode-langservers-extracted)
                yamlls = {},  -- YAML  (yaml-language-server)
                taplo = {},   -- TOML
                lua_ls = {},  -- Lua
                pyright = {}, -- Python
            }

            -- 全サーバ共通: blink.cmp の補完 capabilities を付与
            vim.lsp.config('*', {
                capabilities = require('blink.cmp').get_lsp_capabilities(),
            })

            -- JSON: SchemaStore のスキーマ + コメント許容
            vim.lsp.config('jsonls', {
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = { enable = true },
                    },
                },
            })

            -- YAML: SchemaStore のスキーマ (組込スキーマは無効化して二重適用を防ぐ)
            vim.lsp.config('yamlls', {
                settings = {
                    yaml = {
                        schemaStore = { enable = false, url = '' },
                        schemas = require('schemastore').yaml.schemas(),
                    },
                },
            })

            -- Lua: vim グローバルを既知にし、ランタイムを補完対象に
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        workspace = {
                            checkThirdParty = false,
                            library = vim.api.nvim_get_runtime_file('', true),
                        },
                        diagnostics = { globals = { 'vim' } },
                        telemetry = { enable = false },
                    },
                },
            })

            -- mason: サーバの自動インストール。mason-lspconfig が installed 分を
            -- 自動で vim.lsp.enable する (v2)
            require('mason-lspconfig').setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = true,
            })

            -- LSP共通 keymap (アタッチ時に buffer-local で張る)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(ev)
                    local opts = function(desc)
                        return { buffer = ev.buf, desc = 'LSP: ' .. desc }
                    end
                    local map = vim.keymap.set
                    map('n', 'gd', vim.lsp.buf.definition, opts('definition'))
                    map('n', 'gD', vim.lsp.buf.declaration, opts('declaration'))
                    map('n', 'gr', vim.lsp.buf.references, opts('references'))
                    map('n', 'gi', vim.lsp.buf.implementation, opts('implementation'))
                    map('n', 'K', vim.lsp.buf.hover, opts('hover'))
                    map('n', '<leader>rn', vim.lsp.buf.rename, opts('rename'))
                    map('n', '<leader>ca', vim.lsp.buf.code_action, opts('code action'))
                    map('n', '<leader>cf', function() vim.lsp.buf.format({ async = true }) end, opts('format'))
                    map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts('prev diag'))
                    map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts('next diag'))
                end,
            })
        end,
    },
}

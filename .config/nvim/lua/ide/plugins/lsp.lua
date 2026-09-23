-- ============================================
-- LSP : nvim-lspconfig + mason (+ mason-lspconfig)
-- 対象: TypeScript / JSON / YAML / TOML / Lua / Python / Java
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
                pyright = {}, -- Python (型チェック・補完)
                ruff = {},    -- Python (lint / format。ruff 本体の `ruff server`)
                jdtls = {},   -- Java
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

            -- Python: プロジェクト直下の .venv を pyright に使わせる。pyright の
            -- langserver は venv を自動検出せず、pythonPath が無ければ PATH 上の python
            -- (= venv 外) で import を解決するので、uv 等で入れたパッケージが
            -- 未解決になる。root_dir は nvim の cwd ではなくバッファのパスから
            -- root_markers (pyproject.toml 等) を遡って決まるため、モノレポの親から
            -- 開いても backend/ のようなサブプロジェクトの .venv を拾える。
            -- venv を activate 済みならそちらを優先する。
            -- config.settings は差し替えずに中身を書き換えること: before_init より前に
            -- client.settings が同じテーブルを参照する形で作られているため、
            -- config.settings = tbl_deep_extend(...) では pyright に届かない。
            vim.lsp.config('pyright', {
                before_init = function(_, config)
                    local venv = vim.env.VIRTUAL_ENV
                    if not venv and config.root_dir then
                        venv = vim.fs.joinpath(config.root_dir, '.venv')
                    end
                    if not venv then
                        return
                    end
                    for _, rel in ipairs({ 'bin/python', 'Scripts/python.exe' }) do
                        local python = vim.fs.joinpath(venv, rel)
                        if vim.uv.fs_stat(python) then
                            local settings = config.settings
                            settings.python = settings.python or {}
                            settings.python.pythonPath = python
                            return
                        end
                    end
                end,
            })

            -- Java: Lombok を javaagent として jdtls の JVM に載せる。build.gradle に
            -- lombok があっても、jdtls 自身の JVM にエージェントが無いと生成される
            -- getter/setter が見えず getXxx() が未定義エラーになる。Mason の jdtls
            -- パッケージは lombok.jar を同梱しているが、lspconfig の既定 cmd は
            -- JDTLS_JVM_ARGS 環境変数経由でしか追加の JVM 引数を渡さないため、ここで
            -- 環境変数に足す。jar が無い状態で -javaagent を渡すと JVM が起動しないので
            -- 存在を確認してから、既にユーザーが指定していれば二重に足さない。
            local lombok = vim.fn.stdpath('data') .. '/mason/share/jdtls/lombok.jar'
            local jvm_args = vim.env.JDTLS_JVM_ARGS or ''
            if vim.uv.fs_stat(lombok) and not jvm_args:find('lombok', 1, true) then
                vim.env.JDTLS_JVM_ARGS = vim.trim(jvm_args .. ' -javaagent:' .. lombok)
            end

            -- Java: build.gradle / pom.xml の変更を確認なしで取り込み直させる。既定の
            -- 'interactive' では jdtls が「再同期するか」を VS Code 独自の
            -- language/actionableNotification で尋ねるが、素の Neovim はこれを黙って
            -- 捨てるので、依存を追加しても jdtls のクラスパスが古いまま
            -- (「X cannot be resolved to a type」) になる。
            vim.lsp.config('jdtls', {
                settings = {
                    java = {
                        configuration = { updateBuildConfiguration = 'automatic' },
                    },
                },
            })

            -- Java: java-debug-adapter を jdtls の拡張バンドルとして登録する。これが
            -- 入っていると LSP コマンド vscode.java.startDebugSession が使えるようになり、
            -- nvim-dap から attach できる (dap.lua 側で使う)。Mason は
            -- share/java-debug-adapter/ にバージョン無しの symlink を張るのでそれを見る。
            -- 未インストールでも jdtls は普通に起動させたいので、jar が無ければ足さない。
            local java_debug = vim.fn.stdpath('data')
                .. '/mason/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'
            if vim.uv.fs_stat(java_debug) then
                vim.lsp.config('jdtls', {
                    init_options = { bundles = { java_debug } },
                })
            end

            -- Python: ruff は lint / format だけを担当させる。hover は pyright と
            -- 重複して K で 2 つ出るので切る。保存時の format は ruff に限定する —
            -- filter が無いと pyright 等、同じバッファに付いた他のサーバにも
            -- format 要求が飛ぶ。augroup をバッファ単位で clear しているのは、
            -- :LspRestart で再 attach したときに autocmd が重複しないようにするため。
            vim.lsp.config('ruff', {
                on_attach = function(client, bufnr)
                    client.server_capabilities.hoverProvider = false
                    vim.api.nvim_create_autocmd('BufWritePre', {
                        group = vim.api.nvim_create_augroup('ruff_format_' .. bufnr, { clear = true }),
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr, name = 'ruff' })
                        end,
                    })
                end,
            })

            -- mason: サーバの自動インストール。mason-lspconfig が installed 分を
            -- 自動で vim.lsp.enable する (v2)
            require('mason-lspconfig').setup({
                ensure_installed = vim.tbl_keys(servers),
                automatic_enable = true,
            })

            -- 診断をインライン表示 (行末に virtual text)
            vim.diagnostic.config({
                virtual_text = {
                    prefix = '●',
                    spacing = 2,
                    source = 'if_many',
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = 'rounded', source = 'if_many' },
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

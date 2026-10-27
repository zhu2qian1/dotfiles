-- ============================================
-- Debug : nvim-dap (+ nvim-dap-ui)
-- https://github.com/mfussenegger/nvim-dap
-- 対象: Java (jdtls + java-debug-adapter への attach) / Go (delve で launch)
--
-- Java のデバッグは JDWP で attach するのが基本なので、実行中の JVM 側を
--   ./gradlew bootRun --debug-jvm        (Gradle 既定: server=y,suspend=y,address=*:5005)
--   ./gradlew test    --debug-jvm
-- のように起動してから <leader>dc で attach する。起動は nvim の外 (端末) で行う。
-- nvim-dap は JDWP を直接喋れないので、間に java-debug-adapter を挟む。これは
-- jdtls の拡張バンドルとして動き、LSP コマンド vscode.java.startDebugSession を
-- 投げると DAP サーバを立てて port を返す。バンドルの登録は lsp.lua の jdtls
-- (init_options.bundles) 側にある。
--
-- Go は Java と逆に nvim から delve (`dlv dap`) を起動して launch する。
-- dlv 自体がビルドから実行まで面倒を見るので、事前に端末で起動しておく必要は無い。
-- dlv は `:MasonInstall delve` か `go install github.com/go-delve/delve/cmd/dlv@latest`
-- で入れる (mason-lspconfig の ensure_installed は LSP しか扱わないので自動では入らない)。
-- ============================================

return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                dependencies = { 'nvim-neotest/nvim-nio' },
                opts = {},
            },
        },
        -- keys 経由でのみ読み込む。ブレークポイントを置く/attach する時が最初の起点。
        keys = {
            { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'dap: breakpoint (toggle)' },
            {
                '<leader>dB',
                function()
                    require('dap').set_breakpoint(vim.fn.input('breakpoint condition: '))
                end,
                desc = 'dap: conditional breakpoint',
            },
            { '<leader>dc', function() require('dap').continue() end,  desc = 'dap: continue / attach' },
            { '<leader>dn', function() require('dap').step_over() end, desc = 'dap: step over' },
            { '<leader>di', function() require('dap').step_into() end, desc = 'dap: step into' },
            { '<leader>do', function() require('dap').step_out() end,  desc = 'dap: step out' },
            { '<leader>dq', function() require('dap').disconnect() end, desc = 'dap: detach (対象は動き続ける)' },
            { '<leader>dQ', function() require('dap').terminate() end, desc = 'dap: terminate' },
            { '<leader>du', function() require('dapui').toggle() end,  desc = 'dap-ui: toggle' },
            { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'dap: repl' },
            {
                '<leader>dk',
                function() require('dapui').eval(nil, { enter = true }) end,
                mode = { 'n', 'v' },
                desc = 'dap-ui: eval (カーソル下 / 選択範囲)',
            },
        },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')

            -- adapter: jdtls に DAP サーバを立てさせて、その port へ繋ぐ。
            -- jdtls が起動していない (= Java バッファを開いていない) 状態では
            -- コマンドを投げる先が無いので、その場合は分かる形で失敗させる。
            dap.adapters.java = function(callback)
                local client = vim.lsp.get_clients({ name = 'jdtls' })[1]
                if not client then
                    vim.notify('dap: jdtls が起動していない (Java ファイルを開いてから実行する)', vim.log.levels.ERROR)
                    return
                end
                -- exec_cmd の handler は結果が返るまで呼ばれないため callback も遅延する。
                -- nvim-dap は callback を非同期で待つ作りなのでこれで問題ない。
                client:exec_cmd({ command = 'vscode.java.startDebugSession' }, { bufnr = 0 }, function(err, port)
                    if err or not port then
                        vim.notify(
                            'dap: startDebugSession に失敗 (java-debug-adapter のバンドル未登録?): '
                            .. vim.inspect(err),
                            vim.log.levels.ERROR
                        )
                        return
                    end
                    callback({ type = 'server', host = '127.0.0.1', port = port })
                end)
            end

            -- attach 専用。port を関数にしておくと nvim-dap が continue() のたびに
            -- 評価するので、--debug-jvm のポートを変えた時も設定を直さずに済む。
            dap.configurations.java = {
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to JVM (127.0.0.1:5005)',
                    hostName = '127.0.0.1',
                    port = 5005,
                },
                {
                    type = 'java',
                    request = 'attach',
                    name = 'Attach to JVM (port を入力)',
                    hostName = '127.0.0.1',
                    port = function()
                        return tonumber(vim.fn.input('debug port: ', '5005'))
                    end,
                },
            }

            -- adapter: `dlv dap` を空きポートで起動してそこへ繋ぐ。${port} は nvim-dap が
            -- 空きポートに置き換える。PATH に dlv が無いと nvim-dap は「接続できない」と
            -- しか言わないので、先に分かる形で止める (mason の bin は mason の読み込み時に
            -- PATH へ足されるので、Mason で入れた dlv もここで見える)。
            dap.adapters.delve = function(callback)
                if vim.fn.executable('dlv') ~= 1 then
                    vim.notify('dap: dlv が無い (:MasonInstall delve)', vim.log.levels.ERROR)
                    return
                end
                callback({
                    type = 'server',
                    port = '${port}',
                    executable = { command = 'dlv', args = { 'dap', '-l', '127.0.0.1:${port}' } },
                })
            end

            -- program はパッケージのディレクトリを渡す (ファイル単体だと同じパッケージの
            -- 他ファイルが入らずビルドに失敗する)。cmd/ 配下に main が複数ある構成向けに、
            -- 入力させる版も置く。相対パスは nvim の cwd (= dlv の cwd) 基準。
            dap.configurations.go = {
                { type = 'delve', request = 'launch', name = 'Debug package (このファイルのディレクトリ)', program = '${fileDirname}' },
                {
                    type = 'delve',
                    request = 'launch',
                    name = 'Debug package (パスと引数を入力)',
                    program = function() return vim.fn.input('package: ', './cmd/', 'dir') end,
                    args = function() return vim.split(vim.fn.input('args: '), ' ', { trimempty = true }) end,
                },
                { type = 'delve', request = 'launch', mode = 'test', name = 'Debug test (このパッケージ)', program = '${fileDirname}' },
                {
                    type = 'delve',
                    request = 'launch',
                    mode = 'test',
                    name = 'Debug test (名前を入力)',
                    program = '${fileDirname}',
                    args = function() return { '-test.run', vim.fn.input('test regexp: ', '^Test') } end,
                },
            }

            -- セッションの開始/終了に合わせて UI を出し入れする
            dap.listeners.after.event_initialized['dapui'] = function() dapui.open() end
            dap.listeners.before.event_terminated['dapui'] = function() dapui.close() end
            dap.listeners.before.event_exited['dapui'] = function() dapui.close() end

            -- ブレークポイント等の sign。既定は同じ記号で区別が付かないので変えておく。
            vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticSignError' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticSignError' })
            vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DiagnosticSignInfo' })
            vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticSignWarn', linehl = 'Visual' })
        end,
    },
}

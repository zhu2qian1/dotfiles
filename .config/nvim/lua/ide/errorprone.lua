-- ============================================
-- Error Prone / NullAway の結果を vim.diagnostic に流す (Gradle プロジェクト用)
--
-- jdtls は Eclipse のコンパイラ (ECJ) で解析するので、javac プラグインとして動く
-- Error Prone (と NullAway) の結果は LSP の診断に出てこない。そこで Java ファイルの
-- 保存時に裏で ./gradlew compileJava compileTestJava を走らせ、javac の出力を
-- パースして独自の namespace に診断として載せる。
--
-- - 対象は gradlew があり、build.gradle(.kts) に errorprone の記述があるプロジェクト
--   だけ。そうでないプロジェクトで保存のたびに Gradle を回さないため。
-- - --rerun で毎回フルコンパイルする。インクリメンタルだと再コンパイルされなかった
--   ファイルの警告が出力に現れず、「消えたのか未検査なのか」を区別できないため。
--   代わりに大きなプロジェクトでは遅い。
-- - 載せるのは "[CheckName]" 付きの行だけ。タグ無しの素の javac エラー (構文・型)
--   は jdtls も出すので、二重表示になる。
-- - 開いていないファイルの診断も bufadd (unlisted / 未ロード) で載せるので、
--   telescope の diagnostics などでプロジェクト全体を見られる。
-- :ErrorProne で手動実行もできる。
-- ============================================

local M = {}

local ns = vim.api.nvim_create_namespace('errorprone')
local severities = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    note = vim.diagnostic.severity.INFO,
}

local enabled_roots = {} -- root -> boolean (errorprone を使っているか) のキャッシュ
local jobs = {}          -- root -> 実行中の vim.system オブジェクト
local checked = {}       -- root -> 一度でも実行したか (開いた時点の初回実行用)

local function uses_errorprone(root)
    if enabled_roots[root] == nil then
        enabled_roots[root] = false
        -- ルート直下とサブプロジェクト (1 階層下) の build ファイルだけを見る
        for name, type in vim.fs.dir(root, { depth = 2 }) do
            if type == 'file' and vim.fs.basename(name):match('^build%.gradle') then
                local f = io.open(vim.fs.joinpath(root, name))
                if f then
                    local text = f:read('*a')
                    f:close()
                    if text:find('errorprone', 1, true) then
                        enabled_roots[root] = true
                        break
                    end
                end
            end
        end
    end
    return enabled_roots[root]
end

-- javac の出力 (Gradle 経由) を { [path] = { diagnostic, ... } } にする。
-- 1 件は「path:line: kind: [Check] message」の行と、それに続くソース行・キャレット行
-- (^ の位置が列)。コンパイル失敗時は Gradle が同じ出力を字下げして再掲するが、
-- 行頭アンカーで字下げ側は拾わない。
local function parse(output)
    local result = {}
    local lines = vim.split(output, '\n', { plain = true })
    for i, line in ipairs(lines) do
        local path, lnum, kind, check, msg = line:match('^(%S.-%.java):(%d+): (%a+): %[([%w:]+)%] (.*)$')
        if path and severities[kind] then
            local col = 0
            for j = i + 1, math.min(i + 3, #lines) do
                local caret = lines[j]:find('^%s*%^%s*$')
                if caret then
                    col = lines[j]:find('^', 1, true) - 1
                    break
                end
            end
            result[path] = result[path] or {}
            table.insert(result[path], {
                lnum = tonumber(lnum) - 1,
                col = col,
                severity = severities[kind],
                source = 'errorprone',
                code = check,
                message = msg,
            })
        end
    end
    return result
end

local function apply(root, output)
    -- 前回の結果をプロジェクト単位で消してから載せ直す
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.startswith(vim.fs.normalize(name), vim.fs.normalize(root) .. '/') then
            vim.diagnostic.reset(ns, buf)
        end
    end
    for path, diags in pairs(parse(output)) do
        vim.diagnostic.set(ns, vim.fn.bufadd(path), diags)
    end
end

function M.run(root)
    if jobs[root] then
        jobs[root]:kill('sigterm') -- 保存が続いたら古い実行は捨てる
    end
    checked[root] = true
    local job
    job = vim.system(
        { vim.fn.has('win32') == 1 and 'gradlew.bat' or './gradlew', 'compileJava', '--rerun', 'compileTestJava', '--rerun', '--console=plain' },
        { cwd = root, text = true },
        vim.schedule_wrap(function(res)
            if jobs[root] ~= job then
                return -- 後発の実行に置き換えられた
            end
            jobs[root] = nil
            local output = (res.stdout or '') .. '\n' .. (res.stderr or '')
            apply(root, output)
            -- コンパイル失敗以外 (Gradle 設定のエラー等) で落ちたときは診断が出ないので知らせる
            if res.code ~= 0 and not output:find('Compilation failed', 1, true) then
                vim.notify('errorprone: ./gradlew が失敗 (exit ' .. res.code .. ')', vim.log.levels.WARN)
            end
        end)
    )
    jobs[root] = job
end

local function root_of(buf)
    local root = vim.fs.root(buf, { 'gradlew' })
    if root and uses_errorprone(root) then
        return root
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup('ide_errorprone', { clear = true })
    vim.api.nvim_create_autocmd('BufWritePost', {
        group = group,
        pattern = '*.java',
        callback = function(ev)
            local root = root_of(ev.buf)
            if root then
                M.run(root)
            end
        end,
    })
    -- プロジェクトの Java ファイルを最初に開いたときにも 1 回走らせる
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = 'java',
        callback = function(ev)
            local root = root_of(ev.buf)
            if root and not checked[root] then
                M.run(root)
            end
        end,
    })
    vim.api.nvim_create_user_command('ErrorProne', function()
        local root = root_of(0)
        if not root then
            vim.notify('errorprone: gradlew と errorprone を使うプロジェクトではない', vim.log.levels.WARN)
            return
        end
        M.run(root)
    end, { desc = 'Run Error Prone via Gradle and load its diagnostics' })
end

return M

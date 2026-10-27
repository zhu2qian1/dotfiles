-- ============================================
-- 構文ハイライト : nvim-treesitter (main ブランチ)
-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
-- Neovim 本体に同梱されていないパーサの取得と、ハイライトの有効化だけを担う。
--
-- 動機は Svelte: runtime に svelte の syntax ファイルが無いので、.svelte には
-- 正規表現ハイライトすら掛からない。svelte-language-server の semantic tokens で
-- 識別子だけは色が付くが、キーワード・文字列・コメント・型注釈は無色のままになる。
-- svelte パーサは <script lang="ts"> / {式} / <style> を typescript / javascript /
-- css に injection するので、それらのパーサも揃えておく必要がある。
--
-- Go は Vim 同梱の正規表現 syntax でも色は付くが、型・関数呼び出し・フィールドの
-- 区別が付かないので treesitter に寄せる。go.mod / go.work / go.sum も専用パーサがある。
--
-- main ブランチはパーサを手元でビルドするため tree-sitter CLI (0.26.1+) と
-- C コンパイラが要る。Linux / WSL では `bash install-extra-tools.sh` が CLI を入れる
-- (README の "Neovim tree-sitter" 節)。npm 版は nvim-treesitter が非対応。旧 master ブランチの
-- `highlight = { enable = true }` のような module 設定は無く、ハイライトは
-- 組み込みの vim.treesitter.start() を FileType で呼んで有効にする。
-- ============================================

-- ここに書いた言語のパーサを入れ、その filetype では treesitter でハイライトする。
-- Neovim 同梱のパーサ (lua / markdown / vimdoc など) は本体が既に扱っているので書かない。
local langs = { 'svelte', 'typescript', 'tsx', 'javascript', 'html', 'css', 'go', 'gomod', 'gowork', 'gosum' }

-- パーサのビルドに要る道具が揃っているか。揃っていなければ理由を返す。
-- executable('tree-sitter') だけでは足りない: npm 版は install スクリプトが本体の
-- tree-sitter.exe を落とし損ねても shim (tree-sitter.cmd) だけは残るので 1 を返す。
-- なので実際に --version を実行して確かめる (呼ぶのは未インストール分があるときだけ)。
local function missing_build_tool()
    local ok, res = pcall(function()
        return vim.system({ 'tree-sitter', '--version' }, { text = true }):wait(5000)
    end)
    if not ok or res.code ~= 0 then
        return 'tree-sitter CLI が動かない'
    end
    -- tree-sitter build は $CC があればそれを、無ければ Windows では cl.exe
    -- (PATH に無くても Visual Studio の場所を自分で探す)、他では cc を使う。
    local cc = vim.env.CC
    if cc and cc ~= '' then
        if vim.fn.executable(vim.split(cc, ' ', { trimempty = true })[1]) == 1 then
            return nil
        end
    elseif vim.fn.has('win32') == 1 then
        local vswhere = vim.fs.joinpath(vim.env['ProgramFiles(x86)'] or '', 'Microsoft Visual Studio/Installer/vswhere.exe')
        if vim.fn.executable('cl') == 1 or vim.uv.fs_stat(vswhere) then
            return nil
        end
    elseif vim.fn.executable('cc') == 1 then
        return nil
    end
    return 'C コンパイラが無い'
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        -- README が遅延読み込みを非対応としているので起動時に読む
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- 未インストール分だけを非同期で取得・ビルドする。CLI やコンパイラが無いまま
            -- install() を呼ぶと、起動のたびに全言語分のソースを落としてからビルドの
            -- エラーを言語の数だけ出すので、その場合は 1 行の案内に留める。
            local ts = require('nvim-treesitter')
            local installed = ts.get_installed('parsers')
            local missing = vim.tbl_filter(function(lang)
                return not vim.list_contains(installed, lang)
            end, langs)
            if #missing > 0 then
                local reason = missing_build_tool()
                if not reason then
                    ts.install(missing)
                else
                    vim.notify(
                        reason .. 'のでパーサを入れられない: ' .. table.concat(missing, ', ')
                            .. '\n(Linux / WSL なら dotfiles で `bash install-extra-tools.sh`)',
                        vim.log.levels.WARN
                    )
                end
            end

            local filetypes = {}
            for _, lang in ipairs(langs) do
                vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
            end

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('ide_treesitter', { clear = true }),
                pattern = filetypes,
                callback = function(ev)
                    -- 初回起動時はビルドが終わるまでパーサが無いので失敗し得る。
                    -- その場合は従来のハイライトのまま開き、次にバッファを開いたときに効く。
                    if not pcall(vim.treesitter.start, ev.buf) then
                        return
                    end
                    -- 構文木から fold を作り、カーソルを置いた要素 (HTML ならタグ) を zc で
                    -- 閉じられるようにする。foldmethod は window-local なので、[0][0]
                    -- (このウィンドウでこのバッファを表示している間) に限って設定し、
                    -- 同じウィンドウで別の filetype を開いたときに expr が残らないようにする。
                    -- foldlevel を上げておかないと、開いた直後に全部閉じた状態になる。
                    vim.wo[0][0].foldmethod = 'expr'
                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldlevel = 99
                end,
            })
        end,
    },
}

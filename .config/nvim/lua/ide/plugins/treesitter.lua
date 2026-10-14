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
-- main ブランチはパーサを手元でビルドするため tree-sitter CLI (0.26.1+) と
-- C コンパイラが要る。Linux / WSL では `bash install-extra-tools.sh` が CLI を入れる
-- (README の "Neovim tree-sitter" 節)。npm 版は nvim-treesitter が非対応。旧 master ブランチの
-- `highlight = { enable = true }` のような module 設定は無く、ハイライトは
-- 組み込みの vim.treesitter.start() を FileType で呼んで有効にする。
-- ============================================

-- ここに書いた言語のパーサを入れ、その filetype では treesitter でハイライトする。
-- Neovim 同梱のパーサ (lua / markdown / vimdoc など) は本体が既に扱っているので書かない。
local langs = { 'svelte', 'typescript', 'tsx', 'javascript', 'html', 'css' }

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        -- README が遅延読み込みを非対応としているので起動時に読む
        lazy = false,
        build = ':TSUpdate',
        config = function()
            -- 未インストール分だけを非同期で取得・ビルドする。CLI が無いまま install() を
            -- 呼ぶと、起動のたびに全言語分のソースを落としてから ENOENT のエラーを
            -- 言語の数だけ出すので、その場合は 1 行の案内に留める。
            local ts = require('nvim-treesitter')
            local installed = ts.get_installed('parsers')
            local missing = vim.tbl_filter(function(lang)
                return not vim.list_contains(installed, lang)
            end, langs)
            if #missing > 0 then
                if vim.fn.executable('tree-sitter') == 1 then
                    ts.install(missing)
                else
                    vim.notify(
                        'tree-sitter CLI が無いのでパーサを入れられない: ' .. table.concat(missing, ', ')
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

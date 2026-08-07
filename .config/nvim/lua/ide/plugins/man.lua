-- ============================================
-- man ページ閲覧 : nvim-man (paretje/nvim-man)
-- 組み込みの :Man はテキストとして読み込んで自前ハイライトするため取りこぼしがあるが、
-- こちらは実際の `man` を :terminal 上で走らせるので見た目が端末と完全に一致する。
-- 端末モードのまま <C-w> でウィンドウ移動でき、less を q で抜けると窓も閉じる。
--
-- 要: `man` バイナリ。Windows ネイティブには無いので、その場合は spec ごと無効化し
--     組み込みの :Man を残す (下の early return)。
-- ============================================

-- man が無い環境 (Windows ネイティブ等) では何も入れない。
-- ここで return しておけば init/config も一切走らず、組み込み :Man がそのまま残る。
if vim.fn.executable('man') == 0 then
    return {}
end

return {
    {
        'paretje/nvim-man',
        cmd = { 'Man', 'Sman', 'Vman', 'Tman' },
        keys = {
            -- カーソル下の語を man で引く。count でセクション指定 (例: 3<leader>m)
            { '<leader>m',  '<Plug>(Man)',  desc = 'man: カーソル下の語' },
            { '<leader>Ms', '<Plug>(Sman)', desc = 'man: カーソル下の語 (水平分割)' },
            { '<leader>Mv', '<Plug>(Vman)', desc = 'man: カーソル下の語 (垂直分割)' },
            { '<leader>Mt', '<Plug>(Tman)', desc = 'man: カーソル下の語 (新規タブ)' },
        },
        init = function()
            -- 組み込み man プラグイン ($VIMRUNTIME/plugin/man.lua) を無効化する。
            -- これをやらないと init.lua の後に読まれる組み込み側が :Man を上書きし、
            -- lazy.nvim が cmd 遅延読み込み用に張ったスタブが消えて本体が読まれない。
            -- (nvim-man 自身も plugin/man.vim で同じ変数を立てるが、その時点では手遅れ)
            vim.g.loaded_man = 1

            -- 既定の開き方: horizontal / vertical / tab / current
            vim.g.nvim_man_default_target = 'vertical'

            -- プラグイン既定値は '/usr/bin/man' 決め打ち。PATH 上の man を使う。
            -- less の -+F は --quit-if-one-screen 相当の自動終了を打ち消し、
            -- -c は上から書き直す (端末を汚さない) 指定。
            vim.g.vim_man_cmd = vim.fn.exepath('man') .. ' -P "less -+F -c"'
        end,
        config = function()
            -- nvim-man の :Man 等は補完に autoload 関数 man#complete を指定しているが、
            -- これは Neovim 0.9 で runtime から消えて lua の man モジュールに移った。
            -- そのまま使うと <Tab> で E117 になるので、コマンドを張り直して補完だけ差し替える。
            local complete = function(arg_lead, cmd_line, cursor_pos)
                return require('man').man_complete(arg_lead, cmd_line, cursor_pos)
            end

            local targets = {
                Man  = vim.g.nvim_man_default_target,
                Sman = 'horizontal',
                Vman = 'vertical',
                Tman = 'tab',
            }

            for name, target in pairs(targets) do
                vim.api.nvim_create_user_command(name, function(opts)
                    vim.fn['man#terminal#get_page'](target, unpack(opts.fargs))
                end, {
                    nargs = '*',
                    bar = true,
                    complete = complete,
                    desc = 'man page (' .. target .. ')',
                })
            end
        end,
    },
}

local autocmd = vim.api.nvim_create_autocmd

-- Windows specific
if vim.fn.has('win32') == 1 then
    vim.opt.shell = 'powershell.exe'
    vim.opt.shellxquote = ''
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
    vim.opt.shellquote = ''
    vim.opt.shellpipe = '| Out-File -Encoding UTF8 %s'
    vim.opt.shellredir = '| Out-File -Encoding UTF8 %s'
end

-- WSL: クリップボードプロバイダを win32yank に固定する。
-- Neovim の自動検出は xsel を win32yank より先に試し、しかもその判定条件が
-- `xsel -o -b` の実行そのもの。WSLg の X クリップボードは応答を返さないため
-- ここでブロックし、起動が暗転したまま止まる (Ctrl-C で解除されて画面が出る)。
-- g:clipboard を文字列で指定すると自動検出を丸ごと飛ばせる。
if vim.fn.has('wsl') == 1 and vim.fn.executable('win32yank.exe') == 1 then
    vim.g.clipboard = 'win32yank'
end

-- Disable IME on leaving Insert mode (Windows / WSL)
if vim.fn.has('win32') == 1 or vim.fn.has('wsl') == 1 then
    autocmd('InsertLeave', {
        pattern = '*',
        callback = function() vim.fn.jobstart('zenhan.exe 0') end,
    })
-- Linuxの場合
elseif vim.fn.has('linux') == 1 then
    autocmd('InsertLeave', {
        pattern = '*',
        callback = function() vim.fn.jobstart('fcitx5-remote -o') end,
    })
end

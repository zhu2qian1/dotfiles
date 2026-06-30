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

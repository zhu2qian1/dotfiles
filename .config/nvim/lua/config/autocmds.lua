local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Filetype mapping
augroup('custom_extension_match', { clear = true })
autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.bat_', '*.bat.txt', '*.batx' },
    command = 'set filetype=dosbatch',
})
autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.sql_' },
    command = 'set filetype=sql',
})
autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.md.txt', '*.gij', '*.gij.md', '*.gij.txt' },
    command = 'set filetype=markdown',
})
autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = '*.vbs_',
    command = 'set filetype=vb',
})

-- Markdown-specific settings live in ftplugin/markdown.lua

-- Quickfix open after vimgrep
autocmd('QuickfixCmdPost', {
    pattern = 'vimgrep',
    command = 'copen',
})

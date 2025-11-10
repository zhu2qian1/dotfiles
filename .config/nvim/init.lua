-- needs to be updated

-- Skip default settings
vim.g.vim_skip_defaults = 1

-- Keymaps
vim.keymap.set('i', '<Esc>', '<Esc>:set iminsert=0<CR>', { silent = true })

-- General settings
vim.cmd.colorscheme('evening')
vim.opt.clipboard = 'unnamed'
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')

vim.opt.autochdir = true
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'ucs-bom', 'utf-8', 'default', 'cp932' }

vim.opt.shortmess = 'aoOT'
vim.opt.laststatus = 2
vim.opt.statusline = '%02n %r%w%y %m%t%<%=[%B] [%{&fenc}] %l/%L'

vim.opt.virtualedit = 'block'
vim.opt.whichwrap = 'b,s,[,],<,>'
vim.opt.shellslash = true
vim.opt.swapfile = false
vim.opt.belloff = 'all'
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.cursorline = true
vim.opt.matchpairs:append({ '「:」', '【:】', '『:』', '《:》', '≪:≫', '〔:〕', '［:］', '（:）' })

-- Windows specific
--if vim.fn.has('win32') == 1 then
--  vim.opt.shell = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe'
--end

-- Tab settings
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- Indent settings
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.smarttab = true

-- Appearance
vim.opt.ambiwidth = 'double'
vim.opt.hlsearch = true
vim.opt.list = true
vim.opt.listchars = { tab = '^\\ ', trail = '~' }
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.scrolloff = 8

-- Search settings
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- ============================================
-- Autocommands
-- ============================================
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

-- Markdown-specific
augroup('markdown_custom_settings', { clear = true })
autocmd('FileType', {
  pattern = 'markdown',
  command = 'set conceallevel=2 et shiftwidth=2 softtabstop=2 tabstop=2',
})
autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('n', '<Tab>', '>>', { buffer = true })
    vim.keymap.set('n', '<S-Tab>', '<<', { buffer = true })
    vim.keymap.set('n', 'o', 'A<CR>', { buffer = true })
  end,
})

-- Quickfix open after vimgrep
autocmd('QuickfixCmdPost', {
  pattern = 'vimgrep',
  command = 'copen',
})

-- ============================================
-- Commands
-- ============================================
vim.api.nvim_create_user_command('F2h', '%s/　/  /gc', {})
vim.api.nvim_create_user_command('T2S', '%s/\\t/    /gc', {})
vim.api.nvim_create_user_command('History', 'browse oldfiles', {})
vim.api.nvim_create_user_command('HtmlFlatten', '%s/>\\s*/>\\r/gc', {})
vim.api.nvim_create_user_command('Here', 'cd %:p:h', {})
vim.api.nvim_create_user_command('HereExplore', 'Explore %:p:h', {})
vim.api.nvim_create_user_command('HereEdit', 'e %:p:h', {})
vim.api.nvim_create_user_command('Easy', 'source $VIMRUNTIME/evim.vim', {})

-- Leader key
vim.g.mapleader = ' '

-- ============================================
-- Insert mode shortcuts
-- ============================================
vim.keymap.set('i', '<F5>', '<C-R>=strftime("%Y-%m-%d")<CR>')
vim.keymap.set('i', '<F6>', '<C-R>=strftime("%H:%M:%S")<CR>')

vim.keymap.set('n', '<leader>;;', ':norm i<C-R>=strftime("%Y-%m-%d")<CR><CR>')
vim.keymap.set('n', '<leader>;:', ':norm i<C-R>=strftime("%H:%M:%S")<CR><CR>')
vim.keymap.set('n', '<leader>;dt', ':norm i<C-R>=strftime("%Y-%m-%d")." ".strftime("%H:%M:%S")<CR><CR>')

-- Clipboard shortcuts
vim.keymap.set('v', '<C-c>', '"+y:echo "copied to clipboard."<CR>', { silent = true })
vim.keymap.set('v', '<C-x>', '"+d:echo "cut to clipboard."<CR>', { silent = true })
vim.keymap.set('v', '<C-v>', '"+p:echo "pasted from clipboard."<CR>', { silent = true })
vim.keymap.set('n', '<C-v>', '"+p:echo "pasted from clipboard."<CR>', { silent = true })

-- File edit shortcuts
vim.keymap.set('n', '<leader>,v', ':e $HOME/AppData/Local/nvim/init.lua<CR>')
-- vim.keymap.set('n', '<leader>,g', ':e $HOME/.gvimrc<CR>')

-- Insert expression
vim.keymap.set('n', '<leader>ir', 'i<C-R>=')

-- Movement
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')

-- Selection
vim.keymap.set('v','v','<esc><c-v>')
vim.keymap.set('v',',','<esc>GVgg')

-- Prevent register overwrite
vim.keymap.set({ 'n', 'v' }, 'c', '"_c')
vim.keymap.set(  'n'       , 'C', '"_C')
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')
vim.keymap.set({ 'n', 'v' }, 'X', '"_dd')

-- Search behavior
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '<F3>', 'n')
vim.keymap.set('n', '<S-F3>', 'N')

vim.keymap.set('v', '*', 'y/<C-r>"<CR>:set hls<CR>')
vim.keymap.set('n', '*', ':setlocal hls<CR>*')
vim.keymap.set('n', '/', ':setlocal hls<CR>/')

-- Redo = U
vim.keymap.set('n', 'U', '<C-r>')

-- Toggle hlsearch
vim.keymap.set('n', '<Esc><Esc>', ':setlocal hls!<CR>', { silent = true })

-- Indent staying in visual mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Tabs
vim.keymap.set('n', '<leader>N', ':tabe<CR>')
vim.keymap.set('n', '<leader>[', 'gT<CR>')
vim.keymap.set('n', '<leader>]', 'gt<CR>')

-- Toggles
local toggles = {
  tcl = 'cul',
  th = 'hls',
  tw = 'wrap',
  tnr = 'rnu',
  tnn = 'nu',
}
for k, v in pairs(toggles) do
  vim.keymap.set('n', '<leader>' .. k, ':setlocal ' .. v .. '! ' .. v .. '?<CR>')
end

-- Indent width presets
for i, n in ipairs({ 2, 4, 8, 16, 32 }) do
  vim.keymap.set('n', string.format('<leader>tt%d', i), string.format(':setlocal sts=%d ts=%d sw=%d<CR>', n, n, n))
end

vim.keymap.set('n', '<leader>so', ':source %<CR>:echo "sourced the current file."<CR>')

-- Window navigation
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>l', '<C-w>l')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')

-- Window sizing
vim.keymap.set('n', '<leader>ww', '<C-w>150|')
vim.keymap.set('n', '<leader>w=', '<C-w>=<CR>')

-- Easy copy/paste
vim.keymap.set('v', '<leader>c', '"+y:echo "copied to clipboard."<CR>')
vim.keymap.set('v', '<leader>x', '"+d:echo "cut to clipboard."<CR>')
vim.keymap.set('n', '<leader>v', '"+p:echo "pasted from clipboard."<CR>')
vim.keymap.set('n', '<leader>V', '"+P:echo "pasted from clipboard."<CR>')
vim.keymap.set('v', '<leader>v', '"+p:echo "pasted from clipboard."<CR>')
vim.keymap.set('v', '<leader>V', '"+P:echo "pasted from clipboard."<CR>')

-- Explorer shortcuts
vim.keymap.set('n', '<leader>el', ':Lexplore<CR>')
vim.keymap.set('n', '<leader>ee', ':Explore<CR>')
vim.keymap.set('n', '<leader>eh', ':Hexplore<CR>')
vim.keymap.set('n', '<leader>es', ':Sexplore<CR>')
vim.keymap.set('n', '<leader>ew', ':w<CR>:Explore<CR>')

-- Misc set shortcuts
vim.keymap.set('n', '<leader>::', ':set ')
vim.keymap.set('n', '<leader>:f', ':set filetype=')
vim.keymap.set('n', '<leader>:e', ':set encoding=')

-- -- gVim-specific (font)
-- vim.keymap.set('n', '<leader>,,', ':set gfn=*<CR>')

-- ============================================
-- Startup behavior
-- ============================================
if vim.fn.argc() == 0 then
  vim.cmd('cd ~')
end

-- Local config
if vim.fn.filereadable(vim.fn.expand('~/.vimrc_local')) == 1 then
  vim.cmd('source ~/.vimrc_local')
end

-- Disable IME on entering Normal mode via Esc
vim.keymap.set('i', '<Esc>', '<Esc>:set iminsert=0<CR>', { silent = true })

-- ============================================
-- Insert mode shortcuts
-- ============================================
vim.keymap.set('i', '<F5>', '<C-R>=strftime("%Y-%m-%d")<CR>')
vim.keymap.set('i', '<F6>', '<C-R>=strftime("%H:%M:%S")<CR>')

vim.keymap.set('n', '<leader>;;', ':norm i<C-R>=strftime("%Y-%m-%d")<CR><CR>')
vim.keymap.set('n', '<leader>;:', ':norm i<C-R>=strftime("%H:%M:%S")<CR><CR>')
vim.keymap.set('n', '<leader>;dt', ':norm i<C-R>=strftime("%Y-%m-%d")." ".strftime("%H:%M:%S")<CR><CR>')

-- Clipboard shortcuts (shared rhs for Ctrl- and <leader>- mappings)
local clip = {
    copy  = '"+y:echo "copied to clipboard."<CR>',
    cut   = '"+d:echo "cut to clipboard."<CR>',
    paste = '"+p:echo "pasted from clipboard."<CR>',
    Paste = '"+P:echo "pasted from clipboard."<CR>',
}

local clip_opts = { silent = true, noremap = true }
vim.keymap.set('v', '<C-c>', clip.copy,  clip_opts)
vim.keymap.set('v', '<C-x>', clip.cut,   clip_opts)
vim.keymap.set('v', '<C-v>', clip.paste, clip_opts)
vim.keymap.set('n', '<C-v>', clip.paste, clip_opts)

-- File edit shortcuts
vim.keymap.set('n', '<leader>,v', ':e ' .. vim.fn.stdpath('config') .. '/init.lua<CR>', { noremap = true })
-- vim.keymap.set('n', '<leader>,g', ':e $HOME/.gvimrc<CR>')

-- Insert expression
vim.keymap.set('n', '<leader>ir', 'i<C-R>=', { noremap = true })

-- Movement
vim.keymap.set({ 'n', 'v' }, 'H', '^', { noremap = true })
vim.keymap.set({ 'n', 'v' }, 'L', '$', { noremap = true })

-- Selection
vim.keymap.set('v', 'v', '<esc><c-v>', { noremap = true })
vim.keymap.set('v', ',', '<esc>GVgg',  { noremap = true })

-- Prevent register overwrite
vim.keymap.set({ 'n', 'v' }, 'c', '"_c',  { noremap = true })
vim.keymap.set(  'n'       , 'C', '"_C',  { noremap = true })
vim.keymap.set({ 'n', 'v' }, 'x', '"_x',  { noremap = true })
vim.keymap.set({ 'n', 'v' }, 'X', '"_dd', { noremap = true })

-- Search behavior
vim.keymap.set('n', '<F3>', 'n',   { noremap = true })
vim.keymap.set('n', '<S-F3>', 'N', { noremap = true })

vim.keymap.set('v', '*', 'y/<C-r>"<CR>:set hls<CR>', { noremap = true })
vim.keymap.set('n', '*', ':setlocal hls<CR>*',       { noremap = true })
vim.keymap.set('n', '/', ':setlocal hls<CR>/',       { noremap = true })

-- Redo = U
vim.keymap.set('n', 'U', '<C-r>', { noremap = true })

-- Toggle hlsearch
vim.keymap.set('n', '<Esc><Esc>', ':setlocal hls!<CR>', { silent = true, noremap = true })

-- Indent staying in visual mode
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Tabs
vim.keymap.set('n', '<leader>N', ':tabe<CR>')
vim.keymap.set('n', '<leader>[', 'gT<CR>')
vim.keymap.set('n', '<leader>]', 'gt<CR>')

-- Toggles
local toggles = {
    cl = 'cul',
    h = 'hls',
    w = 'wrap',
    nr = 'rnu',
    nn = 'nu',
}
for k, opt in pairs(toggles) do
    vim.keymap.set('n', '<leader>t' .. k, ':setlocal ' .. opt .. '! ' .. opt .. '?<CR>')
end

-- Indent width presets
for i, n in ipairs({ 2, 4, 8, 16, 32 }) do
    vim.keymap.set('n', string.format('<leader>tt%d', i), string.format(':setlocal sts=%d ts=%d sw=%d<CR>', n, n, n))
end

-- utils
vim.keymap.set('n', '<leader>so', ':update<CR> :source<CR>:echo "sourced the current file."<CR>')
vim.keymap.set('n', '<leader>wr', ':write<CR>')
vim.keymap.set('n', '<leader>qu', ':quit<CR>')

-- Window navigation
vim.keymap.set('n', '<leader>h', '<C-w>h')
vim.keymap.set('n', '<leader>l', '<C-w>l')
vim.keymap.set('n', '<leader>j', '<C-w>j')
vim.keymap.set('n', '<leader>k', '<C-w>k')

-- Window sizing
vim.keymap.set('n', '<leader>ww', '<C-w>150|')
vim.keymap.set('n', '<leader>w=', '<C-w>=<CR>')

-- Easy copy/paste
vim.keymap.set('v', '<leader>c', clip.copy)
vim.keymap.set('v', '<leader>x', clip.cut)
vim.keymap.set({ 'n', 'v' }, '<leader>v', clip.paste)
vim.keymap.set({ 'n', 'v' }, '<leader>V', clip.Paste)

-- Misc set shortcuts
vim.keymap.set('n', '<leader>::', ':set ')
vim.keymap.set('n', '<leader>:f', ':set filetype=')
vim.keymap.set('n', '<leader>:e', ':set encoding=')

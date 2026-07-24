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
    c = 'cul',
    h = 'hls',
    w = 'wrap',
    n = 'nu',
}
for k, opt in pairs(toggles) do
    vim.keymap.set('n', '<leader>t' .. k, ':setlocal ' .. opt .. '! ' .. opt .. '?<CR>')
end

-- utils
vim.keymap.set('n', '<leader>so', ':update<CR> :source<CR>:echo "sourced the current file."<CR>')
vim.keymap.set('n', '<leader>wr', ':write<CR>')
vim.keymap.set('n', '<leader>qu', ':quit<CR>')

-- Explorer
vim.keymap.set('n', '<leader>ee', ':Explore<CR>')
vim.keymap.set('n', '<leader>el', ':Lexplore<CR>')


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

-- Easy copy/paste
vim.keymap.set('v', '<leader>c', clip.copy)
vim.keymap.set('v', '<leader>x', clip.cut)
vim.keymap.set({ 'n', 'v' }, '<leader>v', clip.paste)
vim.keymap.set({ 'n', 'v' }, '<leader>V', clip.Paste)

-- Explorer
vim.keymap.set('n', '<leader>ee', ':Explore<CR>')
vim.keymap.set('n', '<leader>el', ':Lexplore<CR>')

-- terminal
vim.keymap.set('t', '<C-w><ESC>', '<C-\\><C-n>')
vim.keymap.set('t', '<C-w>h', '<CMD>wincmd h<CR>')
vim.keymap.set('t', '<C-w>j', '<CMD>wincmd j<CR>')
vim.keymap.set('t', '<C-w>k', '<CMD>wincmd k<CR>')
vim.keymap.set('t', '<C-w>l', '<CMD>wincmd l<CR>')


-- ============================================
-- man
-- 組み込みの :Man で開く。man の出力を通常のバッファとして読むので、
-- バッファ内で CTRL-] : カーソル下の printf(3) 等へジャンプ (tagfunc)
--              CTRL-T : 元のページへ戻る
--              gO     : 見出し一覧 (location list)
--              q      : 閉じる
-- K は既定の keywordprg=:Man でそのまま引ける。
-- ============================================
-- count でセクションを指定できるようにする (例: 3<leader>m で printf(3))。
-- :vertical 3Man のように mods -> count -> Man の順で組み立てる。
local function man_open(mods)
    return function()
        local count = vim.v.count > 0 and tostring(vim.v.count) or ''
        local ok, err = pcall(vim.cmd, mods .. ' ' .. count .. 'Man')
        if not ok then
            vim.notify(err, vim.log.levels.WARN)
        end
    end
end

vim.keymap.set('n', '<leader>m',  man_open('vertical'),   { desc = 'man: カーソル下の語 (垂直分割)' })
vim.keymap.set('n', '<leader>Ms', man_open('horizontal'), { desc = 'man: カーソル下の語 (水平分割)' })
vim.keymap.set('n', '<leader>Mv', man_open('vertical'),   { desc = 'man: カーソル下の語 (垂直分割)' })
vim.keymap.set('n', '<leader>Mt', man_open('tab'),        { desc = 'man: カーソル下の語 (新規タブ)' })

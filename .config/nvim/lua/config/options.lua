-- General settings
-- vim.cmd.colorscheme('desert')
vim.cmd.colorscheme('catppuccin')

vim.opt.signcolumn = "yes"
-- vim.opt.winborder = "rounded"
vim.opt.clipboard = 'unnamedplus'

vim.opt.autochdir = true

vim.opt.shortmess = 'aoOTIF'
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
-- Ambiguous 幅文字の扱い。
-- claude Code CLI などターミナル内 TUI と幅計算を合わせるため 'single' 固定。
-- ('double' にすると Neovim だけが 2 セル計算になり Windows Terminal / TUI とズレる)
vim.opt.ambiwidth = 'single'
-- そのうえで Nerd Font アイコン(私用領域 = Ambiguous 扱い)だけを幅 2 に固定し、
-- ambiwidth に依存せずアイコンの表示ズレを防ぐ。崩れる文字があれば範囲を追記する。
vim.fn.setcellwidths({
    -- Powerline / Powerline Extra
    { 0xe0a0, 0xe0a2, 2 }, { 0xe0b0, 0xe0b3, 2 },
    -- Nerd Font 主要ブロック (Seti / Devicons / Codicons / Font Awesome / Octicons など)
    { 0xe5fa, 0xe6b7, 2 }, { 0xe700, 0xe8ef, 2 }, { 0xea60, 0xebeb, 2 },
    { 0xed00, 0xf2ff, 2 }, { 0xf300, 0xf532, 2 },
    -- Material Design Icons (補助面)
    { 0xf0001, 0xf1af0, 2 },
})
vim.opt.hlsearch = true
vim.opt.list = true
-- vim.opt.listchars = { tab = '^ ', trail = '~' }
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.scrolloff = 8

-- Search settings
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

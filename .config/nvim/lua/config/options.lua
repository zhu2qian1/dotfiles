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
-- vim.opt.ambiwidth = 'double'
vim.opt.hlsearch = true
vim.opt.list = true
vim.opt.listchars = { tab = '^ ', trail = '~' }
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.scrolloff = 8

-- Search settings
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

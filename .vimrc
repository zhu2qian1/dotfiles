" skip defaults.vim
let skip_defaults_vim = 1

filetype plugin indent on
syntax on

set backspace=indent,eol,start
set cursorline

set encoding=utf-8

" listchars
set list
set listchars=
" set listchars+=tab:« »
" set listchars+=tab:»\
set listchars+=tab:^\
set listchars+=trail:~

set scrolloff=8

" allow Japanese input
set noimdisable
if v:progname =~? "gvim" || v:progname =~? "vim"
	inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

" tab settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" indent settings
set smartindent
set autoindent
set smarttab

" number settings
set number
set norelativenumber

" search settings
set incsearch

set smartcase

set ambiwidth=double

" directory setting
set backupdir=~/vim/tmpfiles//
set directory=~/vim/tmpfiles//
set undodir  =~/vim/tmpfiles//

set wrap

" load my autocmd
let autoCmdFile = expand('~/vim/_myautocmd.vim')
if filereadable(autoCmdFile)
  exec "source " . autoCmdFile
endif

" load my keymap
let keyMapFile = expand('~/vim/_mykeymap.vim')
if filereadable(keyMapFile)
  exec "source " . keyMapFile
endif

"---------------------------------------------------------------------------
"   my own commands
command! F2h :%s/　/  /gc
command! T2S :%s/\t/    /gc
command! HtmlFlatten :%s/>\s*/>\r/gc
if has('win32') && &shell =~? "C:\\Windows\\system32\\cmd.exe"
  command! Today :r! echo \%date:/=-\%
  command! Now :r! echo \%time\%
endif

runtime! autoload/pathogen.vim
if exists("*pathogen#infect")
    call pathogen#infect()
    call pathogen#helptags()
    nnoremap <leader>el :NERDTree<CR>
    nnoremap <leader>ee :NERDTreeExplore<CR>
endif


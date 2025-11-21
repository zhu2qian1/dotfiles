" skip the default settings
let g:vim_skip_defaults=1

inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
if has('mouse')
    set clipboard=unnamed
endif

filetype plugin indent on
syntax on
set autochdir

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,default,cp932

set shortmess=aoOTIF
set laststatus=2
set statusline=%02n\ %r%w%y\ %m%t\%<%=[%B]\ [%{&fenc}]\ %l/%L

set virtualedit=block
set whichwrap=b,s,[,],<,>
set shellslash
set noswf

if has('win32')
    set shell=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
endif

set belloff=all

set backspace=indent,eol,start
set nocursorline

" allow Japanese input
set noimdisable

set matchpairs+=「:」,【:】,『:』,《:》,≪:≫,〔:〕,［:］,（:）

" tab settings
set noexpandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" indent settings
" set smartindent
" set autoindent
" set smarttab

" editor appearance
set ambiwidth=double
set list
set listchars=tab:^\ ,trail:~
set norelativenumber
set number
set nowrap
set scrolloff=8

" search settings
set hlsearch
set incsearch
set ignorecase
set smartcase

augroup  custom_extension_match
    autocmd!
    autocmd BufNewFile,BufRead *.bat_     set filetype=dosbatch
    autocmd BufNewFile,BufRead *.bat.txt  set filetype=dosbatch
    autocmd BufNewFile,BufRead *.batx     set filetype=dosbatch
    autocmd BufNewFile,BufRead *.sql_     set filetype=sql
    autocmd BufNewFile,BufRead *.md.txt   set filetype=markdown
    autocmd BufNewFile,BufRead *.gij      set filetype=markdown
    autocmd BufNewFile,BufRead *.gij.md   set filetype=markdown
    autocmd BufNewFile,BufRead *.gij.txt  set filetype=markdown
    autocmd BufNewFile,BufRead *.vbs_     set filetype=vb
augroup end

augroup  markdown_custom_settings
    autocmd!
    autocmd FileType markdown setlocal conceallevel=2 et shiftwidth=2 softtabstop=2 tabstop=2
    autocmd FileType markdown nnoremap <buffer> <Tab> >>
    autocmd FileType markdown nnoremap <buffer> <s-Tab> <<
    autocmd FileType markdown nnoremap <buffer> o A<CR>
augroup end

" custom autocmd
autocmd QuickfixCmdPost vimgrep copen

"---------------------------------------------------------------------------
"   my own commands
command! F2h         :%s/　/  /gc
command! C2t         :%s/,/\t/gc
command! History     :browse oldfiles
command! HtmlFlatten :%s/>\s*/>\r/gc
command! Here        :cd %\/..
command! HereExplore :Explore %\/..
command! HereEdit    :e %\/..
command! HereExplore :e %\/..
command! Easy        :source $VIMRUNTIME/evim.vim
command! Conf        :e $HOME/.vimrc
command! NvimConf    :e $HOME/AppData/Local/nvim/init.lua
command! Hwscr       :exec "se so=" . (&lines/2)

let mapleader="\<space>"

inoremap <F5> <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <F6> <C-R>=strftime("%H:%M:%S")<CR>
nnoremap <leader>;; :norm i<C-R>=strftime("%Y-%m-%d")<CR><CR>
nnoremap <leader>;: :norm i<C-R>=strftime("%H:%M:%S")<CR><CR>
nnoremap <leader>;dt :norm i<C-R>=strftime("%Y-%m-%d")." ".strftime("%H:%M:%S")<CR><CR>

vnoremap <C-C> "+y:echo "copied to clipboard."<CR>
vnoremap <C-X> "+d:echo "cut to clipboard"<CR>
vnoremap <C-V> "+p:echo "pasted from clipboard."<CR>
nnoremap <C-V> "+p:echo "pasted from clipboard."<CR>

" jump edit .vimrc and .gvimrc
" nnoremap <leader>,v :e $HOME/AppData/Local/nvim/init.lua<CR>
nnoremap <leader>,v :e $HOME/.vimrc<CR>
nnoremap <leader>,g :e $HOME/.gvimrc<CR>

" insert ex command result
nnoremap <leader>ir i<C-R>=

" H and L to Head, taiL
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $

" c does not overwrite registers
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C

" x does not cut into registers
nnoremap x "_x
vnoremap x "_x
nnoremap X "_dd
vnoremap X "_dd

" F3 for next search results without centering
nnoremap   <F3> nzz
nnoremap <S-F3> Nzz

" v_vv to enter v-block mode
vnoremap v <C-v>

" v_v, to select all
vnoremap , <ESC>ggVG

" search selection
vnoremap * y/<C-r>"<CR>:setlocal hls<CR>

" enable hls when * or / is pressed
nnoremap * :setlocal hls<CR>*
nnoremap / :setlocal hls<CR>/

" redo=U
nnoremap U <C-r>

" toggle hlsearch
nnoremap <silent> <ESC><ESC> :setlocal hls!<CR>

" change indentation
vnoremap < <gv
vnoremap > >gv

" new tab
nnoremap <leader>N :tabe<CR>

" tab movning
nnoremap <leader>[ gT<CR>
nnoremap <leader>] gt<CR>

" toggle commands
nnoremap <leader>tcl :setlocal cul!   cul?<CR>
nnoremap <leader>th  :setlocal hls!   hls?<CR>
nnoremap <leader>tw  :setlocal wrap!  wrap?<CR>
nnoremap <leader>tnr :setlocal rnu!   rnu?<CR>
nnoremap <leader>tnn :setlocal nu!    nu?<CR>
nnoremap <leader>tte :setlocal et!    et?<CR>
nnoremap <leader>tt1 :setlocal sts=2  ts=2  sw=2 <CR>
nnoremap <leader>tt2 :setlocal sts=4  ts=4  sw=4 <CR>
nnoremap <leader>tt3 :setlocal sts=8  ts=8  sw=8 <CR>
nnoremap <leader>tt4 :setlocal sts=16 ts=16 sw=16<CR>
nnoremap <leader>tt5 :setlocal sts=32 ts=32 sw=32<CR>

" source
nnoremap <leader>so :source %<CR>:echo "sourced the current file."<CR>

" pane moving
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k

" pane sizing
nnoremap <leader>ww <C-w>150<bar>
nnoremap <leader>w= <C-w>=<CR>

" easy copy and paste
vnoremap <leader>c "+y:echo "copied to clipboard."<CR>
vnoremap <leader>x "+d:echo "cut to clipboard."<CR>
nnoremap <leader>v "+p:echo "pasted from clipboard."<CR>
nnoremap <leader>V "+P:echo "pasted from clipboard."<CR>
vnoremap <leader>v "+p:echo "pasted from clipboard."<CR>
vnoremap <leader>V "+P:echo "pasted from clipboard."<CR>

" Left explorer
nnoremap <leader>el :Lexplore<CR>
nnoremap <leader>ee :Explore<CR>
nnoremap <leader>eh :Hexplore<CR>
nnoremap <leader>es :Sexplore<CR>
nnoremap <leader>ew :w<CR>:Explore<CR>

nnoremap <leader>:: :set 
nnoremap <leader>:f :set filetype=
nnoremap <leader>:e :set encoding=

" gVim-specific settings {{{
" font setting shortcut
nnoremap <leader>,, :set gfn=*<CR>
" }}}

" cd to ~/ when no arguments are given
if argc() == 0
  execute 'cd ~/'
endif

" load local settings if exists
if filereadable(expand('~/.vimrc_local'))
  source ~/.vimrc_local
endif

" extensions
let g:vim_markdown_folding_disabled = 1
let g:netrw_browsex_viewer = "msedge"

" vim: set fdm=syntax:

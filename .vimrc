" skip the default settings
let g:vim_skip_defaults=1
"
" ---- plugs ---- {{{
" using [Pathogen](https://github.com/tpope/vim-pathogen)
" refer to ~/vimfiles/bundle
execute pathogen#infect()

let g:vim_markdown_folding_disabled = 1
let g:netrw_browsex_viewer = "msedge"
" }}}

filetype plugin indent on
syntax on

" ---- options ---- {{{
set clipboard=unnamed

set autochdir

set fileencodings=ucs-bom,utf-8,default,cp932 encoding=utf-8

set shortmess=aoOTIF
set laststatus=2 statusline=%02n\ %r%w%y\ %m%t\%<%=[%B]\ [%{&fenc}]\ %l/%L

set virtualedit=block
set whichwrap=b,s,[,],<,>
set noswf nobackup

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
set tabstop=4 softtabstop=4 shiftwidth=4

" indent settings
set smartindent autoindent smarttab

" editor appearance
set ambiwidth=double
set list
set listchars=tab:^\ ,trail:~
set norelativenumber number
set nowrap
set scrolloff=8

" search settings
set hlsearch incsearch
set ignorecase smartcase
" }}}

" ---- autocmds ---- {{{
augroup  custom_extension_match
	autocmd!
	autocmd BufNewFile,BufRead *.bat_,*bat.txt setfiletype dosbatch
	autocmd BufNewFile,BufRead *.sql_          setfiletype sql
	autocmd BufNewFile,BufRead *.md.txt        setfiletype markdown
	autocmd BufNewFile,BufRead *.vbs_          setfiletype vb
augroup end

augroup  markdown_custom_settings
	autocmd!
	autocmd FileType markdown setlocal conceallevel=2 et sw=2 sts=2 ts=2
	autocmd FileType markdown nnoremap <buffer> o A<CR>
augroup end

" custom autocmd
autocmd QuickfixCmdPost vimgrep copen
" }}}

" ---- commands ---- {{{
command! F2h         :%s/　/  /gc
command! C2t         :%s/,/\t/gc
command! History     :browse oldfiles
command! HtmlFlatten :%s/>\s*/>\r/gc
command! Here        :cd %\/..
command! HereEdit    :e %\/..
command! Easy        :source $VIMRUNTIME/evim.vim
command! NoEasy      :source $HOME/.vimrc
command! Conf        :e $HOME/.vimrc
command! NvimConf    :e $HOME/AppData/Local/nvim/init.lua
command! Hwscr       :exec "se so=" . (&lines/2)
" }}}

" ---- keymaps ---- {{{
let mapleader="\<space>"

inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
inoremap <F5> <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <F6> <C-R>=strftime("%H:%M:%S")<CR>

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

nnoremap   <F3> nzz
nnoremap <S-F3> Nzz

" v_v (n_vv) to enter v-block mode
vnoremap v <C-v>

" v_, (n_v,) to select all
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
vnoremap > >gv
vnoremap < <gv
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
nnoremap <Tab> >>
nnoremap <S-Tab> <<

" keymaps with leader key {{{
" tab movning
nnoremap <leader>n gt<CR>
nnoremap <leader>N gT<CR>

" datetime
nnoremap <leader>;; :norm i<C-R>=strftime("%Y-%m-%d")<CR><CR>
nnoremap <leader>;: :norm i<C-R>=strftime("%H:%M:%S")<CR><CR>
nnoremap <leader>;dt :norm i<C-R>=strftime("%Y-%m-%d")." ".strftime("%H:%M:%S")<CR><CR>

" insert ex command result
nnoremap <leader>ir i<C-R>=

" file manipulation
nnoremap <silent> <leader>ww :write<CR>
nnoremap <silent> <leader>so :update<CR>:source %<CR>:echo "sourced the current file."<CR>

" pane moving
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k

" Left explorer
nnoremap <leader>el :Lexplore<CR>
nnoremap <leader>ee :Explore<CR>

" font setting shortcut
nnoremap <leader>,, :set gfn=*<CR>
" }}}
" }}}

" cd to ~/ when no arguments are given
if argc() == 0
	execute 'cd ~/'
endif

" load local settings if exists
if filereadable(expand('~/.vimrc_local'))
	source ~/.vimrc_local
endif

" vim: set fdm=marker:

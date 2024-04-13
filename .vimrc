" use system clipbaord
set clipboard=unnamed

set nocompatible
set imdisable

set number
set relativenumber

let mapleader=" "

" search related
set incsearch
set smartcase
set smartindent
set hlsearch

" disable highlight when hit escape key twice
nnoremap <ESC><ESC> :nohlsearch<CR>

" L for the last char, H for the first char

nnoremap L $
nnoremap H ^

vnoremap L $
vnoremap H ^

" zz is for centering cursor in the terminal so that
" following cursor will be easier

nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz
nnoremap { {zz
nnoremap } }zz
nnoremap n nzz
nnoremap N nzz

vnoremap <c-d> <c-d>zz
vnoremap <c-u> <c-u>zz
vnoremap { {zz
vnoremap } }zz
vnoremap n nzz
vnoremap N nzz
vnoremap p "_dp

" <c-j> for joining lines
nnoremap <c-j> :join<CR>

" custom v-mode keymaps

vnoremap , <ESC>ggVG
vnoremap v <ESC><c-v>


" _mykeymap.vim
let mapleader="\<space>"

nnoremap H ^
nnoremap L $

nnoremap o A<CR>

" c does not overwrite registers
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C

" x does not cut into registers in normal mode
nnoremap x "_x
vnoremap x "_x
nnoremap X "_dd
vnoremap X "_dd

" move cursor intuitively
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

"zz to centre cursor
nnoremap n nzz
nnoremap N Nzz

vnoremap H ^
vnoremap L $

vnoremap v <C-v>
vnoremap a <ESC>ggVG

nnoremap U <C-r>

nmap <c-w>> <c-w>><c-w>
nmap <c-w>< <c-w><<c-w>

vnoremap < <gv
vnoremap > >gv

" new tab
nnoremap <leader>N :tabedit<CR>

" tab movning
nnoremap <leader>[ gT<CR>
nnoremap <leader>] gt<CR>

" toggle commands
nnoremap <leader>th :set hlsearch! hls?<CR>
nnoremap <leader>tw :set wrap! wrap?<CR>
nnoremap <leader>tnr :set relativenumber! relativenumber?<CR>
nnoremap <leader>tnn :set number! number?<CR>
nnoremap <leader>tte :set expandtab! expandtab?<CR>
nnoremap <leader>tt1 :set softtabstop=2 tabstop=2 shiftwidth=2<CR>

nnoremap <leader>tt2 :set softtabstop=4 tabstop=4 shiftwidth=4<CR>
nnoremap <leader>tt3 :set softtabstop=8 tabstop=8 shiftwidth=8<CR>
nnoremap <leader>tt4 :set softtabstop=16 tabstop=16 shiftwidth=16<CR>
nnoremap <leader>tt5 :set softtabstop=32 tabstop=32 shiftwidth=32<CR>

" jump
nnoremap <leader>m `

" source
nnoremap <leader>so :source %<CR>:echo "sourced the current file."<CR>

" pane moving
nnoremap <leader>h <C-w>h
nnoremap <leader>l <C-w>l
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k

" pane splitting
nnoremap <leader>sv :vsp<CR>
nnoremap <leader>sh :sp<CR>

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

" setting shortcut
nnoremap <leader>,v :exec(":tabedit ~/_vimrc")<CR>
nnoremap <leader>,g :exec(":tabedit ~/_gvimrc")<CR>
if v:progname =~? "gvim.exe"
  nnoremap <leader>,, :set guifont=*<CR>
endif

" Left explorer
nnoremap <leader>el :Lexplore<CR>
nnoremap <leader>ee :Explore<CR>
nnoremap <leader>eh :Hexplore<CR>
nnoremap <leader>es :Sexplore<CR>
nnoremap <leader>ew :w<CR>:Explore<CR>

nnoremap <leader>:: :set
nnoremap <leader>:f :set filetype=
nnoremap <leader>:e :set encoding=


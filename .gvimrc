"set guifont=ＭＳ_ゴシック:h12

colo evening

hi! CursorIM guibg=Red guifg=NONE

if has('linux')
	set   guifont=UDEV\ Gothic\ NFLG\ 13
elseif has('win32')
	set   guifont=UDEV_Gothic_NFLG:h12
endif

" font setting shortcut
nnoremap <leader>,, :set gfn=*<CR>

set guiligatures=!\"#$%&()*+^,./:>=<?@[]^_{}\|~'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
set renderoptions=type:directx

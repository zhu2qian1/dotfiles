" custom extension match
augroup custom_extension_match
    autocmd!
    autocmd BufNewFile,BufRead *.bat_     set filetype=dosbatch
    autocmd BufNewFile,BufRead *.bat.txt  set filetype=dosbatch
    autocmd BufNewFile,BufRead *.batx     set filetype=dosbatch
    autocmd BufNewFile,BufRead *.sql_     set filetype=sql
    autocmd BufNewFile,BufRead *.md.txt   set filetype=markdown
    autocmd BufNewFile,BufRead *.gij      set filetype=markdown
augroup end

" markdown settings
augroup markdown_custom_settings
    autocmd!
    autocmd FileType markdown set conceallevel=2 et shiftwidth=2 softtabstop=2 tabstop=2
    autocmd FileType markdown nnoremap <buffer> <Tab> >>
    autocmd FileType markdown nnoremap <buffer> <s-Tab> <<
augroup end

" custom autocmd
autocmd QuickfixCmdPost vimgrep copen


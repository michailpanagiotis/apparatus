function! s:setf(filetype) abort
  if &filetype !=# a:filetype
    let &filetype = a:filetype
  endif
endfunction

" Capistrano
au BufNewFile,BufRead *.cap call s:setf('ruby')

" God
au BufNewFile,BufRead *.god call s:setf('ruby')


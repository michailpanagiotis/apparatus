" Perl config

" perltidy
command -range=% -nargs=* Tidy <line1>,<line2>!C:/Personal/Programs/cygwin/home/rinis/bin/Perl-Tidy-20140328/perltidy

"run :Tidy on entire buffer and return cursor to (approximate) original position"
fun DoTidy()
    let l = line(".")
    let c = col(".")
    :Tidy
    call cursor(l, c)
endfun

"shortcut for normal mode to run on entire buffer then return to current line"
"au Filetype perl nmap <C-S-f> :call DoTidy()<CR>
nmap <C-S-f> :call DoTidy()<CR>

"shortcut for visual mode to run on the the current visual selection"
"au Filetype perl vmap <C-S-f> :Tidy<CR>
vmap <C-S-f> :Tidy<CR>

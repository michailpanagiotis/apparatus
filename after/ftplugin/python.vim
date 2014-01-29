set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
filetype indent on

set foldmethod=indent
set foldlevel=99


highlight SpellBad term=undercurl ctermfg=202 ctermbg=052  gui=undercurl guisp=Orange
#autocmd BufWritePost *.py call Flake8()
let &colorcolumn=join(range(81,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn="80,".join(range(80,999),",")

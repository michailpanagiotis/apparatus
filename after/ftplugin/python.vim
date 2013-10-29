set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
filetype indent on

set foldmethod=indent
set foldlevel=99


highlight SpellBad term=undercurl ctermfg=202 ctermbg=052  gui=undercurl guisp=Orange
autocmd BufWritePost *.py call Flake8()

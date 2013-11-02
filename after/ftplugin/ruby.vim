" .vimrc.after
"
" Panos-Mike
"
syntax on                           " syntax highlighing
filetype on                          " try to detect filetypes
filetype plugin indent on    " enable loading indent file for filetype

set background=dark

" a tab is 2 spaces
set tabstop=2
set shiftwidth=2

" Turn off vi compatibility
set nocompatible

set smartindent
set autoindent

" load indent file for the current filetype
filetype indent on

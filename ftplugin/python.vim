" .vimrc.after
"
" Panos-Mike
"

autocmd FileType python set ft=python.django " For SnipMate
autocmd FileType html set ft=htmldjango.html " For SnipMate
setfiletype htmldjango
highlight SpellBad term=underline gui=undercurl guisp=Orange
export DJANGO_SETTINGS_MODULE=project.settings

au FileType python set omnifunc=pythoncomplete#Complete


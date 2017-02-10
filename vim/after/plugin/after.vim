" after config

" vim. live it.
noremap <up> <nop>
noremap <down> <nop>
noremap <left> <nop>
noremap <right> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>

" highlight all occurences of current word without moving
nnoremap <C-b> *``

" tab switching alternatives to gt/gT
nnoremap <C-l> :tabnext<CR>
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-t> :tabnew 
inoremap <C-l> <Esc>:tabnext<CR>i
inoremap <C-h> <Esc>:tabprevious<CR>i
inoremap <C-t> <Esc>:tabnew 

" re-map help command to open vertically
cabbrev hv vert help
"cabbrev help tab help

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

" buffers
set hidden
nnoremap <C-j> :bnext<CR>
nnoremap <C-k> :bprevious<CR>
nnoremap <C-o> :edit 
inoremap <C-j> <Esc>:bnext<CR>i
inoremap <C-k> <Esc>:bprevious<CR>i
inoremap <C-e> <Esc>:edit 
" vim-buffkill
nnoremap <C-w> :BW<CR>
inoremap <C-w> <Esc>:BW<CR>

" tab switching alternatives to gt/gT
"nnoremap <C-l> :tabnext<CR>
"nnoremap <C-h> :tabprevious<CR>
"nnoremap <C-t> :tabnew 
"inoremap <C-l> <Esc>:tabnext<CR>i
"inoremap <C-h> <Esc>:tabprevious<CR>i
"inoremap <C-t> <Esc>:tabnew 

" splits
nnoremap <C-e> :vsplit<CR>
nnoremap <C-l> :wincmd l<CR>
nnoremap <C-h> :wincmd h<CR>
inoremap <C-s> <Esc>:vsplit<CR>i
inoremap <C-l> <Esc>:wincmd l<CR>i
inoremap <C-h> <Esc>:wincmd h<CR>i

" re-map help command to open vertically
cabbrev hv vert help
"cabbrev help tab help

" Go config

" syntax highlighting
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1

" gometalinter
let g:go_metalinter_autosave = 0
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave_enabled = ['golint']
nnoremap <leader>l :GoMetaLinter<CR>

" go info
let g:go_auto_type_info = 1
nnoremap <leader>w :GoInfo<CR>

" go same ids
let g:go_auto_sameids = 1

" go list type
let g:go_list_type="quickfix"

" use goimports for formatting
let g:go_fmt_command = "goimports"

" key mappings
nnoremap <leader>b :GoBuild<CR>
nnoremap <leader>r :GoRun % 
noremap <C-n> :cnext<CR>
noremap <C-m> :cprevious<CR>
noremap <C-g> :GoRename 
nnoremap <leader>s :GoMetaLinter<CR>

" godef
" instead of default <C-t>
noremap <C-[> :GoDefPop<CR>

" indentation
set noexpandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" misc
set colorcolumn=0

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
let g:go_metalinter_autosave = 1
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave_enabled = ['golint']

" go list type
let g:go_list_type="quickfix"

" use goimports for formatting
let g:go_fmt_command = "goimports"

" key mappings
nmap <leader>b :GoBuild<CR>
nmap <leader>r :GoRun 
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>
nmap <leader>l :GoMetaLinter<CR>

" indentation
set noexpandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" misc
set colorcolumn=0

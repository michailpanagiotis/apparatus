local Plugin = {'dense-analysis/ale'}

Plugin.dependencies = {}
Plugin.event = {'BufReadPre', 'BufNewFile'}

vim.cmd [[
let g:ale_use_neovim_diagnostics_api = 1
let g:ale_virtualtext_cursor=0
let g:ale_fix_on_save = 1
let g:ale_python_ruff_options = '--config $HOME/.apparatus/.ruff.toml'
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['ruff'],
\}
let g:ale_fixers = {
\   'python': ['black'],
\}
]]
return Plugin

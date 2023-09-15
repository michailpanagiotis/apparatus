local Plugin = {'dense-analysis/ale'}

Plugin.dependencies = {}
Plugin.event = {'BufReadPre', 'BufNewFile'}

vim.cmd [[
let g:ale_use_neovim_diagnostics_api = 1
let g:ale_virtualtext_cursor=0
]]
return Plugin

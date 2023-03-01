vim.cmd([[
  " matze/vim-move
  let g:move_key_modifier = 'S'
  let g:move_key_modifier_visualmode = 'S'

  " Search/replace
  vnoremap <C-R> "hy:%s/<C-r>h//gc<left><left><left>
]])

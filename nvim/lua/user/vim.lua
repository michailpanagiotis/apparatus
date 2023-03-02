vim.cmd([[
  " matze/vim-move
  let g:move_key_modifier = 'A'
  let g:move_key_modifier_visualmode = 'A'

  " Search/replace
  vnoremap <C-R> "hy:%s/<C-r>h//gc<left><left><left>

  " Yank to clipboard
  autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

  " Trim white space
  autocmd BufWritePre * %s/\s\+$//e
]])

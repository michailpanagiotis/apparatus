vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Trim white space',
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})


vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
    if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
      require('osc52').copy_register('"')
    end
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

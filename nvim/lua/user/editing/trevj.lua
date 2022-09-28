require"trevj".setup{}

vim.keymap.set('n', '<C-s>', function()
  require('trevj').format_at_cursor()
end)

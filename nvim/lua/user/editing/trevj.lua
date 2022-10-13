require"trevj".setup{}

vim.keymap.set('n', 'S', function()
  require('trevj').format_at_cursor()
end)

require"trevj".setup{}

vim.g.splitjoin_split_mapping = ''
vim.g.splitjoin_join_mapping  = 'gj'
vim.keymap.set('n', 'gs', function()
  require('trevj').format_at_cursor()
end)

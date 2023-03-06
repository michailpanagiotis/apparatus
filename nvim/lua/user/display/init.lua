-- Make line numbers default
vim.wo.number = true

-- add signcolumn
vim.wo.signcolumn = 'yes'

-- add colorcolumn
vim.api.nvim_set_option_value("colorcolumn", "79", {})

require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

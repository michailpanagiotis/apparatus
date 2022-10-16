-- Make line numbers default
vim.wo.number = true

-- add signcolumn
vim.wo.signcolumn = 'yes'

-- add colorcolumn
vim.api.nvim_set_option_value("colorcolumn", "79", {})

-- require"shade".setup{}
require"colorizer".setup{}

require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

require("stabilize").setup()

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
    if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
      require('osc52').copy_register('"')
    end
  end,
  group = highlight_group,
  pattern = '*',
})

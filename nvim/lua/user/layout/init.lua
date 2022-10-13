require 'user.layout.lualine'
require 'user.layout.tabby'
require 'user.layout.lir'

require"fidget".setup{}

require("toggleterm").setup{
  open_mapping = [[<c-t>]],
  direction ="tab"
}

require"trouble".setup{}

vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })

require'alpha'.setup(require'alpha.themes.startify'.config)

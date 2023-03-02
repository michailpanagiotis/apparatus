require 'user.layout.lir'

require("toggleterm").setup{
  open_mapping = [[<c-t>]],
  direction ="tab"
}

require"trouble".setup{}

vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })

require'alpha'.setup(require'alpha.themes.startify'.config)

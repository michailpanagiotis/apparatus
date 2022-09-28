require 'user.layout.lualine'
require 'user.layout.notify'
require 'user.layout.whichkey'
require 'user.layout.tabby'
-- require 'user.layout.neotree'

require"fidget".setup{}

require("toggleterm").setup{
  open_mapping = [[<c-t>]],
  direction ="tab"
}

require"trouble".setup{}

vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })

vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>', { silent = true })


require'alpha'.setup(require'alpha.themes.startify'.config)

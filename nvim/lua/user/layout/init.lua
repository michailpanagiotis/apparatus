
local M = {}

function M.setup(use)
  use 'tamago324/lir.nvim'         -- file browser
  use 'folke/trouble.nvim'         -- pretty diagnostics list

  require 'user.layout.lir'
  require"trouble".setup{}

  vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })
end

return M




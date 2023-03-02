require 'user.layout.lir'
require"trouble".setup{}

vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })

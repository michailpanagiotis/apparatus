local Plugin = {'folke/trouble.nvim'}

Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  require"trouble".setup{}
  vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })
end

return Plugin

local Plugin = {'jose-elias-alvarez/null-ls.nvim'}

Plugin.dependencies = {'nvim-lua/plenary.nvim'}
Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  local nullLs = require'null-ls'
  nullLs.setup {
    sources = {
      nullLs.builtins.diagnostics.eslint_d,
    },
    update_in_insert = false,
    root_dir = nil,
  }
end

return Plugin

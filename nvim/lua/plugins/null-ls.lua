local Plugin = {'jose-elias-alvarez/null-ls.nvim'}

Plugin.dependencies = {'nvim-lua/plenary.nvim'}
Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  local null_ls = require'null-ls'
  null_ls.setup {
    sources = {
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.diagnostics.pylint.with({
        diagnostics_postprocess = function(diagnostic)
          diagnostic.code = diagnostic.message_id
        end,
      }),
      null_ls.builtins.formatting.isort,
      null_ls.builtins.formatting.black,
    },
    update_in_insert = false,
    root_dir = nil,
  }
end

return Plugin

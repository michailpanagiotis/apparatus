local Plugin = {'jose-elias-alvarez/null-ls.nvim'}

Plugin.dependencies = {'nvim-lua/plenary.nvim'}
Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  local null_ls = require'null-ls'
  null_ls.setup {
    sources = {
      null_ls.builtins.diagnostics.eslint_d,
      -- null_ls.builtins.diagnostics.flake8.with({
      --   args = { "--format", "default", "--config", "/root/.apparatus/.flake8", "--stdin-display-name", "$FILENAME", "-" }
      -- }),
      -- null_ls.builtins.diagnostics.pylint.with({
      --   diagnostics_postprocess = function(diagnostic)
      --     diagnostic.code = diagnostic.message_id
      --   end,
      --   args = { "--rcfile", "/root/.apparatus/.pylintrc", "--from-stdin", "$FILENAME", "-f", "json" }
      -- }),
      null_ls.builtins.formatting.black,
    },
    update_in_insert = false,
    root_dir = nil,
  }
end

return Plugin

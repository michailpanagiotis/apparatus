require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.eslint,
  },
  update_in_insert = false,
  root_dir = nil,
})

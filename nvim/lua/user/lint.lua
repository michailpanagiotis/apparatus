require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.eslint_d,
  },
  update_in_insert = false,
  root_dir = nil,
})

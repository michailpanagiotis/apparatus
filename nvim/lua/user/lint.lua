require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.eslint,
  },
  root_dir = nil,
})

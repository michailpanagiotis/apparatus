require("filetype").setup({
  overrides = {
    shebang = {
      -- Set the filetype of files with a dash shebang to sh
      dash = "sh",
    },
  },
})

-- require("project_nvim").setup({
--   detection_methods = { "lsp", "pattern" },
--   patterns = { "=src", ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
--   silent_chdir = false,
-- })

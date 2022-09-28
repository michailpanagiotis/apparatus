require("filetype").setup({
  overrides = {
    shebang = {
      -- Set the filetype of files with a dash shebang to sh
      dash = "sh",
    },
  },
})

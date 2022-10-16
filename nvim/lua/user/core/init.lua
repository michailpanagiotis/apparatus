require("filetype").setup({
  overrides = {
    shebang = {
      -- Set the filetype of files with a dash shebang to sh
      dash = "sh",
    },
  },
})

require('trim').setup({
  -- if you want to ignore space of top
  patterns = {
    [[%s/\s\+$//e]],           -- remove unwanted spaces
    [[%s/\($\n\s*\)\+\%$//]],  -- trim last line
    [[%s/\%^\n\+//]],          -- trim first line
    -- [[%s/\(\n\n\)\n\+/\1/]],   -- replace multiple blank lines with a single line
  },
})

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
    if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
      require('osc52').copy_register('"')
    end
  end,
  group = highlight_group,
  pattern = '*',
})

-- require("project_nvim").setup({
--   detection_methods = { "lsp", "pattern" },
--   patterns = { "=src", ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
--   silent_chdir = false,
-- })

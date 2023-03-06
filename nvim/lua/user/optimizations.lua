local M = {}

function M.setup(use)
  use 'nathom/filetype.nvim'            -- faster filetype recognition
  use 'lewis6991/impatient.nvim'        -- Improve startup time for Neovim

  require("filetype").setup({
    overrides = {
      shebang = {
        -- Set the filetype of files with a dash shebang to sh
        dash = "sh",
      },
    },
  })
  require('impatient')
end

return M




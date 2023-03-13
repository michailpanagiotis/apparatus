local M = {}

function M.setup(use)
  use 'RRethy/nvim-base16'
  use 'sainnhe/everforest'
  use 'sainnhe/gruvbox-material'
  use { "briones-gabriel/darcula-solid.nvim", requires = "rktjmp/lush.nvim" }

  -- Set colorscheme
  vim.o.termguicolors = true
  vim.o.background = "dark"

  vim.g.monokaipro_filter = "default"
  vim.g.monokaipro_transparent = false
  vim.g.monokaipro_hide_inactive_statusline = false
  vim.g.monokaipro_flat_float = false
  vim.g.monokaipro_sidebars = { "packer", "Trouble" }
  vim.g.sonokai_style = 'default'
  vim.cmd [[colorscheme everforest]]
end

return M

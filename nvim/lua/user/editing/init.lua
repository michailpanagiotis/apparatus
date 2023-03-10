local M = {}

function M.setup(use)
  use({
    'AckslD/nvim-trevJ.lua',
    requires = {},
    config = function()
      require"trevj".setup{}
    end
  })
  use 'windwp/nvim-autopairs'
  use 'kylechui/nvim-surround'
  use 'max397574/better-escape.nvim'    -- Escape using 'jk'
  use 'gennaro-tedesco/nvim-jqx'        -- Json formatter
  use 'ojroques/nvim-osc52'
  require('user.editing.autopairs')

  vim.keymap.set('n', 'S', function()
    require('trevj').format_at_cursor()
  end)

  require('nvim-surround').setup({
      -- Configuration here, or leave empty to use defaults
  })

  require('better_escape').setup({
    mapping = {"jk", "kj"}
  })
end

return M


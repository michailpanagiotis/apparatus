
local M = {}

function M.setup(use)
  use { -- Add git related info in the signs columns and popups
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
  }
  use { 'akinsho/git-conflict.nvim', tag = "*" }
  use { 'ruifm/gitlinker.nvim', requires = 'nvim-lua/plenary.nvim' }

  require('gitsigns').setup {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  }

  require('git-conflict').setup()

  require'gitlinker'.setup{
    opts = {
      -- print the url after performing the action
      print_url = false,
      action_callback = function(url)
        -- yank to unnamed register
        vim.api.nvim_command('let @" = \'' .. url .. '\'')
        -- copy to the system clipboard using OSC52
        require('osc52').copy_register('"')
      end,
    },
  }
end


return M

return {
  'ruifm/gitlinker.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'ojroques/nvim-osc52' },
  event = {'BufReadPre', 'BufNewFile'},
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

return {
  'AckslD/nvim-trevJ.lua',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function ()
      require"trevj".setup{}
      vim.keymap.set('n', 'S', function()
        require('trevj').format_at_cursor()
      end)
    end,
}

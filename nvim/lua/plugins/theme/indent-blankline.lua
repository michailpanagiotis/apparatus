local Plugin = {'lukas-reineke/indent-blankline.nvim'}

Plugin.main = 'ibl'
Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  require'ibl'.setup {
    indent = { char = '┊' },
    scope = { enabled = false },
    whitespace = {
        remove_blankline_trail = false,
    },
  }
end

return Plugin

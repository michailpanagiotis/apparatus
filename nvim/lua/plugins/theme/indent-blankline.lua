local Plugin = {'lukas-reineke/indent-blankline.nvim'}

Plugin.event = {'BufReadPre', 'BufNewFile'}
Plugin.lazy = false

function Plugin.config(LazyPlugin, opts)
  local highlight = {
      "CursorColumn",
      "Whitespace",
  }
  require('ibl').setup({
    indent = { char = '┊' },
    scope = { enabled = false },
    whitespace = {
        remove_blankline_trail = false,
    },
  });
end

return Plugin

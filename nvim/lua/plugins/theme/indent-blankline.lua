return {
  'lukas-reineke/indent-blankline.nvim',
  event = {'BufReadPre', 'BufNewFile'},
  main = 'ibl',
  opts = {
    indent = { char = '┊' },
    scope = { enabled = false },
    whitespace = {
        remove_blankline_trail = false,
    },
  }
}

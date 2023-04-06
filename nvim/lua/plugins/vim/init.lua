return {
  'tpope/vim-sleuth',     -- heuristically set buffer options
  'godlygeek/tabular',    -- align columns :Tabularize /--
  'tomtom/tcomment_vim',  -- "gc" to comment visual regions/lines
  'mhinz/vim-startify',
  'wellle/targets.vim',
  {
    'matze/vim-move',       -- Plugin to move lines and selections up and down
    config = function ()
      vim.cmd([[
        " matze/vim-move
        let g:move_key_modifier = 'A'
        let g:move_key_modifier_visualmode = 'A'
      ]])
    end
  },
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()',
  }
}

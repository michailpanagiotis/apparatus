local map = require("user/utils").map
require('tabby.tabline').use_preset('tab_only', {
  theme = {
    fill = 'TabLineFill', -- tabline background
    head = 'TabLine', -- head element highlight
    current_tab = 'TabLineSel', -- current tab label highlight
    tab = 'TabLine', -- other tab label highlight
    win = 'TabLine', -- window highlight
    tail = 'TabLine', -- tail element highlight
  },
  buf_name = {
      mode = "'unique'|'relative'|'tail'|'shorten'",
  },
})

map('n', '<C-;>', ':tabprevious<CR>', { silent = true })
map('n', '<C-,>', ':tabnext<CR>', { silent = true })
map('t', '<C-,>', [[<C-\><C-n>:tabprevious<CR>]], { silent = true })
map('t', '<C-,>', [[<C-\><C-n>:tabnext<CR>]], { silent = true })

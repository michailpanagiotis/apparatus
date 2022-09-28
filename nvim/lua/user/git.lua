require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

-- vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | tabnew | cw | redraw! ]])
vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw! ]])

vim.keymap.set('n', '<leader>g', ':Git ', { silent = true })
vim.keymap.set('n', '<leader>gg', ':Ggr ', { silent = true })

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
-- vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw! ]])

-- vim.api.nvim_add_user_command('Ggr', "execute 'silent Ggrep!' <q-args> | cw | redraw!", { nargs = 1 })

vim.keymap.set('n', '<leader>g', ':Git ', { silent = true })
vim.keymap.set('n', '<leader>gg', ':Ggr ', { silent = true })

require('git-conflict').setup()

require"gitlinker".setup()

local neogit = require('neogit')

neogit.setup ({
  mappings = {
    -- modify status buffer mappings
    status = {
      ["<C-g>"] = "Close",
    }
  }
})

vim.keymap.set('n', '<C-g>', ':Neogit kind=vsplit<CR>', { silent = true })

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- disable some default keys
vim.keymap.set({ 'n', 'v' }, '<C-o>', '<Nop>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


vim.cmd([[
  " Search/replace
  vnoremap <C-R> "hy:%s/<C-r>h//gc<left><left><left>
]])


-- center text on search
local set = vim.keymap.set
set('n', 'n', 'nzzzv')
set('n', 'N', 'Nzzzv')
set('c', '<CR>',
  function()
    return vim.fn.getcmdtype() == '/' and '<CR>zzzv' or '<CR>'
  end,
  { expr = true })

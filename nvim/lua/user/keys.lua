-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- Search/replace
vim.keymap.set('v', '<C-R>', [["hy:%s/<C-r>h//gc<left><left><left>]], {});
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', '<C-l>', ':TroubleToggle document_diagnostics<CR>', { silent = true })

-- vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {})

vim.api.nvim_set_keymap('i', '<c-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {})


vim.keymap.set('n', '<leader>g', ':Git ', { silent = true })
vim.keymap.set('n', '<leader>gg', ':Ggr ', { silent = true })

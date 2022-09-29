require('leap').set_default_keymaps()
require('leap').setup({
  higlight_unlabeled = true,
  case_sensitive = true
})

vim.keymap.set({'n', 'x', 'o'}, 's', function() require'leap'.leap({ target_windows = { vim.fn.win_getid() } }) end, {})

-- Bidirectional search in the current window is just a specific case of the
-- multi-window mode.
-- require('leap').leap { target_windows = { vim.fn.win_getid() } }

-- -- Searching in all windows (including the current one) on the tab page.
-- require('leap').leap { target_windows = vim.tbl_filter(
--   function (win) return vim.api.nvim_win_get_config(win).focusable end,
--   vim.api.nvim_tabpage_list_wins(0)
-- )}
--
vim.keymap.set('n', '<leader>me', "<cmd>lua require('memento').toggle()<CR>", { silent = true })

require('leap').setup({
  higlight_unlabeled = true,
  case_sensitive = true
})

require('leap').opts.safe_labels = {}
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
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


local ok, cybu = pcall(require, "cybu")
if not ok then
  return
end
cybu.setup()
vim.keymap.set("n", "{", "<Plug>(CybuPrev)")
vim.keymap.set("n", "}", "<Plug>(CybuNext)")
vim.keymap.set({"n", "v"}, "<c-s-tab>", "<plug>(CybuLastusedPrev)")
vim.keymap.set({"n", "v"}, "<c-tab>", "<plug>(CybuLastusedNext)")

-- vim.keymap.set('n', "<Left>", "<C-w>h", { silent = true });
-- vim.keymap.set('n', "<Down>", "<C-w>j", { silent = true });
-- vim.keymap.set('n', "<Up>", "<C-w>k", { silent = true });
-- vim.keymap.set('n', "<Right>", "<C-w>l", { silent = true });

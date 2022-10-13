require('leap').setup({
  higlight_unlabeled = true,
  case_sensitive = true
})

require('leap').opts.safe_labels = {}
vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
vim.keymap.set({'n', 'x', 'o'}, 's', function() require'leap'.leap({ target_windows = { vim.fn.win_getid() } }) end, {})

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

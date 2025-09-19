vim.keymap.set('n', '<leader>date', ":put =strftime('%c')<CR>", {})

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-l>', ':Trouble diagnostics toggle filter.buf=0 focus=true<CR>', { silent = true })
-- vim.keymap.set('n', '<C-p>', ':FzfLua files <CR>', { silent = true })

-- local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })

-- qq starts recording, q stops, Q runs it.
vim.keymap.set('n', 'Q' , '@q', { desc = 'Replay recording'})
vim.keymap.set('v', 'Q' , ':norm @q<cr>', { desc = 'Replay recording' })

-- Cursor when selecting
vim.keymap.set('v', 'y', 'ygv<esc>', { desc = 'Keep cursor at end of selection' })

-- Search/replace
vim.keymap.set('v', '<C-R>', '"hy:%s/<C-r>h//gc<left><left><left>', { desc = 'Search/replace' })

-- trevj
vim.keymap.set('n', 'S', function()
  require('trevj').format_at_cursor()
end)

-- LSP
vim.keymap.set(
  "n",
  "L",
  function()
    local found_float = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local win_config = vim.api.nvim_win_get_config(win)
        if win_config.relative == 'win' then
            vim.api.nvim_win_close(win, true)
            found_float = true
        end
    end

    if found_float then
        return
    end

    vim.diagnostic.open_float(nil, { header="current", split="left", focus=true })
  end,
  { silent = true }
)

vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    vim.keymap.set('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, { buffer = event.buf, desc = 'LSP: [T]oggle Inlay [H]ints' })
  end
});

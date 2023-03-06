local M = {}

function M.setup(use)
  use 'matze/vim-move'       -- Plugin to move lines and selections up and down
  use 'tpope/vim-sleuth'     -- heuristically set buffer options
  use 'godlygeek/tabular'    -- align columns :Tabularize /--
  use 'ojroques/vim-oscyank' -- A Vim plugin to copy text through SSH with OSC52
  use 'tomtom/tcomment_vim'  -- "gc" to comment visual regions/lines
  use {                      -- documentation generator
    'kkoomen/vim-doge', run = ':call doge#install()',
  }
  use 'mhinz/vim-startify'
  -- use({
  --   'RRethy/nvim-base16',
  --   requires = {},
  --   config = function()
  --   end
  -- })
  --
  vim.cmd([[
    " matze/vim-move
    let g:move_key_modifier = 'A'
    let g:move_key_modifier_visualmode = 'A'

    " Search/replace
    vnoremap <C-R> "hy:%s/<C-r>h//gc<left><left><left>

    " Yank to clipboard
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

    " Trim white space
    autocmd BufWritePre * %s/\s\+$//e

    " Set PWD to first file directory
    lcd %:p:h
    " Set PWD to current file directory
    " autocmd BufEnter * silent! lcd %:p:h
  ]])
end

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

return M


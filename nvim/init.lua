-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

-- stylua: ignore start
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'   -- Package manager

  -- Syntax & diagnostics
  use 'folke/lua-dev.nvim'                                                -- Dev setup for nvim lua API
  use 'b0o/schemastore.nvim'
  use 'neovim/nvim-lspconfig'                                             -- Collection of configurations for built-in LSP client
  use 'williamboman/nvim-lsp-installer'                                   -- Automatically install language servers to stdpath
  use 'nvim-treesitter/nvim-treesitter'                                   -- Highlight, edit, and navigate code
  use 'nvim-treesitter/nvim-treesitter-textobjects'                       -- Additional textobjects for treesitter
  use 'jose-elias-alvarez/null-ls.nvim'
  use { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" }

  -- Autocomplete
  use {
    'L3MON4D3/LuaSnip',
    requires = { 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  }
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp' } }-- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-buffer'

  -- Searching & Browsing
  use {
    'nvim-telescope/telescope.nvim',            -- Fuzzy Finder (files, lsp, etc)
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use 'nvim-telescope/telescope-ui-select.nvim'
  use {
    'nvim-telescope/telescope-fzf-native.nvim', -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    run = 'make',
    cond = vim.fn.executable "make" == 1
  }

  -- Moving
  use 'ggandor/leap.nvim'

  -- Editing
  use 'AndrewRadev/splitjoin.vim'                   -- splitting/joining lines
  use 'AckslD/nvim-trevJ.lua'                       -- splitting lines according to treesitter
  use 'tpope/vim-surround'
  use 'tpope/vim-sleuth'                            -- Detect tabstop and shiftwidth automatically
  use 'numToStr/Comment.nvim'                       -- "gc" to comment visual regions/lines
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'windwp/nvim-autopairs'

  -- Layout & Display
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'     -- File browser
  use 'mjlbach/onedark.nvim'         -- Theme inspired by Atom
  use 'nvim-lualine/lualine.nvim'    -- Fancier statusline
  use 'j-hui/fidget.nvim'            -- Progress bar for LSP
  use 'sunjon/shade.nvim'            -- shade inactive windows
  use 'mhinz/vim-startify'           -- The fancy start screen for Vim
  use 'rcarriga/nvim-notify'

  -- Git
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups
  use 'tpope/vim-fugitive'
  use 'whiteinge/diffconflicts'

  -- Minor Enhancements
  use 'ojroques/vim-oscyank'                -- yank in clipboard
  use 'vim-scripts/ReplaceWithRegister'     -- multiple pastes after yank
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'cappyzawa/trim.nvim'                 -- trim trailing space
  use 'nathom/filetype.nvim'                -- faster filetype recognition
  use 'godlygeek/tabular'                   -- align columns
  use 'RRethy/vim-illuminate'               -- Illuminate word under cursor
  use 'antoinemadec/FixCursorHold.nvim'
  use 'folke/which-key.nvim'

  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end}

  use 'nanozuki/tabby.nvim'
  use 'NvChad/nvim-colorizer.lua'

  if is_bootstrap then
    require('packer').sync()
  end
end)
-- stylua: ignore end

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

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
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme onedark]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

-- Gitsigns
-- See `:help gitsigns.txt`
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

require('trim').setup({
  -- if you want to ignore space of top
  patterns = {
    [[%s/\s\+$//e]],           -- remove unwanted spaces
    [[%s/\($\n\s*\)\+\%$//]],  -- trim last line
    [[%s/\%^\n\+//]],          -- trim first line
    -- [[%s/\(\n\n\)\n\+/\1/]],   -- replace multiple blank lines with a single line
  },
})

require("null-ls").setup({
  sources = {
    require("null-ls").builtins.diagnostics.eslint_d,
  },
})

require('leap').set_default_keymaps()
require('leap').setup({
  higlight_unlabeled = true,
  case_sensitive = true
})

require("toggleterm").setup{
  open_mapping = [[<c-t>]],
  direction ="tab"
}

vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
-- nvim-cmp setup
require 'user/cmp'
require 'user/nvimtree'
require 'user/notify'
require 'user/treesitter'
require 'user/gitsigns'
require 'user/telescope'
require 'user/lsp'
require 'user/lualine'
require 'user/comment'
require 'user/autopairs'
require 'user/whichkey'
require 'user/splitjoin'
require 'user/keys'

-- vanilla
require"fidget".setup{}
require"which-key".setup{}
require"shade".setup{}
require"trouble".setup{}
require"colorizer".setup{}

vim.g.did_load_filetypes = 1
vim.api.nvim_exec([[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif ]], false)
-- vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | tabnew | cw | redraw! ]])
vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw! ]])

vim.cmd([[ set autochdir ]])

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

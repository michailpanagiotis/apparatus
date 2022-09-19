-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path, false, {}, false)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

-- stylua: ignore start
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'
  -- Dev setup for nvim lua API.
  use 'folke/lua-dev.nvim'
  -- File browser
  use 'kyazdani42/nvim-tree.lua'
  -- Autocompletion
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp' } }
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-buffer'

  use 'rcarriga/nvim-notify'
  use 'nvim-treesitter/nvim-treesitter'                                     -- Highlight, edit, and navigate code
  use 'nvim-treesitter/nvim-treesitter-textobjects'                         -- Additional textobjects for treesitter
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups
  use 'neovim/nvim-lspconfig'                                               -- Collection of configurations for built-in LSP client
  use 'williamboman/nvim-lsp-installer'                                     -- Automatically install language servers to stdpath
  -- Snippet Engine and Snippet Expansion
  use {
    'L3MON4D3/LuaSnip',
    requires = { 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  }
  -- Theme
  use 'mjlbach/onedark.nvim'                                                      -- Theme inspired by Atom

  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Fuzzy Finder (files, lsp, etc)
  use 'nvim-telescope/telescope-ui-select.nvim'
  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable "make" == 1 }
  use 'nvim-lualine/lualine.nvim'                                                 -- Fancier statusline
  use 'windwp/nvim-autopairs'
  use 'numToStr/Comment.nvim'                                                     -- "gc" to comment visual regions/lines
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  -- MISC
  use 'kyazdani42/nvim-web-devicons'
  use 'b0o/schemastore.nvim'
  use 'Tastyep/structlog.nvim'
  use 'mhinz/vim-startify'


  -- Lunar vim extras
  -- https://www.lunarvim.org/plugins/01-core-plugins-list.html
  -- use { 'nvim-lua/popup.nvim')
  use 'jose-elias-alvarez/null-ls.nvim'

  -- User plugins
  use 'tpope/vim-sleuth'                                                          -- Detect tabstop and shiftwidth automatically
  use { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" }
  -- Progress bar for LSP
  use 'j-hui/fidget.nvim'

  use 'sunjon/shade.nvim'

  -- Illuminate word under cursor
  use 'RRethy/vim-illuminate'

  -- splitting/joining lines
  use 'AndrewRadev/splitjoin.vim'
  use 'AckslD/nvim-trevJ.lua'

  use 'vim-scripts/ReplaceWithRegister'
  use 'whiteinge/diffconflicts'

  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'ggandor/leap.nvim'
  use 'folke/which-key.nvim'

  -- Minor Enhancements
  use 'ojroques/vim-oscyank'                -- yank in clipboard
  use 'antoinemadec/FixCursorHold.nvim'
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'cappyzawa/trim.nvim'                 -- trim trailing space
  use 'nathom/filetype.nvim'                -- faster filetype recognition
  use 'godlygeek/tabular'                   -- align columns

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

vim.g.did_load_filetypes = 1
vim.api.nvim_exec([[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif ]], false)
vim.cmd([[ command -nargs=+ Ggr execute 'silent Ggrep!' <q-args> | cw | redraw! ]])
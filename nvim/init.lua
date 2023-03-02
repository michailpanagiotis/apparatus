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

  -- Vim Core
  use 'matze/vim-move'       -- Plugin to move lines and selections up and down
  use 'tpope/vim-sleuth'     -- heuristically set buffer options
  use 'godlygeek/tabular'    -- align columns :Tabularize /--
  use 'ojroques/vim-oscyank' -- A Vim plugin to copy text through SSH with OSC52
  use 'tomtom/tcomment_vim'  -- "gc" to comment visual regions/lines
  use {                      -- documentation generator
    'kkoomen/vim-doge', run = ':call doge#install()',
  }
  use 'mhinz/vim-startify'

  -- Optimizations
  use 'nathom/filetype.nvim'            -- faster filetype recognition
  use 'lewis6991/impatient.nvim'        -- Improve startup time for Neovim

  -- Searching & Browsing
  use 'ibhagwan/fzf-lua'

  -- LSP
  use "neovim/nvim-lspconfig"
  use 'nanotee/nvim-lsp-basics'

  -- Syntax & diagnostics
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use 'hrsh7th/cmp-nvim-lsp'                        -- nvim-cmp source for neovim builtin LSP client
  use 'jose-elias-alvarez/typescript.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'

  -- Treesitter
  use 'nvim-treesitter/nvim-treesitter'             -- Highlight, edit, and navigate code
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- Additional textobjects for treesitter
  use 'RRethy/nvim-treesitter-textsubjects'
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'windwp/nvim-ts-autotag'

  -- Autocomplete
  use {
    'L3MON4D3/LuaSnip',
    requires = { 'saadparwaiz1/cmp_luasnip', 'rafamadriz/friendly-snippets' },
    config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
  }
  use { 'hrsh7th/nvim-cmp', requires = { 'hrsh7th/cmp-nvim-lsp' } }
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-buffer'

  -- Editing
  use 'AckslD/nvim-trevJ.lua' 		-- splitting lines according to treesitter
  use 'windwp/nvim-autopairs'
  use 'kylechui/nvim-surround'
  use 'max397574/better-escape.nvim'    -- Escape using 'jk'
  use 'gennaro-tedesco/nvim-jqx'        -- Json formatter

  -- Layout
  use 'tamago324/lir.nvim'         -- file browser
  use 'folke/trouble.nvim'         -- pretty diagnostics list

  -- Display
  use 'sunjon/shade.nvim'                   -- shade inactive windows
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'xiyaowong/virtcolumn.nvim'           -- display a line as the colorcolumn

  -- Moving
  use 'ggandor/leap.nvim'                   -- motion plugin
  use { -- cycle through buffers
    "ghillb/cybu.nvim",
    requires = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim"}, -- optional for icon support
  }

  -- Themes
  use 'RRethy/nvim-base16'

  -- Lualine
  use 'nvim-lualine/lualine.nvim'      -- fancier statusline
  use 'arkav/lualine-lsp-progress'     -- LSP Progress lualine component
  use 'https://gitlab.com/__tpb/monokai-pro.nvim'
  use {
    "SmiteshP/nvim-navic",             -- Simple winbar/statusline plugin that shows your current code context
    requires = "neovim/nvim-lspconfig"
  }

  -- Git
  use { -- Add git related info in the signs columns and popups
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
  }
  use { 'akinsho/git-conflict.nvim', tag = "*" }
  use { 'ruifm/gitlinker.nvim', requires = 'nvim-lua/plenary.nvim' }

  -- TODO
  --
  --https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
  --https://github.com/glepnir/lspsaga.nvim
  --https://github.com/roobert/node-type.nvim
  --https://github.com/danymat/neogen
  --https://github.com/CKolkey/ts-node-action
  --https://github.com/barrett-ruth/import-cost.nvim
  -- RRethy/nvim-treesitter-textsubjects
  -- autocomplete when <Tab>
  -- https://github.com/gbprod/yanky.nvim
  -- wellle/targets.vim
  -- https://github.com/notomo/cmdbuf.nvim
  -- https://github.com/gelguy/wilder.nvim
  -- https://github.com/chipsenkbeil/distant.nvim
  -- https://github.com/andrewferrier/debugprint.nvim
  -- https://github.com/m-demare/attempt.nvim
  -- use yorickpeterse/nvim-dd
  use {'kevinhwang91/nvim-bqf', ft = 'qf'}

  -- TODO

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


-- essential
require 'user/vim'
require 'user/optimizations'
require 'user/fzf'
require 'user/theme'
require 'user/lsp'
require 'user/diagnostics'
require 'user/treesitter'
require 'user/completion'
require 'user/layout'
require 'user/display'
require 'user/editing'
require 'user/moving'
require 'user/lint'

-- nice-to-have
require 'user/git'
require 'user/lualine'

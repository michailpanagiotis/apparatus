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
  use 'andymass/vim-matchup' -- navigate and highlight matching words
  -- wellle/targets.vim

  -- Neovim Core
  use 'folke/lua-dev.nvim'              -- Dev setup for nvim lua API
  use 'nvim-lua/plenary.nvim'
  use 'ojroques/nvim-osc52'
  use 'kyazdani42/nvim-web-devicons'
  use 'cappyzawa/trim.nvim'             -- trim trailing space
  use 'nathom/filetype.nvim'            -- faster filetype recognition
  use 'antoinemadec/FixCursorHold.nvim'
  use 'ahmedkhalf/project.nvim'
  use 'b0o/schemastore.nvim'
  use 'lewis6991/impatient.nvim'        -- Improve startup time for Neovim

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

  -- Searching & Browsing
  use 'ibhagwan/fzf-lua'
  use 'AckslD/nvim-neoclip.lua'
  use 'gennaro-tedesco/nvim-peekup'

  -- Git
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups
  use { 'akinsho/git-conflict.nvim', tag = "*" }
  use { 'ruifm/gitlinker.nvim', requires = 'nvim-lua/plenary.nvim' }
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

  -- Editing
  use 'AckslD/nvim-trevJ.lua' 		-- splitting lines according to treesitter
  use 'numToStr/Comment.nvim' 		-- "gc" to comment visual regions/lines
  use 'windwp/nvim-autopairs'
  use 'kylechui/nvim-surround'
  use 'max397574/better-escape.nvim'    -- Escape using 'jk'
  use 'gennaro-tedesco/nvim-jqx'        -- Json formatter

  -- Layout
  use 'tamago324/lir.nvim'         -- file browser
  use 'nvim-lualine/lualine.nvim'  -- fancier statusline
  use 'arkav/lualine-lsp-progress' -- LSP Progress lualine component
  use 'goolord/alpha-nvim'         -- start screen
  use 'akinsho/toggleterm.nvim'    -- terminal
  use 'folke/trouble.nvim'         -- pretty diagnostics list
  use 'nanozuki/tabby.nvim'        -- tabs

  -- Display
  use 'sunjon/shade.nvim'                   -- shade inactive windows
  use 'NvChad/nvim-colorizer.lua'           -- color highlighter
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines
  use 'luukvbaal/stabilize.nvim'            -- stabilize window open/close events.
  use 'xiyaowong/virtcolumn.nvim'           -- display a line as the colorcolumn

  -- Moving
  use 'ggandor/leap.nvim'                   -- motion plugin
  use 'ghillb/cybu.nvim'                    -- cycle through buffers

  -- Themes
  use 'mjlbach/onedark.nvim'                        -- Theme inspired by Atom
  use { "briones-gabriel/darcula-solid.nvim", requires = "rktjmp/lush.nvim" }
  use { "mcchrish/zenbones.nvim", requires = "rktjmp/lush.nvim" }
  use 'doums/darcula'
  use 'RRethy/nvim-base16'
  use 'https://gitlab.com/__tpb/monokai-pro.nvim'
  use 'sainnhe/sonokai'
  use 'tanvirtin/monokai.nvim'

  use {
    'kkoomen/vim-doge',
    run = ':call doge#install()'
  }

  use {
    "SmiteshP/nvim-navic",
    requires = "neovim/nvim-lspconfig"
  }


  -- TODO
  --
  --https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-bracketed.md
  --https://github.com/glepnir/lspsaga.nvim
  --https://github.com/roobert/node-type.nvim
  --https://github.com/SmiteshP/nvim-navic
  --https://github.com/danymat/neogen
  --https://github.com/CKolkey/ts-node-action
  --https://github.com/barrett-ruth/import-cost.nvim
  -- RRethy/nvim-treesitter-textsubjects
  -- autocomplete when <Tab>
  -- https://github.com/gbprod/yanky.nvim
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

-- Search/replace
vim.keymap.set('v', '<C-R>', [["hy:%s/<C-r>h//gc<left><left><left>]], {});

require 'user/vim'
require 'user/core'
require 'user/theme'
require 'user/lsp'
require 'user/diagnostics'
require 'user/treesitter'
require 'user/completion'
require 'user/fzf'
require 'user/git'
require 'user/layout'
require 'user/display'
require 'user/editing'
require 'user/moving'
require 'user/lint'

function _G.reload_nvim_conf()
  for name,_ in pairs(package.loaded) do
    if name:match('^user/') then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify("Nvim configuration reloaded!", vim.log.levels.INFO)
end

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
  use 'vim-scripts/ReplaceWithRegister' -- multiple pastes after yank
  use 'tpope/vim-surround'
  use 'tpope/vim-sleuth'                -- Detect tabstop and shiftwidth automatically
  -- use 'tpope/vim-vinegar'
  use 'godlygeek/tabular'               -- align columns

  -- Neovim Core
  use 'folke/lua-dev.nvim'                          -- Dev setup for nvim lua API
  use 'lewis6991/impatient.nvim'                    -- Improve startup time for Neovim
  use 'b0o/schemastore.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'nathom/filetype.nvim'                        -- faster filetype recognition
  use 'antoinemadec/FixCursorHold.nvim'
  use 'ahmedkhalf/project.nvim'
  use 'mjlbach/onedark.nvim'                        -- Theme inspired by Atom

  -- Syntax & diagnostics
  use 'neovim/nvim-lspconfig'                       -- Collection of configurations for built-in LSP client
  use 'williamboman/nvim-lsp-installer'             -- Automatically install language servers to stdpath
  use 'nvim-treesitter/nvim-treesitter'             -- Highlight, edit, and navigate code
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'jose-elias-alvarez/null-ls.nvim'

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
  use {
    'nvim-telescope/telescope.nvim',            -- Fuzzy Finder (files, lsp, etc)
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use 'nvim-telescope/telescope-ui-select.nvim'
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- Git
  use 'tpope/vim-fugitive'
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Add git related info in the signs columns and popups

  -- Editing
  use 'AckslD/nvim-trevJ.lua' -- splitting lines according to treesitter
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'windwp/nvim-autopairs'
  use 'cappyzawa/trim.nvim'   -- trim trailing space
  use 'ojroques/nvim-osc52'

  -- Layout
  use 'nvim-lualine/lualine.nvim'              -- Fancier statusline
  use 'j-hui/fidget.nvim'                      -- Progress bar for LSP
  use 'goolord/alpha-nvim'                     -- start screen
  use 'rcarriga/nvim-notify'
  use 'akinsho/toggleterm.nvim'
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
  }
  use 'folke/which-key.nvim'
  use 'nanozuki/tabby.nvim'

  -- Display
  use 'sunjon/shade.nvim'                   -- shade inactive windows
  use 'NvChad/nvim-colorizer.lua'
  use 'lukas-reineke/indent-blankline.nvim' -- Add indentation guides even on blank lines

  -- Moving
  use 'ggandor/leap.nvim'

  -- VIM
  -- use 'preservim/nerdtree'
  --
  use 'tamago324/lir.nvim'

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

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Search/replace
vim.keymap.set('v', '<C-R>', [["hy:%s/<C-r>h//gc<left><left><left>]], {});

require 'user/core'
require 'user/lsp'
require 'user/treesitter'
require 'user/completion'
require 'user/telescope'
require 'user/git'
require 'user/lint'
require 'user/layout'
require 'user/display'
require 'user/editing'

-- vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>', { silent = true })
-- vim.keymap.set('n', '<C-n>', ':Ve<CR>', { silent = true })

local actions = require'lir.actions'
local lirFloat = require'lir.float'
local mark_actions = require 'lir.mark.actions'
local clipboard_actions = require'lir.clipboard.actions'
local lir = require'lir'

lir.setup {
  show_hidden_files = false,
  devicons_enable = true,
  mappings = {
    ['<CR>']  = actions.edit,
    ['<C-s>'] = actions.split,
    ['<C-v>'] = actions.vsplit,
    ['<C-t>'] = actions.tabedit,

    ['<C-n>'] = function()
      vim.cmd("quit")
    end,
    -- ['q']     = actions.quit,
    ['q']     = function()
      vim.cmd("quit")
    end,

    ['-']     = actions.up,

    ['K']     = actions.mkdir,
    ['N']     = actions.newfile,
    ['R']     = actions.rename,
    ['@']     = actions.cd,
    ['Y']     = actions.yank_path,
    ['.']     = actions.toggle_show_hidden,
    ['D']     = actions.delete,

    ['J'] = function()
      mark_actions.toggle_mark()
      vim.cmd('normal! j')
    end,
    ['C'] = clipboard_actions.copy,
    ['X'] = clipboard_actions.cut,
    ['P'] = clipboard_actions.paste,
  },
      float = {
        winblend = 15,
        curdir_window = {
          enable = false,
          highlight_name = false
        },

        -- You can define a function that returns a table to be passed as the third
        -- argument of nvim_open_win().
        win_opts = function()
          local width = math.floor(vim.o.columns * 0.6)
          local height = math.floor(vim.o.lines * 0.8)
          return {
            border = require("lir.float.helper").make_border_opts({
              "+", "─", "+", "│", "+", "─", "+", "│",
            }, "Normal"),
            width = width,
            height = height,
            row = 10,
            col = math.floor((vim.o.columns - width) / 2),
          }
        end,
      },
  hide_cursor = true,
  on_init = function()
    -- use visual mode
    vim.api.nvim_buf_set_keymap(
      0,
      "x",
      "J",
      ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
      { noremap = true, silent = true }
    )

    -- echo cwd
    vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
  end,
}

-- custom folder icon
require'nvim-web-devicons'.set_icon({
  lir_folder_icon = {
    icon = "",
    color = "#7ebae4",
    name = "LirFolderNode"
  }
})

vim.api.nvim_set_keymap(
  'n',
  '<C-n>',
  ':<C-u>lua require"lir.float".toggle()<CR>',
  { noremap = true }
)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_altv=1

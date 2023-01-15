 vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'   -- Package manager

  -- Vim Core
  use 'godlygeek/tabular'            -- align columns :Tabularize /--
  use 'andymass/vim-matchup'         -- navigate and highlight matching words
  use 'tpope/vim-sleuth'             -- heuristically set buffer options
  -- wellle/targets.vim

  -- Neovim Core
  use 'nvim-lua/plenary.nvim'
  use 'folke/lua-dev.nvim'                          -- Dev setup for nvim lua API
  use 'ojroques/nvim-osc52'
  use 'kyazdani42/nvim-web-devicons'
  use 'cappyzawa/trim.nvim'   			    -- trim trailing space
  use 'nathom/filetype.nvim'                        -- faster filetype recognition
  use 'antoinemadec/FixCursorHold.nvim'
  use 'ahmedkhalf/project.nvim'
  use 'b0o/schemastore.nvim'
  use 'lewis6991/impatient.nvim'                    -- Improve startup time for Neovim

  -- Syntax & diagnostics
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "neovim/nvim-lspconfig"
  use 'nanotee/nvim-lsp-basics'
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

  -- TODO
  --
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

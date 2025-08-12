require('vimrc')
require('keymap')
require('autocommands')

-- Loader (https://github.com/neovim/neovim/commit/2257ade3dc2daab5ee12d27807c0b3bcf103cd29)
-- vim.loader.enable()

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'nvim-tree/nvim-web-devicons',
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = { indent = { char = '┊' }, scope = { enabled = false }, whitespace = { remove_blankline_trail = false } }
  },
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'tomtom/tcomment_vim',  -- "gc" to comment visual regions/lines
  'mhinz/vim-startify',
  'AckslD/nvim-trevJ.lua',
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
  },
  'folke/todo-comments.nvim',
  'folke/which-key.nvim', -- Useful plugin to show you pending keybinds.
  'lewis6991/gitsigns.nvim',
  'ojroques/nvim-osc52',
  { 'folke/trouble.nvim', opts = {} },
  {
    'ruifm/gitlinker.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'ojroques/nvim-osc52' },
    event = {'BufReadPre', 'BufNewFile'},
    config = function ()
      require'gitlinker'.setup{
        opts = {
          -- print the url after performing the action
          print_url = false,
          action_callback = function(url)
            -- yank to unnamed register
            vim.api.nvim_command('let @" = \'' .. url .. '\'')
            -- copy to the system clipboard using OSC52
            require('osc52').copy_register('"')
          end,
        },
      }
    end
  },
  {
    "ibhagwan/fzf-lua",
    opts = {
      file_icon_padding = '',
      winopts = { width = 0.90, preview = { horizontal = "right:50%" } },
      files = { path_shorten = 5 },
    }
  },
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      skip_confirm_for_simple_edits = true,
      keymaps = {
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-p>"] = "actions.preview",
        ["<CR>"] = {
          callback = function(opts)
            local oil = require('oil')
            opts = opts or {}
            local entry = oil.get_cursor_entry()
            if entry ~= nil and entry.type == "file" then
              opts = vim.tbl_deep_extend('force', opts, { vertical = true })
            end
            oil.select(opts)
          end
        },
        ["<Esc>"] = { "actions.close", mode = "n" },
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = false,
      },
      float = {
        padding = 10,
      },
    },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    'echasnovski/mini.statusline',
    version = '*',
    config = function()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'javascript', 'typescript', 'rust' },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      -- 'hrsh7th/cmp-nvim-lsp',
      'saghen/blink.cmp',
    },
    config = function()
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = false,
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities({}, false))

      capabilities = vim.tbl_deep_extend('force', capabilities, {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
          }
        }
      })

      vim.lsp.enable('eslint')
      vim.lsp.enable('lua_ls')
      vim.lsp.enable('quick_lint_js')
      vim.lsp.enable('json_ls')
      vim.lsp.enable('rust_analyzer')
    end,
  },
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  -- {
  --   'cordx56/rustowl',
  --   version = '*', -- Latest stable version
  --   -- build = 'cargo binstall rustowl',
  --   lazy = false, -- This plugin is already lazy
  --   opts = {
  --     client = {
  --       cmd = { '/root/.cargo/bin/rustowl' },
  --       on_attach = function(_, buffer)
  --         vim.keymap.set('n', '<leader>o', function()
  --           require('rustowl').toggle(buffer)
  --         end, { buffer = buffer, desc = 'Toggle RustOwl' })
  --       end
  --     },
  --   },
  -- },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },
    event = {'BufReadPre', 'BufNewFile'},

    -- use a release tag to download pre-built binaries
    version = '1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'enter',
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  }
})

vim.cmd.colorscheme 'everforest'

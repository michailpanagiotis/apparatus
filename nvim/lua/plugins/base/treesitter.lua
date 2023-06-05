local TreeSitterPlugin = {'nvim-treesitter/nvim-treesitter'}

TreeSitterPlugin.version = '0.8.5'
TreeSitterPlugin.lazy = false
TreeSitterPlugin.module = false
TreeSitterPlugin.build = ":TSUpdate"

TreeSitterPlugin.config = function ()
  local config = {
    on_config_done = nil,
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'help', 'lua', 'typescript', 'javascript', 'rust', 'go', 'python', 'vim' },
    ignore_install = {},
    matchup = {
      enable = true, -- mandatory, false will disable the whole extension
      -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
    },
    highlight = {
      enable = true, -- false will disable the whole extension
      additional_vim_regex_highlighting = true,
      disable = { "latex" },
    },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
      config = {
        -- Languages that have a single comment style
        typescript = "// %s",
        css = "/* %s */",
        scss = "/* %s */",
        html = "<!-- %s -->",
        svelte = "<!-- %s -->",
        vue = "<!-- %s -->",
        json = "",
      },
    },
    indent = { enable = false, disable = { "yaml", "python" } },
    autotag = { enable = true },
    textobjects = {
      swap = {
        enable = false,
        -- swap_next = textobj_swap_keymaps,
      },
      -- move = textobj_move_keymaps,
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          -- you can optionally set descriptions to the mappings (used in the desc parameter of nvim_buf_set_keymap
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        },
        -- You can choose the select mode (default is charwise 'v')
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding xor succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        include_surrounding_whitespace = true,
      },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "v",
        node_decremental = "V",
        scope_incremental = "grc",
        node_decremental = ",",
      },
    },
    playground = {
      enable = false,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
    rainbow = {
      enable = false,
      extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
      max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
    },
    refactor = {
      smart_rename = {
        enable = true,
        keymaps = {
          smart_rename = "grr",
        },
      },
      highlight_current_scope = { enable = false },
      highlight_definitions = {
        enable = true,
        -- Set to false if you have an `updatetime` of ~100.
        clear_on_cursor_move = true,
      },
    },
    autopairs = {
      enable = true,
    }
  }

  local treesitter_configs = require "nvim-treesitter.configs"
  treesitter_configs.setup(config)
end

return {
  TreeSitterPlugin,
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {'nvim-treesitter/nvim-treesitter'}
  },
  {
    'RRethy/nvim-treesitter-textsubjects',
    dependencies = {'nvim-treesitter/nvim-treesitter'}
  },
  {
    'nvim-treesitter/nvim-treesitter-refactor',
    dependencies = {'nvim-treesitter/nvim-treesitter'}
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    dependencies = {'nvim-treesitter/nvim-treesitter'}
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = {'nvim-treesitter/nvim-treesitter'}
  },
}

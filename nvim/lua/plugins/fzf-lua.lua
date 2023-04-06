local Plugin = {'ibhagwan/fzf-lua'}

Plugin.event = {'BufReadPre', 'BufNewFile'}
Plugin.lazy = false

function Plugin.config(LazyPlugin, opts)
  local actions = require "fzf-lua.actions"
  require('fzf-lua').setup({
    winopts = {
      preview = {
        -- default     = 'bat',           -- override the default previewer?
      },
    },
    fzf_opts = {
      -- options are sent as `<left>=<right>`
      -- set to `false` to remove a flag
      -- set to '' for a non-value flag
      -- for raw args use `fzf_args` instead
      ['--ansi']        = '',
      ['--info']        = 'inline',
      ['--height']      = '100%',
      ['--layout']      = 'reverse',
      ['--border']      = 'left',
    },
    -- fzf '--color=' options (optional)
    previewers = {
      cat = {
        cmd             = "cat",
        args            = "--number",
      },
      bat = {
        cmd             = "bat",
        args            = "--style=numbers,changes --color always",
        theme           = 'Coldark-Dark', -- bat preview theme (bat --list-themes)
        config          = nil,            -- nil uses $BAT_CONFIG_PATH
      },
      head = {
        cmd             = "head",
        args            = nil,
      },
      git_diff = {
        cmd_deleted     = "git diff --color HEAD --",
        cmd_modified    = "git diff --color HEAD",
        cmd_untracked   = "git diff --color --no-index /dev/null",
        -- uncomment if you wish to use git-delta as pager
        -- can also be set under 'git.status.preview_pager'
        -- pager        = "delta --width=$FZF_PREVIEW_COLUMNS",
      },
      man = {
        -- NOTE: remove the `-c` flag when using man-db
        cmd             = "man -c %s | col -bx",
      },
      builtin = {
        syntax          = true,         -- preview syntax highlight?
        syntax_limit_l  = 0,            -- syntax limit (lines), 0=nolimit
        syntax_limit_b  = 1024*1024,    -- syntax limit (bytes), 0=nolimit
        limit_b         = 1024*1024*10, -- preview limit (bytes), 0=nolimit
        -- preview extensions using a custom shell command:
        -- for example, use `viu` for image previews
        -- will do nothing if `viu` isn't executable
        extensions      = {
          -- neovim terminal only supports `viu` block output
          ["png"]       = { "viu", "-b" },
          ["jpg"]       = { "ueberzug" },
        },
        -- if using `ueberzug` in the above extensions map
        -- set the default image scaler, possible scalers:
        --   false (none), "crop", "distort", "fit_contain",
        --   "contain", "forced_cover", "cover"
        -- https://github.com/seebye/ueberzug
        ueberzug_scaler = "cover",
      },
    },
    -- provider setup
    files = {
      previewer      = false,          -- uncomment to override previewer
                                          -- (name from 'previewers' table)
                                          -- set to 'false' to disable
      prompt            = 'Files❯ ',
      multiprocess      = true,           -- run command in a separate process
      git_icons         = true,           -- show git icons?
      file_icons        = true,           -- show file icons?
      color_icons       = true,           -- colorize file|git icons
      -- path_shorten   = 1,              -- 'true' or number, shorten path?
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
      -- default options are controlled by 'fd|rg|find|_opts'
      -- NOTE: 'find -printf' requires GNU find
      -- cmd            = "find . -type f -printf '%P\n'",
      find_opts         = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
      rg_opts           = "--color=never --files --hidden --follow -g '!.git'",
      fd_opts           = "--color=never --type f --hidden --follow --exclude .git",
      actions = {
        -- inherits from 'actions.files', here we can override
        -- or set bind to 'false' to disable a default action
        ["default"]     = actions.file_edit,
        -- custom actions are available too
        ["ctrl-y"]      = function(selected) print(selected[1]) end,
      }
    },
    grep = {
      prompt            = 'Rg❯ ',
      input_prompt      = 'Grep For❯ ',
      multiprocess      = true,           -- run command in a separate process
      git_icons         = true,           -- show git icons?
      file_icons        = true,           -- show file icons?
      color_icons       = true,           -- colorize file|git icons
      -- executed command priority is 'cmd' (if exists)
      -- otherwise auto-detect prioritizes `rg` over `grep`
      -- default options are controlled by 'rg|grep_opts'
      -- cmd            = "rg --vimgrep",
      grep_opts         = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp",
      rg_opts           = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
      -- set to 'true' to always parse globs in both 'grep' and 'live_grep'
      -- search strings will be split using the 'glob_separator' and translated
      -- to '--iglob=' arguments, requires 'rg'
      -- can still be used when 'false' by calling 'live_grep_glob' directly
      rg_glob           = false,        -- default to glob parsing?
      glob_flag         = "--iglob",    -- for case sensitive globs use '--glob'
      glob_separator    = "%s%-%-",     -- query separator pattern (lua): ' --'
      -- advanced usage: for custom argument parsing define
      -- 'rg_glob_fn' to return a pair:
      --   first returned argument is the new search query
      --   second returned argument are addtional rg flags
      -- rg_glob_fn = function(query, opts)
      --   ...
      --   return new_query, flags
      -- end,
      actions = {
        -- actions inherit from 'actions.files' and merge
        -- this action toggles between 'grep' and 'live_grep'
        ["ctrl-g"]      = { actions.grep_lgrep }
      },
      no_header             = false,    -- hide grep|cwd header?
      no_header_i           = false,    -- hide interactive header?
    },
    colorschemes = {
      prompt            = 'Colorschemes❯ ',
      live_preview      = true,       -- apply the colorscheme on preview?
      actions           = { ["default"] = actions.colorscheme, },
      winopts           = { height = 0.55, width = 0.30, },
      post_reset_cb     = function()
        -- reset statusline highlights after
        -- a live_preview of the colorscheme
        -- require('feline').reset_highlights()
      end,
    },
    quickfix = {
      file_icons        = true,
      git_icons         = true,
    },
    lsp = {
      prompt_postfix    = '❯ ',       -- will be appended to the LSP label
                                      -- to override use 'prompt' instead
      cwd_only          = false,      -- LSP/diagnostics for cwd only?
      async_or_timeout  = 5000,       -- timeout(ms) or 'true' for async calls
      file_icons        = true,
      git_icons         = false,
      ui_select         = true,       -- use 'vim.ui.select' for code actions
      -- settings for 'lsp_{document|workspace|lsp_live_workspace}_symbols'
      symbols = {
          async_or_timeout  = true,       -- symbols are async by default
          symbol_style      = 1,          -- style for document/workspace symbols
                                          -- false: disable,    1: icon+kind
                                          --     2: icon only,  3: kind only
                                          -- NOTE: icons are extracted from
                                          -- vim.lsp.protocol.CompletionItemKind
          -- colorize using nvim-cmp's CmpItemKindXXX highlights
          -- can also be set to 'TS' for treesitter highlights ('TSProperty', etc)
          -- or 'false' to disable highlighting
          symbol_hl_prefix  = "CmpItemKind",
          -- additional symbol formatting, works with or without style
          symbol_fmt        = function(s) return "["..s.."]" end,
      },
    },
    file_icon_colors = {
      ["sh"] = "green",
    },
	})

  vim.keymap.set('n', '<c-P>',
      "<cmd>lua require('fzf-lua').files()<CR>",
      { silent = true })

      vim.keymap.set('n', '<c-F>',
      "<cmd>lua require('fzf-lua').grep()<CR>",
      { silent = true })

  vim.keymap.set('n', 'git',
      "<cmd>lua require('fzf-lua').git_status()<CR>",
      { silent = true })

  vim.keymap.set('n', 'glog',
      "<cmd>lua require('fzf-lua').git_commits()<CR>",
      { silent = true })
end

return Plugin

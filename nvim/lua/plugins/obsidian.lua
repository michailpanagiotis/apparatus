local Plugin = {'epwalsh/obsidian.nvim'}

Plugin.event = {'BufReadPre', 'BufNewFile'}
Plugin.version = "*"
Plugin.lazy = true
Plugin.ft = "markdown"
Plugin.dependencies = {
  -- Required.
  "nvim-lua/plenary.nvim",

  -- see below for full list of optional dependencies 👇
  "hrsh7th/nvim-cmp",
  "ibhagwan/fzf-lua",
  "nvim-treesitter/nvim-treesitter",
}

Plugin.config = function ()
  require"obsidian".setup{
    workspaces = {
      {
        name = "personal",
        path = "~/Obsidian",
      },
    },

    -- see below for full list of options 👇
    log_level = vim.log.levels.INFO,
  }
  vim.cmd("let conceallevel = 1")
end

return Plugin

local Plugin = {'epwalsh/obsidian.nvim'}

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
    open_notes_in = "vsplit",
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      }
    },
    ui = {
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo", order = 1 },
        [">"] = { char = "󰣖", hl_group = "ObsidianCog", order = 2 },
        ["x"] = { char = "", hl_group = "ObsidianDone", order = 3 },
        -- ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      },
      hl_groups = {
        -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
        ObsidianTodo = { bold = true, fg = "#f78c6c" },
        ObsidianDone = { bold = true, fg = "#89ddff" },
        ObsidianCog = { bold = true, fg = "#ff5370" },
      },

    },

    -- see below for full list of options 👇
    log_level = vim.log.levels.INFO,
  }
  vim.cmd("set conceallevel=1")
end

return Plugin

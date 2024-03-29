local Plugin = {'nvim-lualine/lualine.nvim'}

Plugin.dependencies = {
  'SmiteshP/nvim-navic',
  'https://gitlab.com/__tpb/monokai-pro.nvim',
  'arkav/lualine-lsp-progress',
}

Plugin.config = function ()
  local colors = {
    bg = "#202328",
    fg = "#bbc2cf",
    yellow = "#ECBE7B",
    cyan = "#008080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    purple = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67",
  }

  local window_width_limit = 70

  local function hideInWidth()
    return vim.fn.winwidth(0) > window_width_limit
  end

  local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
      return {
        added = gitsigns.added,
        modified = gitsigns.changed,
        removed = gitsigns.removed,
      }
    end
  end

  function GetCurrentDiagnostic()
    bufnr = 0
    line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1
    opts = { ["lnum"] = line_nr }

    local line_diagnostics = vim.diagnostic.get(bufnr, opts)
    if vim.tbl_isempty(line_diagnostics) then
      return
    end

    local best_diagnostic = nil

    for _, diagnostic in ipairs(line_diagnostics) do
      if
        best_diagnostic == nil or diagnostic.severity < best_diagnostic.severity
      then
        best_diagnostic = diagnostic
      end
    end

    return best_diagnostic
  end

  function GetCurrentDiagnosticString()
    local diagnostic = GetCurrentDiagnostic()

    if not diagnostic or not diagnostic.message then
      return
    end

    local message = vim.split(diagnostic.message, "\n")[1]
    local max_width = vim.api.nvim_win_get_width(0) - 35

    if string.len(message) < max_width then
      return message
    else
      return string.sub(message, 1, max_width) .. "..."
    end
  end

  local components = {
    mode = {
      function()
        return " "
      end,
      padding = { left = 0, right = 0 },
      color = {},
      cond = nil,
    },
    branch = {
      "b:gitsigns_head",
      icon = " ",
      color = { gui = "bold" },
      cond = hideInWidth,
    },
    filename = {
      "filename",
      color = {},
      cond = nil,
      path = 1,
    },
    diff = {
      "diff",
      source = diff_source,
      symbols = { added = "  ", modified = " ", removed = " " },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.yellow },
        removed = { fg = colors.red },
      },
      cond = nil,
    },
    diagnostics = {
      "diagnostics",
      sources = { "nvim_diagnostic" },
      symbols = { error = " ", warn = " ", info = " ", hint = " " },
      cond = hideInWidth,
    },
    lsp_progress = {
      'lsp_progress',
      display_components = { { 'percentage', 'message' }, 'spinner' },
      -- display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' } },
      colors = {
        percentage  = colors.cyan,
        title  = colors.cyan,
        message  = colors.cyan,
        spinner = colors.cyan,
        lsp_client_name = colors.magenta,
        use = true,
      },
      separators = {
        component = ' ',
        progress = ' | ',
        message = { pre = '[', post = ']', commenced = 'In Progress', completed = 'Completed' },
        percentage = { pre = '', post = '%% ' },
        title = { pre = '[', post = ']' },
        lsp_client_name = { pre = '[', post = ']' },
        spinner = { pre = '', post = '' },
      },
      timer = { progress_enddelay = 0, spinner = 100, lsp_client_name_enddelay = 1000 },
      spinner_symbols = {
        "▰▱▱▱▱▱▱",
        "▰▰▱▱▱▱▱",
        "▰▰▰▱▱▱▱",
        "▰▰▰▰▱▱▱",
        "▰▰▰▰▰▱▱",
        "▰▰▰▰▰▰▱",
        "▰▰▰▰▰▰▰",

        -- "🤘 ",
        -- "🤟 ",
        -- "🖖 ",
        -- "✋ ",
        -- "🤚 ",
        -- "👆 "
        --
        -- "┤",
        -- "┘",
        -- "┴",
        -- "└",
        -- "├",
        -- "┌",
        -- "┬",
        -- "┐"
        --
        -- "◐",
        -- "◓",
        -- "◑",
        -- "◒"
      }
    },
    treesitter = {
      function()
        return ""
      end,
      color = function()
        local buf = vim.api.nvim_get_current_buf()
        local ts = vim.treesitter.highlighter.active[buf]
        return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
      end,
      cond = hideInWidth,
    },
    location = { "location", cond = hideInWidth, color = {} },
    progress = { "progress", cond = hideInWidth, color = {} },
    spaces = {
      function()
        if not vim.api.nvim_buf_get_option(0, "expandtab") then
          return "Tab size: " .. vim.api.nvim_buf_get_option(0, "tabstop") .. " "
        end
        local size = vim.api.nvim_buf_get_option(0, "shiftwidth")
        if size == 0 then
          size = vim.api.nvim_buf_get_option(0, "tabstop")
        end
        return "Spaces: " .. size .. " "
      end,
      cond = hideInWidth,
      color = {},
    },
    encoding = {
      "o:encoding",
      fmt = string.upper,
      color = {},
      cond = hideInWidth,
    },
    filetype = { "filetype", cond = hideInWidth },
    scrollbar = {
      function()
        local current_line = vim.fn.line "."
        local total_lines = vim.fn.line "$"
        local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
        local line_ratio = current_line / total_lines
        local index = math.ceil(line_ratio * #chars)
        return chars[index]
      end,
      padding = { left = 0, right = 0 },
      color = { fg = colors.yellow, bg = colors.bg },
      cond = nil,
    },
  }

  local navic = require("nvim-navic")
  local lualineConfig = {
    options = {
      theme = "monokaipro",
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "alpha", "NvimTree", "Outline" },
      globalstatus = false,
    },
    sections = {
      lualine_a = {
        components.mode,
      },
      lualine_b = {
        components.branch,
        components.filename,
      },
      lualine_c = {
        components.diff,
        { navic.get_location, cond = navic.is_available },
      },
      lualine_x = {
        components.lsp_progress,
        components.diagnostics,
        components.treesitter,
        components.lsp,
        components.filetype,
      },
      lualine_y = {},
      lualine_z = {
        components.scrollbar,
      },
    },
    inactive_sections = {
      lualine_a = {
        "filename",
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = nil,
    extensions = { "nvim-tree" },
  }

  local lualine = require "lualine"
  lualine.setup(lualineConfig)
end

return Plugin

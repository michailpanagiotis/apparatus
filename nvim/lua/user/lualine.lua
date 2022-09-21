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

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand "%:t") ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > window_width_limit
  end,
  -- check_git_workspace = function()
  --   local filepath = vim.fn.expand "%:p:h"
  --   local gitdir = vim.fn.finddir(".git", filepath .. ";")
  --   return gitdir and #gitdir > 0 and #gitdir < #filepath
  -- end,
}

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
    cond = conditions.hide_in_width,
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
  python_env = {
    function()
      local utils = require "lvim.core.lualine.utils"
      if vim.bo.filetype == "python" then
        local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
        if venv then
          return string.format("  (%s)", utils.env_cleanup(venv))
        end
      end
      return ""
    end,
    color = { fg = colors.green },
    cond = conditions.hide_in_width,
  },
  diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
    cond = conditions.hide_in_width,
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
    cond = conditions.hide_in_width,
  },
  lsp = {
    function(msg)
      msg = msg or "LS Inactive"
      local buf_clients = vim.lsp.buf_get_clients()
      if next(buf_clients) == nil then
        -- TODO: clean up this if statement
        if type(msg) == "boolean" or #msg == 0 then
          return "LS Inactive"
        end
        return msg
      end
      local buf_ft = vim.bo.filetype
      local buf_client_names = {}

      -- add client
      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" then
          table.insert(buf_client_names, client.name)
        end
      end

      -- add formatter
      local formatters = require "lvim.lsp.null-ls.formatters"
      local supported_formatters = formatters.list_registered(buf_ft)
      vim.list_extend(buf_client_names, supported_formatters)

      -- add linter
      local linters = require "lvim.lsp.null-ls.linters"
      local supported_linters = linters.list_registered(buf_ft)
      vim.list_extend(buf_client_names, supported_linters)

      local unique_client_names = vim.fn.uniq(buf_client_names)
      return "[" .. table.concat(unique_client_names, ", ") .. "]"
    end,
    color = { gui = "bold" },
    cond = conditions.hide_in_width,
  },
  location = { "location", cond = conditions.hide_in_width, color = {} },
  progress = { "progress", cond = conditions.hide_in_width, color = {} },
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
    cond = conditions.hide_in_width,
    color = {},
  },
  encoding = {
    "o:encoding",
    fmt = string.upper,
    color = {},
    cond = conditions.hide_in_width,
  },
  filetype = { "filetype", cond = conditions.hide_in_width },
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

local config = {
  options = {
    theme = "auto",
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
      components.python_env,
    },
    lualine_x = {
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

lualine.setup(config)

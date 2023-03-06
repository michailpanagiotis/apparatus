---Join path segments that were passed as input
---@return string
local function join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

return {
  templates_dir = join_paths(vim.call("stdpath", "data"), "site", "after", "ftplugin"),
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
      },
    },
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          return string.format("%s [%s]", d.message, code):gsub("1. ", "")
        end
        return d.message
      end,
    },
  },
  document_highlight = true,
  code_lens_refresh = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
  },
  peek = {
    max_height = 15,
    max_width = 30,
    context = 10,
  },
  on_attach_callback = nil,
  on_init_callback = nil,
  automatic_configuration = {
    ---@usage list of servers that the automatic installer will skip
    skipped_servers = skipped_servers,
    ---@usage list of filetypes that the automatic installer will skip
    skipped_filetypes = skipped_filetypes,
  },
  buffer_mappings = {
    normal_mode = {
      -- ["K"] = { vim.lsp.buf.hover, "Show hover" },
      -- ["gd"] = { vim.lsp.buf.definition, "Goto Definition" },
      -- ["gD"] = { vim.lsp.buf.declaration, "Goto declaration" },
      -- ["gr"] = { vim.lsp.buf.references, "Goto references" },
      -- ["gI"] = { vim.lsp.buf.implementation, "Goto Implementation" },
      -- ["gs"] = { vim.lsp.buf.signature_help, "show signature help" },
      -- ["gp"] = {
      --   function()
      --     require("user.lsp.peek").Peek "definition"
      --   end,
      --   "Peek definition",
      -- },
      -- ["gl"] = {
      --   function()
      --     local config = lvim.lsp.diagnostics.float
      --     config.scope = "line"
      --     vim.diagnostic.open_float(0, config)
      --   end,
      --   "Show line diagnostics",
      -- },
    },
    insert_mode = {},
    visual_mode = {},
  },
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },
  ---@usage list of settings of nvim-lsp-installer
  installer = {
    setup = {
      ensure_installed = {},
      automatic_installation = {
        exclude = {},
      },
    },
  },
  nlsp_settings = {
    setup = {
      config_home = join_paths(vim.call("stdpath", "config"), "lsp-settings"),
      -- set to false to overwrite schemastore.nvim
      append_default_schemas = true,
      ignored_servers = {},
      loader = "json",
    },
  },
  null_ls = {
    setup = {},
    config = {},
  },
  ---@deprecated use lvim.lsp.automatic_configuration.skipped_servers instead
  override = {},
  ---@deprecated use lvim.lsp.installer.setup.automatic_installation instead
  automatic_servers_installation = nil,
}

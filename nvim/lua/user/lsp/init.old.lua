local lspParams = require('user.lsp.config')

local function setup_document_highlight(client, bufnr)
  local status_ok, highlight_supported = pcall(function()
    return client.supports_method "textDocument/documentHighlight"
  end)
  if not status_ok or not highlight_supported then
    return
  end
  local augroup_exist, _ = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_document_highlight",
  })
  if not augroup_exist then
    vim.api.nvim_create_augroup("lsp_document_highlight", {})
  end
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    group = "lsp_document_highlight",
    buffer = bufnr,
    callback = vim.lsp.buf.document_highlight,
  })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = "lsp_document_highlight",
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end

local function setup_codelens_refresh(client, bufnr)
  local status_ok, codelens_supported = pcall(function()
    return client.supports_method "textDocument/codeLens"
  end)
  if not status_ok or not codelens_supported then
    return
  end
  local augroup_exist, _ = pcall(vim.api.nvim_get_autocmds, {
    group = "lsp_code_lens_refresh",
  })
  if not augroup_exist then
    vim.api.nvim_create_augroup("lsp_code_lens_refresh", {})
  end
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
    group = "lsp_code_lens_refresh",
    buffer = bufnr,
    callback = vim.lsp.codelens.refresh,
  })
end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
local function clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds { group = name }
    end)
  end)
end

-- Set Default Prefix.
-- Note: You can set a prefix per lsp server in the lv-globals.lua file
local function setupHandlers()
  local config = { -- your config
    virtual_text = lspParams.diagnostics.virtual_text,
    signs = lspParams.diagnostics.signs,
    underline = lspParams.diagnostics.underline,
    update_in_insert = lspParams.diagnostics.update_in_insert,
    severity_sort = lspParams.diagnostics.severity_sort,
    float = lspParams.diagnostics.float,
  }
  vim.diagnostic.config(config)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lspParams.float)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lspParams.float)
end


local function add_lsp_buffer_options(bufnr)
  for k, v in pairs(lspParams.buffer_options) do
    vim.api.nvim_buf_set_option(bufnr, k, v)
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  local mappings = {
    normal_mode = "n",
    insert_mode = "i",
    visual_mode = "v",
  }

  for mode_name, mode_char in pairs(mappings) do
    for key, remap in pairs(lspParams.buffer_mappings[mode_name]) do
      local opts = { buffer = bufnr, desc = remap[2], noremap = true, silent = true }
      vim.keymap.set(mode_char, key, remap[1], opts)
    end
  end
end

local function common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.default_capabilities()
  end

  return capabilities
end

local function common_on_exit(_, _)
  if lspParams.document_highlight then
    clear_augroup "lsp_document_highlight"
  end
  if lspParams.code_lens_refresh then
    clear_augroup "lsp_code_lens_refresh"
  end
end

local function common_on_init(client, bufnr)
  if lspParams.on_init_callback then
    lspParams.on_init_callback(client, bufnr)
    return
  end
end

local function common_on_attach(client, bufnr)
  if lspParams.on_attach_callback then
    lspParams.on_attach_callback(client, bufnr)
  end
  if lspParams.document_highlight then
    setup_document_highlight(client, bufnr)
  end
  if lspParams.code_lens_refresh then
    setup_codelens_refresh(client, bufnr)
  end
  add_lsp_buffer_keybindings(bufnr)
  add_lsp_buffer_options(bufnr)
end

local resolve_config = function(...)
  local defaults = {
    on_attach = common_on_attach,
    on_init = common_on_init,
    on_exit = common_on_exit,
    capabilities = common_capabilities(),
  }

  defaults = vim.tbl_deep_extend("force", defaults, ...)

  return defaults
end

require('user.lsp.mason')
local lspconfig = require('lspconfig')
lspconfig.sumneko_lua.setup(resolve_config({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = { enable = false, },
    },
  },
}))

require("typescript").setup({
  disable_commands = false, -- prevent the plugin from creating Vim commands
  debug = false, -- enable debug logging for commands
  go_to_source_definition = {
      fallback = true, -- fall back to standard LSP definition on failure
  },
  server = resolve_config({
    root_dir = lspconfig.util.root_pattern("package.json", "lerna.json", ".git"),
  }),
})

for _, sign in ipairs(lspParams.diagnostics.signs.values) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
end

setupHandlers()

-- require("lvim.lsp.null-ls").setup()

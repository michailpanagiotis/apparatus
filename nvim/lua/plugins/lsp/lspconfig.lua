local Plugin = {'neovim/nvim-lspconfig'}

Plugin.dependencies = {
  'nanotee/nvim-lsp-basics',
  'hrsh7th/cmp-nvim-lsp',
}
Plugin.lazy = false
Plugin.module = false

Plugin.config = function ()
  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  local opts = { noremap=true, silent=true }
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  end


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

  local function add_lsp_buffer_options(bufnr)
    local buffer_options = {
      --- enable completion triggered by <c-x><c-o>
      omnifunc = "v:lua.vim.lsp.omnifunc",
      --- use gq for formatting
      formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
    }
    for k, v in pairs(buffer_options) do
      vim.api.nvim_buf_set_option(bufnr, k, v)
    end
  end

  local function add_lsp_buffer_keybindings(bufnr)
    local mappings = {
      normal_mode = "n",
      insert_mode = "i",
      visual_mode = "v",
    }

    local buffer_mappings = {
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
    }

    for mode_name, mode_char in pairs(mappings) do
      for key, remap in pairs(buffer_mappings[mode_name]) do
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
    clear_augroup "lsp_document_highlight"
    clear_augroup "lsp_code_lens_refresh"
  end

  local function common_on_init(client, bufnr)
  end

  local function common_on_attach(client, bufnr)
    setup_document_highlight(client, bufnr)
    setup_codelens_refresh(client, bufnr)

    add_lsp_buffer_keybindings(bufnr)
    add_lsp_buffer_options(bufnr)

    local basics = require('lsp_basics')

    basics.make_lsp_commands(client, bufnr)
    basics.make_lsp_mappings(client, bufnr)
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


  local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
  }
  -- require('lspconfig')['vtsls'].setup(resolve_config({
  --   flags = lsp_flags,
  -- }))
  --
  require'lspconfig'.ruff_lsp.setup{
    init_options = {
      settings = {
        -- Any extra CLI arguments for `ruff` go here.
        args = { "--config", "/root/.apparatus/.ruff.toml" }
      }
    }
  }
end

return Plugin

local runtime_path = vim.split(package.path, ';')
local opts = {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      telemetry = { enable = false, },
    },
  },
}

return opts

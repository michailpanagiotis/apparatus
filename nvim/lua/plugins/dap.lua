local DapPlugin = {'mfussenegger/nvim-dap'}

local js_based_languages = {
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "vue",
}

DapPlugin.dependencies = {
  -- Install the vscode-js-debug adapter
  {
    "microsoft/vscode-js-debug",
    -- After install, build it and rename the dist directory to out
    build = "npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
    version = "1.*",
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("dap-vscode-js").setup({
        -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        -- node_path = "node",

        -- Path to vscode-js-debug installation.
        -- debugger_path = "/root/Projects/vscode-js-debug/out/src",

        -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
        debugger_cmd = { "js-debug-adapter" },

        -- which adapters to register in nvim-dap
        adapters = {
          "chrome",
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
          "pwa-extensionHost",
          "node-terminal",
        },

        -- Path for file logging
        log_file_path = "/root/dap_vscode_js.log",

        -- Logging level for output to file. Set to false to disable logging.
        log_file_level = vim.log.levels.DEBUG,

        -- Logging level for output to console. Set to false to disable console output.
        log_console_level = vim.log.levels.DEBUG,
      })
    end,
  },
}

DapPlugin.event = {'BufReadPre', 'BufNewFile'}

DapPlugin.keys =  {
  {
    "<leader>dO",
    function()
      require("dap").step_out()
    end,
    desc = "Step Out",
  },
  {
    "<leader>do",
    function()
      require("dap").step_over()
    end,
    desc = "Step Over",
  },
  {
    "<leader>da",
    function()
      if vim.fn.filereadable(".vscode/launch.json") then
        local dap_vscode = require("dap.ext.vscode")
        dap_vscode.load_launchjs(nil, {
          ["pwa-node"] = js_based_languages,
          ["chrome"] = js_based_languages,
          ["pwa-chrome"] = js_based_languages,
        })
      end
      require("dap").continue()
    end,
    desc = "Run with Args",
  },
}

DapPlugin.config = function()
  local dap = require("dap")
  vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

  for _, language in ipairs(js_based_languages) do
    dap.configurations[language] = {
      {
        address= "127.0.0.1",
        name = "Attach: Docker",
        type = "pwa-node",
        request = "attach",
        skipFiles = {"<node_internals>/**"},
        cwd = "${workspaceFolder}",
        localRoot = "${workspaceFolder}",
        remoteRoot = "/app",
        restart = true
      }
    }
  end
end

return {
  DapPlugin
}

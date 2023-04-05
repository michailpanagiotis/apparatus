local Plugin = {'ahmedkhalf/project.nvim'}

Plugin.event = {'BufReadPre', 'BufNewFile'}

Plugin.config = function ()
  require("project_nvim").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
end

return Plugin

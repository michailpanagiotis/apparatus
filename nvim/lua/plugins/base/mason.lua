local MasonPlugin = {'williamboman/mason.nvim'}

MasonPlugin.lazy = false
MasonPlugin.module = false
MasonPlugin.build = ":TSUpdate"

MasonPlugin.config = function ()
  local configs = require "mason"
  configs.setup()
end

return {
  MasonPlugin,
}

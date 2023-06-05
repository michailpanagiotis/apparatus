local load = function(mod)
  package.loaded[mod] = nil
  require(mod)
end

load('user.settings')
load('user.commands')
load('user.keymaps')
load('user.diagnostics')

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  -- You can "comment out" the line below after lazy.nvim is installed
  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)
  require('lazy').setup(plugins, lazy.opts)
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
  {import = 'plugins/base'},
  {import = 'plugins/lsp'},
  {import = 'plugins'},
  {import = 'plugins/theme'},
  {import = 'plugins/editing'},
  {import = 'plugins/git'},
  {import = 'plugins/optimizations'},
  {import = 'plugins/moving'},
})

pcall(vim.cmd.colorscheme, 'everforest')

local map = vim.keymap.set
-- Remap y to ygv<esc> in visual mode so the cursor does not jump back to where you started the selection.
map("v", "y", "ygv<esc>")

-- qq starts recording, q stops, Q runs it.
map("n", "Q" , "@q")
map("v", "Q" , ":norm @q<cr>")

-- -- Center to focus
-- map("n", "{", "{zz")
-- map("n", "}", "}zz")
-- map("n", "n", "nzz")
-- map("n", "N", "Nzz")
-- map("n", "G", "Gzz")
-- map("n", "i", "zzi")
-- map("n", "I", "zzI")
-- map("n", "o", "zzo")
-- map("n", "O", "zzO")
-- map("n", "a", "zza")
-- map("n", "A", "zzA")
-- map("n", "s", "zzs")
-- map("n", "S", "zzS")
-- map("n", "c", "zzc")
-- map("n", "C", "zzC")

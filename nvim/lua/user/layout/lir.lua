local actions = require'lir.actions'
local lirFloat = require'lir.float'
local mark_actions = require 'lir.mark.actions'
local clipboard_actions = require'lir.clipboard.actions'
local lir = require'lir'

lir.setup {
  show_hidden_files = false,
  devicons = {
    enable = true,
  },
  mappings = {
    ['<CR>']  = actions.edit,
    ['<C-s>'] = actions.split,
    ['<C-v>'] = actions.vsplit,
    ['<C-t>'] = actions.tabedit,

    ['<C-n>'] = function()
      vim.cmd("quit")
    end,
    ['<Esc>'] = function()
      vim.cmd("quit")
    end,
    -- ['q']     = actions.quit,

    ['q']     = actions.up,
    ['-']     = actions.up,

    ['K']     = actions.mkdir,
    ['N']     = actions.newfile,
    ['R']     = actions.rename,
    ['@']     = actions.cd,
    ['Y']     = actions.yank_path,
    ['.']     = actions.toggle_show_hidden,
    ['D']     = actions.delete,

    ['<Space>'] = function()
      mark_actions.toggle_mark()
      vim.cmd('normal! j')
    end,
    ['y'] = clipboard_actions.copy,
    ['p'] = clipboard_actions.paste,
  },
      float = {
        winblend = 15,
        curdir_window = {
          enable = false,
          highlight_name = false
        },

        -- You can define a function that returns a table to be passed as the third
        -- argument of nvim_open_win().
        win_opts = function()
          local width = math.floor(vim.o.columns * 0.6)
          local height = math.floor(vim.o.lines * 0.8)
          return {
            border = require("lir.float.helper").make_border_opts({
              "+", "─", "+", "│", "+", "─", "+", "│",
            }, "Normal"),
            width = width,
            height = height,
            row = 10,
            col = math.floor((vim.o.columns - width) / 2),
          }
        end,
      },
  hide_cursor = true,
  on_init = function()
    -- use visual mode
    vim.api.nvim_buf_set_keymap(
      0,
      "x",
      "J",
      ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
      { noremap = true, silent = true }
    )

    -- echo cwd
    vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
  end,
}

-- custom folder icon
local hasModule,devicons = pcall(require,"nvim-web-devicons")
if hasModule then
  devicons.set_icon({
    lir_folder_icon = {
      icon = "",
      color = "#7ebae4",
      name = "LirFolderNode"
    }
  })
end

vim.api.nvim_set_keymap(
  'n',
  '<C-n>',
  ':<C-u>lua require"lir.float".toggle()<CR>',
  { noremap = true }
)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_altv=1

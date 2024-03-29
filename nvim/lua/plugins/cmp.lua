local LuasnipPlugin = {'L3MON4D3/LuaSnip'}

LuasnipPlugin.dependencies = {
  'saadparwaiz1/cmp_luasnip',
  'rafamadriz/friendly-snippets',
  'ray-x/cmp-treesitter',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
}
LuasnipPlugin.event = {'BufReadPre', 'BufNewFile'}

LuasnipPlugin.config = function ()
  require("luasnip.loaders.from_vscode").lazy_load()
end

local CmpPlugin = {'hrsh7th/nvim-cmp'}

CmpPlugin.dependencies = {
  'hrsh7th/cmp-nvim-lsp',
  'L3MON4D3/LuaSnip',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
}
CmpPlugin.event = {'BufReadPre', 'BufNewFile'}

-- See :help gitsigns-usage
CmpPlugin.config = function ()
  -- https://raw.githubusercontent.com/LunarVim/LunarVim/rolling/lua/lvim/core/cmp.lua

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
  end

  ---when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it is jumpable
  ---@param dir number 1 for forward, -1 for backward; defaults to 1
  ---@return boolean true if a jumpable luasnip field is found while inside a snippet
  local function jumpable(dir)
    local luasnip_ok, luasnip = pcall(require, "luasnip")
    if not luasnip_ok then
      return false
    end

    local win_get_cursor = vim.api.nvim_win_get_cursor
    local get_current_buf = vim.api.nvim_get_current_buf

    ---sets the current buffer's luasnip to the one nearest the cursor
    ---@return boolean true if a node is found, false otherwise
    local function seek_luasnip_cursor_node()
      -- TODO(kylo252): upstream this
      -- for outdated versions of luasnip
      if not luasnip.session.current_nodes then
        return false
      end

      local node = luasnip.session.current_nodes[get_current_buf()]
      if not node then
        return false
      end

      local snippet = node.parent.snippet
      local exit_node = snippet.insert_nodes[0]

      local pos = win_get_cursor(0)
      pos[1] = pos[1] - 1

      -- exit early if we're past the exit node
      if exit_node then
        local exit_pos_end = exit_node.mark:pos_end()
        if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
          snippet:remove_from_jumplist()
          luasnip.session.current_nodes[get_current_buf()] = nil

          return false
        end
      end

      node = snippet.inner_first:jump_into(1, true)
      while node ~= nil and node.next ~= nil and node ~= snippet do
        local n_next = node.next
        local next_pos = n_next and n_next.mark:pos_begin()
        local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
          or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

        -- Past unmarked exit node, exit early
        if n_next == nil or n_next == snippet.next then
          snippet:remove_from_jumplist()
          luasnip.session.current_nodes[get_current_buf()] = nil

          return false
        end

        if candidate then
          luasnip.session.current_nodes[get_current_buf()] = node
          return true
        end

        local ok
        ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
        if not ok then
          snippet:remove_from_jumplist()
          luasnip.session.current_nodes[get_current_buf()] = nil

          return false
        end
      end

      -- No candidate, but have an exit node
      if exit_node then
        -- to jump to the exit node, seek to snippet
        luasnip.session.current_nodes[get_current_buf()] = snippet
        return true
      end

      -- No exit node, exit from snippet
      snippet:remove_from_jumplist()
      luasnip.session.current_nodes[get_current_buf()] = nil
      return false
    end

    if dir == -1 then
      return luasnip.in_snippet() and luasnip.jumpable(-1)
    else
      return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
    end
  end

  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  local snip = luasnip.snippet
  local text = luasnip.text_node
  local insert = luasnip.insert_node
  luasnip.add_snippets(nil, {
      all = {
          snip({
              trig = "jst",
              namr = "Console stringify",
              dscr = "console.log(JSON.stringify...",
          }, {
              text("console.log(JSON.stringify("), insert(0), text(", null, 2));")
          }),
      },
  })

  CmpConfig = {
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      completion = {
        ---@usage The minimum length of a word to complete on.
        keyword_length = 2,
      },
      experimental = {
        ghost_text = true,
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        max_width = 0,
        kind_icons = {
          Class = " ",
          Color = " ",
          Constant = "ﲀ ",
          Constructor = " ",
          Enum = "練",
          EnumMember = " ",
          Event = " ",
          Field = " ",
          File = "",
          Folder = " ",
          Function = " ",
          Interface = "ﰮ ",
          Keyword = " ",
          Method = " ",
          Module = " ",
          Operator = "",
          Property = " ",
          Reference = " ",
          Snippet = " ",
          Struct = " ",
          Text = " ",
          TypeParameter = " ",
          Unit = "塞",
          Value = " ",
          Variable = " ",
        },
        source_names = {
          nvim_lsp = "(LSP)",
          emoji = "(Emoji)",
          path = "(Path)",
          calc = "(Calc)",
          cmp_tabnine = "(Tabnine)",
          vsnip = "(Snippet)",
          luasnip = "(Snip)",
          buffer = "(Buffer)",
          tmux = "(TMUX)",
          nvim_lsp_signature_help = "(Signature)"
        },
        duplicates = {
          buffer = 1,
          path = 1,
          nvim_lsp = 0,
          luasnip = 1,
        },
        duplicates_default = 0,
        format = function(entry, vim_item)
          local max_width = CmpConfig.formatting.max_width
          if max_width ~= 0 and #vim_item.abbr > max_width then
            vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. "…"
          end
          vim_item.menu = CmpConfig.formatting.source_names[entry.source.name]
          vim_item.dup = CmpConfig.formatting.duplicates[entry.source.name]
            or CmpConfig.formatting.duplicates_default
          return vim_item
        end,
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "treesitter" },
        { name = "path" },
        { name = "cmp_tabnine" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "calc" },
        { name = "emoji" },
        { name = "crates" },
        { name = "tmux" },
        { name = 'nvim_lsp_signature_help' },
      },
      mapping = cmp.mapping.preset.insert {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select }, { "i" }),
        ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select }, { "i" }),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-y>"] = cmp.mapping {
          i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
          c = function(fallback)
            if cmp.visible() then
              cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
            else
              fallback()
            end
          end,
        },
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          elseif jumpable(1) then
            luasnip.jump(1)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if cmp.get_active_entry() then
              cmp.select_prev_item()
            else
              cmp.close()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'nt', true)
            end
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            local confirm_opts = vim.deepcopy(CmpConfig.confirm_opts) -- avoid mutating the original opts below
            local is_insert_mode = function()
              return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
            end
            if is_insert_mode() then -- prevent overwriting brackets
              confirm_opts.behavior = cmp.ConfirmBehavior.Insert
            end
            if cmp.confirm(confirm_opts) then
              return -- success, exit early
            end
          end

          if jumpable(1) and luasnip.jump(1) then
            return -- success, exit early
          end
          fallback() -- if not exited early, lys fallback
        end),
    }
  }

  cmp.setup(CmpConfig)
end

return {
  LuasnipPlugin,
  CmpPlugin
}

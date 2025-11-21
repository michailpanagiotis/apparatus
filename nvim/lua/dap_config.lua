-- DAP Configuration for Rust debugging with CodeLLDB
local dap = require('dap')
local dap_ui = require('dapui')

-- Configure CodeLLDB as the Rust debugger
dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = os.getenv('HOME') .. '/.local/share/codelldb/bin/codelldb-wrapper',
    args = { '--port', '${port}' }
  }
}

-- Rust debugging configuration
dap.configurations.rust = {
  {
    name = 'Debug (Binary)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    sourceLanguages = { 'rust' },
    runInTerminal = true,
    initCommands = { 'breakpoint set --name main' }
  },
  {
    name = 'Debug (Cargo)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      -- Build the project first
      local result = os.execute('cargo build 2>&1 > /dev/null')
      if result ~= 0 then
        vim.notify('Cargo build failed', vim.log.levels.ERROR)
        return nil
      end
      return vim.fn.getcwd() .. '/target/debug/plugin_rack'
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    sourceLanguages = { 'rust' },
    runInTerminal = true,
    initCommands = { 'breakpoint set --name main' }
  },
  {
    name = 'Debug (Custom Binary)',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Binary path: ', '', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    sourceLanguages = { 'rust' },
    runInTerminal = true,
    initCommands = { 'breakpoint set --name main' }
  }
}

-- Setup DAP UI
dap_ui.setup({
  controls = {
    element = "repl",
    enabled = true,
    icons = {
      disconnect = "⏹",
      pause = "⏸",
      play = "▶",
      run_last = "▶▶",
      step_back = "b",
      step_into = "⬇",
      step_out = "⬆",
      step_over = "⬇",
      terminate = "⏹"
    }
  },
  element_mappings = {},
  expand_lines = vim.fn.has("nvim-0.10") == 1,
  floating = {
    max_height = nil,
    max_width = nil,
    mappings = {
      close = { "q", "<Esc>" }
    }
  },
  force_buffers = true,
  icons = {
    collapsed = "▶",
    current_frame = "▶",
    expanded = "▼"
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.25 },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      position = "left",
      size = 40
    },
    {
      elements = {
        { id = "repl", size = 0.5 },
        { id = "console", size = 0.5 },
      },
      position = "bottom",
      size = 10
    }
  },
  mappings = {
    edit = "e",
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    repl = "r",
    toggle = "t"
  },
  render = {
    indent = 1,
    max_type_length = nil,
    max_value_length = nil
  }
})

-- Automatically open DAP UI (but keep it open after completion to see output)
local dap_listeners = dap.listeners
dap_listeners.before.event_initialized["dapui_config"] = function()
  dap_ui.open()
end
dap_listeners.before.event_terminated["dapui_config"] = function()
  dap_ui.close()
end
dap_listeners.before.event_exited["dapui_config"] = function()
  dap_ui.close()
end

-- Setup keybindings for DAP
local function setup_dap_keybindings()
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- Debug control
  keymap('n', '<Leader>dc', dap.continue, vim.tbl_extend('force', opts, { desc = 'DAP: Continue' }))
  keymap('n', '<Leader>do', dap.step_over, vim.tbl_extend('force', opts, { desc = 'DAP: Step Over' }))
  keymap('n', '<Leader>di', dap.step_into, vim.tbl_extend('force', opts, { desc = 'DAP: Step Into' }))
  keymap('n', '<Leader>ds', dap.step_out, vim.tbl_extend('force', opts, { desc = 'DAP: Step Out' }))

  -- Breakpoints
  keymap('n', '<Leader>db', dap.toggle_breakpoint, vim.tbl_extend('force', opts, { desc = 'DAP: Toggle Breakpoint' }))
  keymap('n', '<Leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, vim.tbl_extend('force', opts, { desc = 'DAP: Set Conditional Breakpoint' }))

  -- DAP UI
  keymap('n', '<Leader>du', dap_ui.toggle, vim.tbl_extend('force', opts, { desc = 'DAP UI: Toggle' }))
  keymap('n', '<Leader>dq', function()
    dap_ui.close()
    dap.terminate()
  end, vim.tbl_extend('force', opts, { desc = 'DAP: Close UI and Quit Debugging' }))

  -- REPL
  keymap('n', '<Leader>dr', dap.repl.open, vim.tbl_extend('force', opts, { desc = 'DAP: Open REPL' }))

  -- Hover evaluation
  keymap('n', '<Leader>dh', dap_ui.eval, vim.tbl_extend('force', opts, { desc = 'DAP: Eval Hover' }))
  keymap('v', '<Leader>dh', dap_ui.eval, vim.tbl_extend('force', opts, { desc = 'DAP: Eval Selection' }))
end

setup_dap_keybindings()

-- Helper command to debug Rust tests
vim.api.nvim_create_user_command('RustDebugTest', function(opts)
  local test_filter = opts.args
  if test_filter == '' then
    vim.notify('Usage: RustDebugTest <test_name>', vim.log.levels.ERROR)
    return
  end

  -- Build the test and capture output
  local cmd = 'cargo test --no-run ' .. test_filter .. ' 2>&1'
  local handle = io.popen(cmd)
  if not handle then
    vim.notify('Could not run cargo test', vim.log.levels.ERROR)
    return
  end

  local output = handle:read('*a')
  handle:close()

  -- Check if build succeeded
  if output:find('error') then
    vim.notify('Build failed: ' .. test_filter, vim.log.levels.ERROR)
    return
  end

  -- Extract the executable path from the output
  -- Format: "Executable unittests src/main.rs (target/debug/deps/plugin_rack-HASH)"
  local test_binary = output:match('Executable [^\n]+ %(([^)]+)%)')

  if not test_binary or test_binary == '' then
    vim.notify('Could not find executable path in cargo output', vim.log.levels.ERROR)
    return
  end

  -- Make it absolute if it's relative
  if not test_binary:match('^/') then
    test_binary = vim.fn.getcwd() .. '/' .. test_binary
  end

  -- Find the test function in source code and get the line number
  local cwd = vim.fn.getcwd()
  local src_dir = cwd .. '/src'

  -- Search for the test function definition in all .rs files (use -r for recursive search)
  local search_cmd = 'grep -rn "fn ' .. test_filter .. '" ' .. src_dir .. ' --include="*.rs" 2>/dev/null'
  local grep_handle = io.popen(search_cmd)
  local grep_output = grep_handle:read('*a')
  grep_handle:close()

  local source_file = nil
  local line_number = nil

  -- Parse grep output: "src/file.rs:123:    fn test_name() {"
  if grep_output ~= '' then
    for match in grep_output:gmatch('[^\n]+') do
      local file, line = match:match('^([^:]+):(%d+):')
      if file and line then
        source_file = file
        line_number = tonumber(line)
        break
      end
    end
  end

  if not source_file or not line_number then
    vim.notify('Could not find test function ' .. test_filter .. ' in source code', vim.log.levels.ERROR)
    return
  end

  -- Move to the first line inside the function body
  line_number = line_number + 1

  -- vim.api.nvim_echo({{'Test ready: ' .. test_filter .. ' | Binary: ' .. test_binary .. ' | Breakpoint: ' .. source_file .. ':' .. line_number, 'Normal'}}, false, {})

  -- Convert absolute path to relative path for LLDB (remove leading project path)
  local cwd = vim.fn.getcwd()
  local relative_path = source_file
  if source_file:find('^' .. cwd, 1, true) then
    relative_path = source_file:sub(#cwd + 2)  -- Remove cwd and leading slash
  end

  -- Create breakpoint command for source line using relative path
  local bp_command = 'breakpoint set --file ' .. relative_path .. ' --line ' .. line_number

  -- Create a temporary config and launch
  local config = {
    name = 'Rust Test Debug',
    type = 'codelldb',
    request = 'launch',
    program = test_binary,
    args = { '--test-threads=1', '--nocapture', '--', test_filter },
    cwd = vim.fn.getcwd(),
    stopOnEntry = false,
    sourceLanguages = { 'rust' },
    runInTerminal = false,
    initCommands = { bp_command }
  }

  dap.run(config)
end, { nargs = '?' })


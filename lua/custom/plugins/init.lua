-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

vim.opt.spell = true
vim.opt.shell = 'pwsh'

-- then setup your lsp server as usual
local lspconfig = require 'lspconfig'

-- example to setup lua_ls and enable call snippets
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
}

local function command_finder()
  require('telescope.builtin').keymaps {
    prompt_title = 'Commands',
    mappings = {
      i = {
        ['<C-f>'] = function()
          local command = action_state.get_selected_entry().value
          vim.cmd(command)
        end,
      },
    },
  }
end

vim.keymap.set('n', '<leader>sc', command_finder, { desc = 'Find commands' })

return {

  { 'folke/neodev.nvim', opts = {} },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  --   'LazyVim/LazyVim',
  -- opts = {},
  -- -- spec = {
  -- --   { import = 'lazyvim.plugins' },
  -- --   { import = 'lazyvim.plugins.extras.util.project' },
  -- --   { import = 'plugins' },
  -- -- },
  {
    'Civitasv/cmake-tools.nvim',
    opts = {
      cmake_command = 'cmake', -- this is used to specify cmake command path
      ctest_command = 'ctest', -- this is used to specify ctest command path
      cmake_regenerate_on_save = false, -- auto generate when save CMakeLists.txt
      cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' }, -- this will be passed when invoke `CMakeGenerate`
      cmake_build_options = {}, -- this will be passed when invoke `CMakeBuild`
      -- support macro expansion:
      --       ${kit}
      --       ${kitGenerator}
      --       ${variant:xx}
      cmake_build_directory = 'out/${variant:buildType}', -- this is used to specify generate directory for cmake, allows macro expansion, relative to vim.loop.cwd()
      cmake_soft_link_compile_commands = true, -- this will automatically make a soft link from compile commands file to project root dir
      cmake_compile_commands_from_lsp = false, -- this will automatically set compile commands file location using lsp, to use it, please set `cmake_soft_link_compile_commands` to false
      cmake_kits_path = nil, -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
      cmake_variants_message = {
        short = { show = true }, -- whether to show short message
        long = { show = true, max_length = 40 }, -- whether to show long message
      },
      cmake_dap_configuration = { -- debug settings for cmake
        name = 'cpp',
        type = 'codelldb',
        request = 'launch',
        stopOnEntry = false,
        runInTerminal = true,
        console = 'integratedTerminal',
      },
      cmake_executor = { -- executor to use
        name = 'quickfix', -- name of the executor
        opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
        default_opts = { -- a list of default and possible values for executors
          quickfix = {
            show = 'always', -- "always", "only_on_error"
            position = 'belowright', -- "vertical", "horizontal", "leftabove", "aboveleft", "rightbelow", "belowright", "topleft", "botright", use `:h vertical` for example to see help on them
            size = 10,
            encoding = 'utf-8', -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
          },
          toggleterm = {
            direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = false, -- whether close the terminal when exit
            auto_scroll = true, -- whether auto scroll to the bottom
            singleton = true, -- single instance, autocloses the opened one, if present
          },
          overseer = {
            new_task_opts = {
              strategy = {
                'toggleterm',
                direction = 'horizontal',
                autos_croll = true,
                quit_on_exit = 'success',
              },
            }, -- options to pass into the `overseer.new_task` command
            on_new_task = function()
              require('overseer').open { enter = false, direction = 'right' }
            end, -- a function that gets overseer.Task when it is created, before calling `task:start`
          },
          terminal = {
            name = 'Main Terminal',
            prefix_name = '[CMakeTools]: ', -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
            split_direction = 'horizontal', -- "horizontal", "vertical"
            split_size = 11,

            -- Window handling
            single_terminal_per_instance = true, -- Single viewport, multiple windows
            single_terminal_per_tab = true, -- Single viewport per tab
            keep_terminal_static_location = true, -- Static location of the viewport if avialable

            -- Running Tasks
            start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
            focus = false, -- Focus on terminal when cmake task is launched.
            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
          }, -- terminal executor uses the values in cmake_terminal
        },
      },
      cmake_runner = { -- runner to use
        name = 'terminal', -- name of the runner
        opts = {}, -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
        default_opts = { -- a list of default and possible values for runners
          quickfix = {
            show = 'always', -- "always", "only_on_error"
            position = 'belowright', -- "bottom", "top"
            size = 10,
            encoding = 'utf-8',
            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
          },
          toggleterm = {
            direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = false, -- whether close the terminal when exit
            auto_scroll = true, -- whether auto scroll to the bottom
            singleton = true, -- single instance, autocloses the opened one, if present
          },
          overseer = {
            new_task_opts = {
              strategy = {
                'toggleterm',
                direction = 'horizontal',
                autos_croll = true,
                quit_on_exit = 'success',
              },
            }, -- options to pass into the `overseer.new_task` command
            on_new_task = function() end, -- a function that gets overseer.Task when it is created, before calling `task:start`
          },
          terminal = {
            name = 'Main Terminal',
            prefix_name = '[CMakeTools]: ', -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
            split_direction = 'horizontal', -- "horizontal", "vertical"
            split_size = 11,

            -- Window handling
            single_terminal_per_instance = true, -- Single viewport, multiple windows
            single_terminal_per_tab = true, -- Single viewport per tab
            keep_terminal_static_location = true, -- Static location of the viewport if avialable

            -- Running Tasks
            start_insert = false, -- If you want to enter terminal with :startinsert upon using :CMakeRun
            focus = false, -- Focus on terminal when cmake task is launched.
            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
          },
        },
      },
      cmake_notifications = {
        runner = { enabled = true },
        executor = { enabled = true },
        spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }, -- icons used for progress display
        refresh_rate_ms = 100, -- how often to iterate icons
      },
      cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner) ,
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    },
  },
  { 'b0o/schemastore.nvim' },
}

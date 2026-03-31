return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      styles = {
        float = {
          backdrop = false,
        },
      },
      picker = {
        enabled = true,
        ui_select = true,
        hidden = true,
        ignored = false,
        sources = {
          explorer = { hidden = true },
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
      notifier = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      scope = { enabled = true },
    },
    keys = {
      {
        '\\',
        function()
          require('snacks').explorer()
        end,
        desc = 'Explorer toggle',
      },
      {
        '<leader>nn',
        function()
          require('snacks').notifier.show_history()
        end,
        desc = 'Notification History',
      },
      {
        '<leader>nd',
        function()
          require('snacks').notifier.hide()
        end,
        desc = 'Dismiss Notifications',
      },
    },
  },
  -- UI Theme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      term_colors = true,
      transparent_background = true,
      dim_inactive = {
        enabled = false,
        shade = 'dark',
        percentage = 0.15,
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        mason = true,
        which_key = true,
        notify = true,
        noice = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme 'catppuccin-macchiato'
      vim.api.nvim_set_hl(0, 'MsgArea', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'FloatTitle', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'FloatFooter', { bg = 'none' })

      for _, group in ipairs {
        'SnacksPicker',
        'SnacksPickerNormal',
        'SnacksPickerBorder',
        'SnacksPickerTitle',
        'SnacksPickerFooter',
        'SnacksPickerInput',
        'SnacksPickerInputNormal',
        'SnacksPickerInputBorder',
        'SnacksPickerList',
        'SnacksPickerListNormal',
        'SnacksPickerListBorder',
        'SnacksPickerPreview',
        'SnacksPickerPreviewNormal',
        'SnacksPickerPreviewBorder',
      } do
        vim.api.nvim_set_hl(0, group, { bg = 'none' })
      end
    end,
  },

  -- Prettier status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      options = {
        theme = 'catppuccin-macchiato',
        component_separators = '|',
      },
    },
  },

  -- Show pending keybinds
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading evnt to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>g', group = '[G]it' },
        { '<leader>l', group = '[L]azyGit' },
      }

      -- visual mode
      require('which-key').add {
        { '<leader>g', group = '[G]it' },
        { mode = 'v' },
      }
    end,
  },

  -- Add fancy command popup + pretty notifcations (specifically adds configuration options for command prompt + notifications)
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('noice').setup {
        notify = {
          enabled = false,
        },
        lsp = {
          progress = {
            enabled = true,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat|string
            format = 'lsp_progress',
            --- @type NoiceFormat|string
            format_done = 'lsp_progress_done',
            throttle = 1000 / 30, -- frequency to update lsp progress message
            view = 'mini',
          },
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
  },
}

return {
  {
    'folke/snacks.nvim',
    opts = {
      picker = {
        enabled = true,
      },
    },
    keys = {
      { '<leader>sh', function() require('snacks').picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('snacks').picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>ss', function() require('snacks').picker() end, desc = '[S]earch [S]elect Picker' },
      { '<leader>sw', function() require('snacks').picker.grep_word() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('snacks').picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('snacks').picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('snacks').picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() require('snacks').picker.recent() end, desc = '[S]earch Recent Files ("." for repeat)' },
      { '<leader><leader>', function() require('snacks').picker.buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('snacks').picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>st', function() require('snacks').picker.lsp_symbols() end, desc = '[S]earch [T]reesitter' },
      { '<leader>s/', function() require('snacks').picker.grep_buffers() end, desc = '[S]earch [/] in Open Files' },
      {
        '<leader>sn',
        function()
          local uv = vim.uv or vim.loop
          local config_dir = uv.fs_realpath(vim.fn.stdpath 'config') or vim.fn.stdpath 'config'
          require('snacks').picker.files { cwd = config_dir, follow = true }
        end,
        desc = '[S]earch [N]eovim files',
      },
      {
        '<leader>sf',
        function()
          require('snacks').picker.files { hidden = true, ignored = true }
        end,
        desc = '[S]earch [F]iles',
      },
    },
  },

  {
    'MagicDuck/grug-far.nvim',
    -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
    -- additional lazy config to defer loading is not really needed...
    config = function()
      -- optional setup call to override plugin options
      -- alternatively you can set options with vim.g.grug_far = { ... }
      require('grug-far').setup {
        -- options, see Configuration section below
        -- there are no required options atm
      }
      vim.keymap.set({ 'n', 'x' }, '<leader>si', function()
        require('grug-far').open { visualSelectionUsage = 'operate-within-range' }
      end, { desc = 'grug-far: Search within range' })
    end,
  },
}

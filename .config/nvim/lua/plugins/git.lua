-- nvim v0.8.0
return {
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'Open [L]azy[G]it' },
    },
  },
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>gsh', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[g]it [s]tage [h]unk' })
        map('v', '<leader>grh', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[g]it [r]eset [h]unk' })
        -- normal mode
        map('n', '<leader>gsh', gitsigns.stage_hunk, { desc = '[g]it [s]tage [h]unk' })
        map('n', '<leader>grh', gitsigns.reset_hunk, { desc = '[g]it [r]eset [h]unk' })
        map('n', '<leader>gsb', gitsigns.stage_buffer, { desc = '[g]it [s]tage [b]uffer' })
        map('n', '<leader>guh', gitsigns.undo_stage_hunk, { desc = '[g]it [u]ndo stage [h]unk' })
        map('n', '<leader>grb', gitsigns.reset_buffer, { desc = '[g]it [r]eset [b]uffer' })
        map('n', '<leader>gph', gitsigns.preview_hunk, { desc = '[g]it [p]review [h]unk' })
        map('n', '<leader>gdi', gitsigns.diffthis, { desc = '[g]it [d]iff against [i]ndex' })
        map('n', '<leader>gdc', function()
          gitsigns.diffthis '@'
        end, { desc = '[g]it [d]iff against last [c]ommit' })
        -- Toggles
        map('n', '<leader>tgd', gitsigns.toggle_deleted, { desc = '[t]oggle [g]it show [d]eleted' })
      end,
    },
  },
  {
    'FabijanZulj/blame.nvim',
    opts = {
      blame_options = { '-w' },
      -- manually set some Catpuccin Mocha hexcodes
      -- Picker seems to choose colors from order they are listed here.
      -- Ideally should try to order theme colors in contrasting order
      colors = {
        '#f5e0dc',
        '#f38ba8',
        '#a6e3a1',
        '#94e2d5',
        '#cba6f7',
        '#fab387',
        '#f9e2af',
        '#f5c2e7',
        '#f2cdcd',
        '#eba0ac',
        '#fab387',
      },
    },
    keys = {
      { '<leader>gb', '<cmd>BlameToggle<cr>', desc = '[G]it [B]lame' },
    },
  },
}

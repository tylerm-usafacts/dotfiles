return {
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require('copilot').setup {}
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'j-hui/fidget.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup {
        strategies = {
          chat = {
            adapter = 'copilot',
            model = 'claude-3-7-sonnet',
          },
          inline = {
            adapter = 'copilot',
            model = 'gpt-4.1',
          },
        },
      }
      vim.keymap.set({ 'n', 'v' }, '<C-a>', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
      vim.keymap.set({ 'n', 'v' }, '<LocalLeader>a', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
      vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })
    end,
  },
}

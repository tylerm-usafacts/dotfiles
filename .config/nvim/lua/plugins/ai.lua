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
      vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { desc = '[A]gent [A]ctions', noremap = true, silent = true })
      vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', { desc = '[A]gent [T]oggle', noremap = true, silent = true })
      vim.keymap.set('v', '<leader>ac', '<cmd>CodeCompanionChat Add<cr>', { desc = '[A]gent [C]ontext', noremap = true, silent = true })
    end,
  },
}

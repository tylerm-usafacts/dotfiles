return {
  -- autoset tabstop & shiftwidth
  {
    'tpope/vim-sleuth',
  },
  -- autoformat
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        python = { 'black' },
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },
  -- specify tabset
  {
    'FotiadisM/tabset.nvim',
    opts = {
      defaults = {
        tabwidth = 4,
        expandtab = true,
      },
      languages = {
        lua = {
          tabwidth = 2,
          expandtab = true,
        },
        python = {
          tabwidth = 4,
          expandtab = true,
        },
      },
    },
  },
  -- todo comments
  {
    'folke/todo-comments.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {},
  },
}

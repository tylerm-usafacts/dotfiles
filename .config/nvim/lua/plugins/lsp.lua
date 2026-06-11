local treesitter_parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'hcl',
  'lua',
  'luadoc',
  'markdown',
  'latex',
  'yaml',
  'json',
  'vim',
  'vimdoc',
  'python',
  'regex',
  'terraform',
  'toml',
}

return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      { 'williamboman/mason-lspconfig.nvim' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`

      -- {
      --  'j-hui/fidget.nvim',
      --  opts = {
      --  notification = {
      --    window = {
      --      winblend = 0,
      --    },
      --   },
      --  },
      -- },

      -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
      -- NOTE: `opts = {}` is the same as calling `require('lazydev').setup({})`
      -- used for completion, annotations and signatures of Neovim apis

      { 'folke/lazydev.nvim', opts = {} },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', function()
            require('snacks').picker.lsp_definitions()
          end, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', function()
            require('snacks').picker.lsp_references()
          end, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function()
            require('snacks').picker.lsp_implementations()
          end, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', function()
            require('snacks').picker.lsp_type_definitions()
          end, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', function()
            require('snacks').picker.lsp_symbols()
          end, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', function()
            require('snacks').picker.lsp_workspace_symbols()
          end, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
              format = {
                enable = false,
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'pyright',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Treesitter
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        config = function()
          require('nvim-treesitter-textobjects').setup {
            select = {
              lookahead = true,
            },
            move = {
              set_jumps = true,
            },
          }

          local select = require 'nvim-treesitter-textobjects.select'
          local move = require 'nvim-treesitter-textobjects.move'
          local swap = require 'nvim-treesitter-textobjects.swap'

          local select_map = function(keys, query, desc)
            vim.keymap.set({ 'x', 'o' }, keys, function()
              select.select_textobject(query, 'textobjects')
            end, { desc = desc })
          end

          select_map('aa', '@parameter.outer', 'Select outer parameter')
          select_map('ia', '@parameter.inner', 'Select inner parameter')
          select_map('ab', '@block.outer', 'Select outer block')
          select_map('ib', '@block.inner', 'Select inner block')
          select_map('af', '@function.outer', 'Select outer function')
          select_map('if', '@function.inner', 'Select inner function')
          select_map('ac', '@class.outer', 'Select outer class')
          select_map('ic', '@class.inner', 'Select inner class')
          select_map('ii', '@conditional.inner', 'Select inner conditional')
          select_map('ai', '@conditional.outer', 'Select outer conditional')
          select_map('il', '@loop.inner', 'Select inner loop')
          select_map('al', '@loop.outer', 'Select outer loop')
          select_map('at', '@comment.outer', 'Select outer comment')
          select_map('it', '@comment.inner', 'Select inner comment')

          vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
            move.goto_next_start('@function.outer', 'textobjects')
          end, { desc = 'Next function start' })
          vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
            move.goto_next_start('@class.outer', 'textobjects')
          end, { desc = 'Next class start' })
          vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
            move.goto_next_end('@function.outer', 'textobjects')
          end, { desc = 'Next function end' })
          vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
            move.goto_next_end('@class.outer', 'textobjects')
          end, { desc = 'Next class end' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
            move.goto_previous_start('@function.outer', 'textobjects')
          end, { desc = 'Previous function start' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
            move.goto_previous_start('@class.outer', 'textobjects')
          end, { desc = 'Previous class start' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
            move.goto_previous_end('@function.outer', 'textobjects')
          end, { desc = 'Previous function end' })
          vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
            move.goto_previous_end('@class.outer', 'textobjects')
          end, { desc = 'Previous class end' })

          vim.keymap.set('n', '<leader>a', function()
            swap.swap_next('@parameter.inner', 'textobjects')
          end, { desc = 'Swap with next parameter' })
          vim.keymap.set('n', '<leader>A', function()
            swap.swap_previous('@parameter.inner', 'textobjects')
          end, { desc = 'Swap with previous parameter' })
        end,
      },
    },
    build = function()
      local ts = require 'nvim-treesitter'
      ts.setup { install_dir = vim.fn.stdpath 'data' .. '/site' }
      ts.install(treesitter_parsers, { max_jobs = 1, summary = true }):wait(300000)
      ts.update(treesitter_parsers, { max_jobs = 1, summary = true }):wait(300000)
    end,
    opts = {
      install_dir = vim.fn.stdpath 'data' .. '/site',
      ensure_installed = treesitter_parsers,
    },
    config = function(_, opts)
      local ts = require 'nvim-treesitter'
      ts.setup { install_dir = opts.install_dir }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}

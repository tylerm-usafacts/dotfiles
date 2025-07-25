-- Install lazylazy
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup {

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- ui.lua -------------------------------------
  -- navigation tree + theme + keybinding info --
  -- + tabset detection -------------------------
  -----------------------------------------------
  require 'plugins.ui',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- search.lua ---------------------------------
  -- fuzzy search -------------------------------
  -----------------------------------------------
  require 'plugins.search',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- git.lua ------------------------------------
  -- git + git ui -------------------------------
  -----------------------------------------------
  require 'plugins.git',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- format.lua ---------------------------------
  -- autoformat ---------------------------------
  -----------------------------------------------
  require 'plugins.format',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- lsp.lua ------------------------------------
  -- mason + lsp --------------------------------
  -----------------------------------------------
  require 'plugins.lsp',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- cmp.lua ------------------------------------
  -- autocompletions + autopairs ----------------
  -----------------------------------------------
  require 'plugins.cmp',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- markdown.lua -------------------------------
  -- markdown preview + obsidian ----------------
  -----------------------------------------------
  require 'plugins.markdown',

  -----------------------------------------------
  -- SECTION ------------------------------------
  -- ai.lua -------------------------------------
  -- codecompanion ------------------------------
  -----------------------------------------------

  require 'plugins.ai',
}

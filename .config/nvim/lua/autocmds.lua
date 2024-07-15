-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Clean on save ]]
-- remove trailing whitespace from all lines before saving a file)
local clean_on_save = vim.api.nvim_create_augroup('clean_on_save', {})
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = clean_on_save,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- [[ Format on save]]
-- after file is saved, format file then reload the file
local black = vim.api.nvim_create_augroup('black', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = black,
  pattern = '*.py',
  callback = function()
    vim.cmd 'silent !black --quiet %'
    vim.cmd 'edit'
  end,
})

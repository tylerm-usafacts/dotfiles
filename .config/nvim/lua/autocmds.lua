------------------------------------------------
--
-- Highlight on yank
--
------------------------------------------------

-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank()
  end,
})

------------------------------------------------
--
-- Clean on save
--
------------------------------------------------

-- remove trailing whitespace from all lines before saving a file)
local clean_on_save = vim.api.nvim_create_augroup('clean_on_save', {})
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = clean_on_save,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

------------------------------------------------
--
-- Format on save
--
------------------------------------------------

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

local quickfix = vim.api.nvim_create_augroup('quickfix', { clear = true })

------------------------------------------------
--
-- Quickfix
--
------------------------------------------------

-- Remove items from quickfix list.
-- `dd` to delete in Normal
-- `d` to delete Visual selection
local function delete_qf_items()
  local mode = vim.api.nvim_get_mode()['mode']

  local start_idx
  local count

  if mode == 'n' then
    -- Normal mode
    start_idx = vim.fn.line '.'
    count = vim.v.count > 0 and vim.v.count or 1
  else
    -- Visual mode
    local v_start_idx = vim.fn.line 'v'
    local v_end_idx = vim.fn.line '.'

    start_idx = math.min(v_start_idx, v_end_idx)
    count = math.abs(v_end_idx - v_start_idx) + 1

    -- Go back to normal
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        '<esc>', -- what to escape
        true, -- Vim leftovers
        false, -- Also replace `<lt>`?
        true -- Replace keycodes (like `<esc>`)?
      ),
      'x', -- Mode flag
      false -- Should be false, since we already `nvim_replace_termcodes()`
    )
  end

  local qflist = vim.fn.getqflist()

  for _ = 1, count, 1 do
    table.remove(qflist, start_idx)
  end

  vim.fn.setqflist(qflist, 'r')
  vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd('FileType', {
  group = quickfix,
  pattern = 'qf',
  callback = function()
    -- Do not show quickfix in buffer lists.
    vim.api.nvim_buf_set_option(0, 'buflisted', false)

    -- Escape closes quickfix window.
    vim.keymap.set('n', '<ESC>', '<CMD>cclose<CR>', { buffer = true, remap = false, silent = true })

    -- `dd` deletes an item from the list.
    vim.keymap.set('n', 'dd', delete_qf_items, { buffer = true })
    vim.keymap.set('x', 'd', delete_qf_items, { buffer = true })
  end,
  desc = 'Quickfix tweaks',
})

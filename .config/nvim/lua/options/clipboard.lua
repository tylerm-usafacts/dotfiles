local M = {}

local function is_remote_clipboard_context()
  if vim.env.NVIM_REMOTE_CLIPBOARD == '1' then
    return true
  end

  if vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT then
    return true
  end

  if vim.env.DEVCONTAINER or vim.env.CODESPACES or vim.env.container then
    return true
  end

  return vim.fn.filereadable '/.dockerenv' == 1
end

function M.setup()
  if not is_remote_clipboard_context() then
    return
  end

  local ok, osc52 = pcall(require, 'vim.ui.clipboard.osc52')
  if not ok then
    return
  end

  local max_copy_bytes = tonumber(vim.env.NVIM_OSC52_MAX_BYTES) or 100000

  local function copy_with_limit(register)
    local copy = osc52.copy(register)
    return function(lines, regtype)
      local text = table.concat(lines, '\n')
      if #text > max_copy_bytes then
        vim.notify('Skipping OSC52 copy: selection too large', vim.log.levels.WARN)
        return
      end

      copy(lines, regtype)
    end
  end

  local function paste_from_register()
    return { vim.split(vim.fn.getreg '"', '\n'), vim.fn.getregtype '"' }
  end

  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = copy_with_limit '+',
      ['*'] = copy_with_limit '*',
    },
    paste = {
      ['+'] = paste_from_register,
      ['*'] = paste_from_register,
    },
  }
end

return M

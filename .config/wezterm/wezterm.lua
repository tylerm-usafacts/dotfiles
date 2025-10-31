local wezterm = require 'wezterm'
local config = require 'config'
local utils = require 'utils'

wezterm.on('format-tab-title', function(tab)
  local has_unseen_output = false
  if not tab.is_active then
    for _, pane in ipairs(tab.panes) do
      if pane.has_unseen_output then
        has_unseen_output = true
        break
      end
    end
  end

  local cwd = wezterm.format {
    { Text = utils.get_current_working_dir(tab) },
  }

  local process = utils.get_process(tab)
  local title = process and string.format(' %s (%s) ', process, cwd) or ' [?] '

  if has_unseen_output then
    return {
      { Background = { Color = '#f38ba8' } },
      { Foreground = { Color = '#11111b' } },
      { Text = title },
    }
  end

  return {
    { Text = title },
  }
end)

return config

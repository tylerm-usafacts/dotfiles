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

  local process_name = utils.get_process_name(tab)
  local process_icon = utils.get_process_icon(process_name)
  local title = ' [?] '

  if process_name then
    if process_icon then
      title = string.format(' %s %s ', process_icon, process_name)
    else
      title = string.format(' [%s] ', process_name)
    end
  end

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

wezterm.on('update-right-status', function(window, _)
  window:set_right_status(window:active_workspace())
end)

return config

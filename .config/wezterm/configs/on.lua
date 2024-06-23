local wezterm = require 'wezterm'

wezterm.on('window-config-reloaded', function(window, _)
  window:toast_notification('Wezterm', 'Configuration reloaded!', nil, 2000)
end)

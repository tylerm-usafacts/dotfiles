local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
  config.color_scheme = 'Catppuccin Macchiato'
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 30
  -- mouse bindings
  config.keys = {
    {
      key = 'f',
      mods = 'CTRL',
      action = wezterm.action.ToggleFullScreen,
    },
  }
  config.mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  }
end

return module

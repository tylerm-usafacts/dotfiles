local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
  config.keys = {
    -- This will create a new split and run my default program inside it
    {
      key = 'd',
      mods = 'CMD',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 30 },
      },
    },
    {
      key = 'r',
      mods = 'CMD',
      action = wezterm.action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
    {
      key = 'w',
      mods = 'CMD',
      action = wezterm.action.CloseCurrentTab { confirm = true },
    },
    {
      key = 'e',
      mods = 'CMD',
      action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
      key = 'h',
      mods = 'CMD',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'CMD',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'CMD',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'CMD',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },
  }
end

return module

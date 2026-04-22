local wezterm = require 'wezterm'
local act = wezterm.action
local workspace_switcher = wezterm.plugin.require 'https://github.com/MLFlexer/smart_workspace_switcher.wezterm'

local M = {}

M.keys = {
  -- This will create a new split and run my default program inside it
  {
    key = 'd',
    mods = 'SUPER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 30 },
    },
  },
  {
    key = 'r',
    mods = 'SUPER',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 30 },
    },
  },
  {
    key = 'w',
    mods = 'SUPER',
    action = act.CloseCurrentTab { confirm = true },
  },
  {
    key = 'q',
    mods = 'SUPER',
    action = act.QuitApplication,
  },
  {
    key = 'e',
    mods = 'SUPER',
    action = act.CloseCurrentPane { confirm = false },
  },
  {
    key = 'h',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'SUPER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 's',
    mods = 'SUPER',
    action = workspace_switcher.switch_workspace(),
  },
  {
    key = 's',
    mods = 'SUPER|SHIFT',
    action = workspace_switcher.switch_to_prev_workspace(),
  },
  {
    key = 'n',
    mods = 'SUPER',
    action = wezterm.action_callback(function(window, pane)
      local cwd_uri = pane:get_current_working_dir()
      if not cwd_uri or not cwd_uri.file_path or cwd_uri.file_path == '' then
        return
      end

      local cwd = cwd_uri.file_path
      local workspace_name = cwd:gsub('[/\\]+$', ''):gsub('(.*[/\\])(.*)', '%2')
      if workspace_name == '' then
        workspace_name = cwd
      end

      window:perform_action(
        act.SwitchToWorkspace {
          name = workspace_name,
          spawn = {
            cwd = cwd,
          },
        },
        pane
      )
    end),
  },
}

M.mouse = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

return M

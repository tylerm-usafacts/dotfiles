local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local M = {}

local function derive_workspace_name(cwd)
  local workspace_name = cwd:gsub('[/\\]+$', ''):gsub('(.*[/\\])(.*)', '%2')
  if workspace_name == '' then
    return cwd
  end
  return workspace_name
end

local function workspace_exists(name)
  for _, workspace in ipairs(mux.get_workspace_names()) do
    if workspace == name then
      return true
    end
  end
  return false
end

local function apply_dev_layout(mux_window, cwd)
  local first_tab = mux_window:active_tab()
  if not first_tab then
    return
  end

  local top_pane = first_tab:active_pane()
  if not top_pane then
    return
  end

  top_pane:send_text 'nvim\n'
  top_pane:split {
    direction = 'Right',
    size = 0.30,
    cwd = cwd,
  }

  local _, left_pane = mux_window:spawn_tab {
    cwd = cwd,
  }
  if not left_pane then
    return
  end

  left_pane:send_text 'opencode\n'

  local right_pane = left_pane:split {
    direction = 'Right',
    size = 0.5,
    cwd = cwd,
  }

  if right_pane then
    right_pane:send_text 'lazygit\n'
  end
end

local function find_workspace_window(workspace_name)
  for _, workspace_window in ipairs(mux.all_windows()) do
    if workspace_window:get_workspace() == workspace_name then
      return workspace_window
    end
  end
  return nil
end

local function wait_for_workspace_window(workspace_name, attempts_remaining, on_ready)
  local workspace_window = find_workspace_window(workspace_name)
  if workspace_window then
    on_ready(workspace_window)
    return
  end

  if attempts_remaining <= 0 then
    wezterm.log_warn('workspace window did not appear before timeout: ' .. workspace_name)
    return
  end

  wezterm.time.call_after(0.05, function()
    wait_for_workspace_window(workspace_name, attempts_remaining - 1, on_ready)
  end)
end

function M.switch_or_create_dev_layout(window, pane)
  local cwd_uri = pane:get_current_working_dir()
  if not cwd_uri or not cwd_uri.file_path or cwd_uri.file_path == '' then
    return
  end

  local cwd = cwd_uri.file_path
  local workspace_name = derive_workspace_name(cwd)

  if workspace_exists(workspace_name) then
    window:perform_action(act.SwitchToWorkspace { name = workspace_name }, pane)
    return
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

  wait_for_workspace_window(workspace_name, 40, function(workspace_window)
    apply_dev_layout(workspace_window, cwd)
  end)
end

return M

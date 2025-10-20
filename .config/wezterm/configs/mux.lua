local wezterm = require 'wezterm'

local module = {}

module.devpods = {}
module.ssh_domains = {}

function module.get_container_ids()
  local container_ids = {}
  local cmd = "docker container ls --format '{{.ID}}'"
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      table.insert(container_ids, line)
    end
    handle:close()
  end
  return container_ids
end

function module.map_ports(ports)
  local port_map = {}
  if ports and ports ~= '' then
    for container_port, host_port in ports:gmatch '(%S+)->(%S+)' do
      port_map[container_port] = host_port
    end
  end
  return port_map
end

function module.extract_workspace_name(image)
  local workspace = image:match '^([^:]+)'
  if workspace then
    workspace = workspace:match '^(.*)%-.+$' or workspace
  end
  return workspace
end

function module.get_devpod_info()
  local ids = module.get_container_ids()
  local devpods = {}

  for _, id in ipairs(ids) do
    local cmd = string.format(
      "docker inspect -f '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} {{.Config.Image}} {{.State.Status}} {{.Config.User}} {{range $p, $conf := .NetworkSettings.Ports}}{{$p}}->{{if $conf}}{{(index $conf 0).HostPort}}{{end}} {{end}}' %s",
      id
    )
    local handle = io.popen(cmd)
    if handle then
      local line = handle:read '*l'
      handle:close()
      if line then
        local name, ip, image, state, user, ports = line:match '^/(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S*)%s*(.*)$'
        if name and image and ports then
          local workspace = module.extract_workspace_name(image)
          local port_map = module.map_ports(ports)
          devpods[name] = {
            ip = ip,
            image = image,
            workspace = workspace,
            state = state,
            user = user ~= '' and user or nil,
            ports = port_map,
          }
        end
      end
    end
  end
  return devpods
end

function module.create_ssh_domains()
  if next(module.ssh_domains) ~= nil then
    return module.ssh_domains
  end

  if next(module.devpods) == nil then
    module.devpods = module.get_devpod_info()
  end

  for name, data in pairs(module.devpods) do
    table.insert(module.ssh_domains, {
      name = data.workspace or name,
      remote_address = string.format('127.0.0.1:%s', data.ports['8888/tcp']),
      username = data.user or 'vscode',
      connect_automatically = false,
      multiplexing = 'WezTerm',
      remote_wezterm_path = '/usr/bin/wezterm',
      ssh_option = {
        identityfile = '~/.ssh/id_devcontainer',
        forwardagent = 'yes',
      },
    })
  end
  return module.ssh_domains
end

function module.apply_to_config(config)
  config.ssh_domains = module.create_ssh_domains()
  config.keys = {
    -- This will create a new split and run my default program inside it
    {
      key = 'd',
      mods = 'SUPER',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 30 },
      },
    },
    {
      key = 'r',
      mods = 'SUPER',
      action = wezterm.action.SplitPane {
        direction = 'Right',
        size = { Percent = 50 },
      },
    },
    {
      key = 'w',
      mods = 'SUPER',
      action = wezterm.action.CloseCurrentTab { confirm = true },
    },
    {
      key = 'e',
      mods = 'SUPER',
      action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
      key = 'h',
      mods = 'SUPER',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'SUPER',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'SUPER',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'SUPER',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },
  }
end

return module

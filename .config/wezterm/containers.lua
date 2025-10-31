local wezterm = require 'wezterm'

local M = {}

M.devpods = {}
M.ssh_domains = {}

M.get_container_ids = function()
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

M.map_ports = function(ports)
  local port_map = {}
  if ports and ports ~= '' then
    for container_port, host_port in ports:gmatch '(%S+)->(%S+)' do
      port_map[container_port] = host_port
    end
  end
  return port_map
end

M.extract_workspace_name = function(image)
  local workspace = image:match '^([^:]+)'
  if workspace then
    workspace = workspace:match '^(.*)%-.+$' or workspace
  end
  return workspace
end

M.get_devpod_info = function()
  local ids = M.get_container_ids()
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
          local workspace = M.extract_workspace_name(image)
          local port_map = M.map_ports(ports)
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

M.create_ssh_domains = function()
  if next(M.ssh_domains) ~= nil then
    return M.ssh_domains
  end

  if next(M.devpods) == nil then
    M.devpods = M.get_devpod_info()
  end

  for name, data in pairs(M.devpods) do
    table.insert(M.ssh_domains, {
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
  return M.ssh_domains
end

M.create_container_choices = function()
  local container_choices = {}

  if next(M.devpods) == nil then
    M.devpods = M.get_devpod_info()
  end

  table.insert(container_choices, {
    label = 'local',
  })

  for _, pod in pairs(M.devpods) do
    local domain = wezterm.mux.get_domain(pod.workspace)
    local label = 'devpod: ' .. pod.workspace
    if domain:state() == 'Attached' then
      label = label .. ' *'
    end

    table.insert(container_choices, {
      label = label,
    })
  end
  table.insert(container_choices, {
    label = '󰌙 detach domains',
  })

  table.insert(container_choices, {
    label = '󰑓 reload domains',
  })

  return container_choices
end

return M

local wezterm = require 'wezterm'

local M = {}

M.detect_host_os = function()
  -- package.config:sub(1,1) returns '\' for windows and '/' for *nix.
  if package.config:sub(1, 1) == '\\' then
    return 'windows'
  else
    -- uname should be available on *nix systems.
    local check = io.popen 'uname -s'
    local result = check:read '*l'
    check:close()

    if result == 'Darwin' then
      return 'macos'
    else
      return 'linux'
    end
  end
end

M.set_mac_path = function()
  local set_environment_variables = {}
  set_environment_variables = {
    PATH = '/usr/local/bin/:' .. os.getenv 'PATH',
  }
  return set_environment_variables
end

M.get_current_working_dir = function(tab)
  local current_dir = tab.active_pane and tab.active_pane.current_working_dir or { file_path = '' }
  local HOME_DIR = os.getenv 'HOME'

  return current_dir.file_path == HOME_DIR and '~' or string.gsub(current_dir.file_path, '(.*[/\\])(.*)', '%2')
end

M.get_process = function(tab)
  local process_icons = {
    ['docker'] = wezterm.nerdfonts.linux_docker,
    ['docker-compose'] = wezterm.nerdfonts.linux_docker,
    ['psql'] = wezterm.nerdfonts.dev_postgresql,
    ['ssh'] = wezterm.nerdfonts.fa_exchange,
    ['ssh-add'] = wezterm.nerdfonts.fa_exchange,
    ['kubectl'] = wezterm.nerdfonts.linux_docker,
    ['nvim'] = wezterm.nerdfonts.linux_neovim,
    ['make'] = wezterm.nerdfonts.seti_makefile,
    ['vim'] = wezterm.nerdfonts.dev_vim,
    ['node'] = wezterm.nerdfonts.dev_nodejs_small,
    ['go'] = wezterm.nerdfonts.seti_go,
    ['python3'] = wezterm.nerdfonts.dev_python,
    ['zsh'] = wezterm.nerdfonts.dev_terminal,
    ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
    ['sudo'] = wezterm.nerdfonts.fa_hashtag,
    ['lazydocker'] = wezterm.nerdfonts.linux_docker,
    ['git'] = wezterm.nerdfonts.dev_git,
    ['lazygit'] = wezterm.nerdfonts.dev_git,
    ['lua'] = wezterm.nerdfonts.seti_lua,
    ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
    ['curl'] = wezterm.nerdfonts.md_curling,
    ['gh'] = wezterm.nerdfonts.dev_github_badge,
  }

  if not tab.active_pane or tab.active_pane.foreground_process_name == '' then
    return nil
  end

  local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  if string.find(process_name, 'kubectl') then
    process_name = 'kubectl'
  end

  return process_icons[process_name] or string.format('[%s]', process_name)
end

return M

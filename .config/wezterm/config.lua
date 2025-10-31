local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local keybinds = require 'keybinds'
local utils = require 'utils'

config.keys = keybinds.keys
config.mouse_bindings = keybinds.mouse
config.color_scheme = 'Catppuccin Macchiato'
config.window_background_opacity = 0.8
config.macos_window_background_blur = 30
config.use_fancy_tab_bar = false
config.tab_max_width = 100
if utils.detect_host_os == 'macos' then
  config.set_environment_variables = utils.set_mac_path
end

return config

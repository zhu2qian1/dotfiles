local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font('UDEV Gothic NFLG')
--config.color_scheme = 'DimmedMonokai'
config.color_scheme = 'AdventureTime'
config.font_size = 11
config.default_prog = { 'pwsh.exe' }

return config

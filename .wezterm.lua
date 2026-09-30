local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.font = wezterm.font('UDEV Gothic NFLG')
--config.color_scheme = 'DimmedMonokai'
--config.color_scheme = 'AdventureTime'
config.font_size = 12
config.default_prog = { 'pwsh.exe' }

-- psmux 3.3.8 は起動時にホスト端末へ色を問い合わせる (OSC 10/11/4 + DA1) が、
-- WezTerm は DA1 に先に答えるため、遅れて届いた色の返事の切れ端 (`555<ESC>\`) を
-- psmux がキー入力として読んでペインに打ち込むことがある (psmux/psmux#646)。
-- PSMUX_HOST_COLORS があると psmux は問い合わせ自体を送らないので、それで避ける。
-- 値はペイン内のアプリが色を問い合わせたときの返事にも使われるため、WezTerm の
-- 既定の前景/背景色を書いておく。color_scheme を変えたらここも合わせること。
-- 修正 (31e9ea0) を含む psmux がリリースされたら、この設定は消してよい。
config.set_environment_variables = {
	PSMUX_HOST_COLORS = 'fg=b2b2b2,bg=000000,dark=1',
}

return config

-- yazi.nvim から起動されたとき (YAZI_NVIM_ID が渡される) だけアイコンを出さない。
-- Neovim の config/options.lua は setcellwidths で Nerd Font アイコンを幅 2 に
-- しているため、:terminal 上ではアイコンが 2 セルを占める。yazi 側 (ratatui) は
-- 1 セルとして描くので行が 1 セルずつ右へずれ、差分描画のたびに枠線が消えたり
-- 文字が描き残されたりする。lazygit (ide/plugins/git.lua) と同じ理由・同じ対処。
if os.getenv("YAZI_NVIM_ID") then
	function Entity:icon() return "" end
end

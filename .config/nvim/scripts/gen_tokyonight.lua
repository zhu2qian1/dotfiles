-- ============================================
-- tokyonight.nvim から依存の無い静的カラースキーム colors/tokyonight-<style>.lua を生成する。
--
-- tokyonight.nvim の colors/*.lua は require('tokyonight').load() を呼ぶだけで、
-- 本体の Lua モジュールが runtimepath に無いと動かない。lite プロファイルは
-- プラグインを読まないので、ハイライト定義を展開済みの単体ファイルとして持つ。
-- 同梱の extras/vim/colors/*.vim も静的だが、treesitter (@*) と Neovim プラグイン向けの
-- グループが削られており、treesitter ハイライトが既定で有効な lua / markdown などで
-- 色が素の Neovim のリンク先に落ちるため使わない。
--
-- 使い方 (プラグインを更新したら再生成してコミットする):
--   git clone --depth 1 https://github.com/folke/tokyonight.nvim /tmp/tokyonight.nvim
--   nvim --clean -l .config/nvim/scripts/gen_tokyonight.lua /tmp/tokyonight.nvim [style]
-- style は storm / moon / night / day (既定 night)。
-- ============================================

local root = arg[1]
if not root or vim.fn.isdirectory(root .. '/lua/tokyonight') == 0 then
    io.stderr:write('usage: nvim --clean -l gen_tokyonight.lua <tokyonight.nvim dir> [style]\n')
    os.exit(1)
end
root = vim.fn.fnamemodify(root, ':p'):gsub('/$', '')
local style = arg[2] or 'night'

vim.opt.rtp:prepend(root)
local config = require('tokyonight.config')
local opts = config.extend({
    style = style,
    -- ~/.cache に書かせない。
    cache = false,
    -- lazy.nvim の有無で出力が変わらないよう、対応プラグインのグループは全部含める。
    -- 使っていないプラグインのグループは定義されるだけで害は無い。
    plugins = { all = true, auto = false },
})
local colors = require('tokyonight.colors').setup(opts)
local groups = require('tokyonight.groups').setup(colors, opts)

local rev = vim.trim(vim.fn.system({ 'git', '-C', root, 'rev-parse', '--short', 'HEAD' }))
if vim.v.shell_error ~= 0 then
    rev = 'unknown'
end

local name = 'tokyonight-' .. style
local out = {
    ('-- %s : folke/tokyonight.nvim v%s (%s) から生成した静的カラースキーム'):format(name, config.version, rev),
    '-- https://github.com/folke/tokyonight.nvim (Apache License 2.0)',
    '-- 手で編集しないこと。再生成手順は scripts/gen_tokyonight.lua を参照。',
    '',
    'if vim.g.colors_name then',
    "    vim.cmd('hi clear')",
    'end',
    ("vim.o.background = '%s'"):format(style == 'day' and 'light' or 'dark'),
    'vim.o.termguicolors = true',
    ("vim.g.colors_name = '%s'"):format(name),
    '',
    'local hl = vim.api.nvim_set_hl',
}

local names = vim.tbl_keys(groups)
table.sort(names)
for _, group in ipairs(names) do
    local val = groups[group]
    if type(val) == 'string' then
        val = { link = val }
    end
    local spec = vim.inspect(val, { newline = ' ', indent = '' })
    out[#out + 1] = ('hl(0, %q, %s)'):format(group, spec)
end

out[#out + 1] = ''
local terminal = {
    'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white',
}
for i, color in ipairs(terminal) do
    out[#out + 1] = ("vim.g.terminal_color_%d = '%s'"):format(i - 1, colors.terminal[color])
    out[#out + 1] = ("vim.g.terminal_color_%d = '%s'"):format(i + 7, colors.terminal[color .. '_bright'])
end

local script = debug.getinfo(1, 'S').source:sub(2)
local dest = vim.fn.fnamemodify(script, ':p:h:h') .. '/colors/' .. name .. '.lua'
vim.fn.mkdir(vim.fn.fnamemodify(dest, ':h'), 'p')
vim.fn.writefile(out, dest)
print(('wrote %s (%d groups)'):format(dest, #names))

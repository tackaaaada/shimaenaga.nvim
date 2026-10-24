local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h')
vim.opt.rtp:prepend(root)
require('shimaenaga').setup()
local anchors=vim.deepcopy(require('shimaenaga.palette'))
local comparison=dofile(root..'/scripts/validation/backgrounds.lua')
assert(comparison.index==2)
comparison.install()
vim.cmd.colorscheme("shimaenaga-yukiyo")
assert(require('shimaenaga.colors').setup({style='yukiyo'}).bg=='#070c17')
comparison.index=3 -- start each ordered cycle immediately before candidate one
local config=require('shimaenaga.config')
for _,transparent in ipairs({false,true}) do
  config.options.transparent=transparent
  for _,background in ipairs(comparison.values) do
    vim.cmd('ShimaenagaBackground')
    local c=require('shimaenaga.colors').setup({style='yukiyo'})
    assert(c.bg==background and c.base03==background)
    assert(c.bg_dark=='#111b2f' and c.fg==anchors.yukiyo.fg)
    assert(c.selection==require('shimaenaga.design').blend(background,c.blue,0.22))
    local normal=vim.api.nvim_get_hl(0,{name='Normal',link=false})
    if transparent then assert(normal.bg==nil) else assert(normal.bg==tonumber(background:sub(2),16)) end
    assert(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg==0x111b2f)
  end
end
assert(comparison.index==3)
vim.cmd.colorscheme('shimaenaga-ryuhyo')
assert(require('shimaenaga.colors').setup({style='ryuhyo'}).bg==anchors.ryuhyo.bg)
assert(vim.deep_equal(anchors,require('shimaenaga.palette')))
print('PASS: three session-local backgrounds, opaque/transparent surfaces, constant statusline, Ryuhyo and canonical palette unchanged.')

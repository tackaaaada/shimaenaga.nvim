local root = vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
local theme = require('shimaenaga')
local function fg(group) return string.format('#%06x',vim.api.nvim_get_hl(0,{name=group,link=false}).fg) end
for _, style in ipairs({'yukiyo','ryuhyo'}) do
  theme.setup({plugins={all=true,auto=false}})
  vim.cmd.colorscheme('shimaenaga-'..style)
  local p = require('shimaenaga.palette')[style]
  assert(vim.g.colors_name == 'shimaenaga-'..style)
  assert(vim.o.background==(style=='ryuhyo' and 'light' or 'dark'))
  for group, color in pairs({Normal=p.fg,Comment=p.comment,String=p.green,Keyword=p.purple,Function=p.blue,Type=p.cyan,Number=p.orange,Operator=p.magenta,DiagnosticError=p.red,['@variable.parameter']=p.fg,['@keyword']=p.purple}) do
    assert(fg(group)==color,style..' '..group..': expected '..color..', got '..fg(group))
  end
  assert(vim.g.terminal_color_1 == p.red)
  assert(vim.g.terminal_color_0 == p.bg and vim.g.terminal_color_8 == p.comment)
  assert(vim.g.terminal_color_9 == require('shimaenaga.colors').setup({style=style}).red300)
  for _,group in ipairs({'NormalFloat','Pmenu','BlinkCmpMenu','WhichKeyNormal','SnacksDashboardNormal','SnacksPickerNormal','CoverageSummaryNormal','MasonNormal'}) do
    assert(vim.api.nvim_get_hl(0,{name=group,link=false}).bg==tonumber((p.bg_menu or p.bg_dark):sub(2),16),group..' menu background mismatch')
  end
  assert(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg==tonumber(p.bg_dark:sub(2),16))

  assert(vim.api.nvim_get_hl(0,{name='Normal',link=false}).bg ~= nil)
  theme.setup({transparent=true,plugins={all=true,auto=false}})
  vim.cmd.colorscheme('shimaenaga-'..style)
  assert(vim.api.nvim_get_hl(0,{name='Normal',link=false}).bg == nil)
  for _, group in ipairs({'NormalFloat','NormalSB','Pmenu','BlinkCmpMenu','TabLine','WinBar','OilFile','CoverageSummaryNormal','MasonNormal','SnacksDashboardNormal','WhichKeyNormal'}) do
    local hl=vim.api.nvim_get_hl(0,{name=group,link=false})
    assert(hl.bg==nil,style..' opaque surface: '..group)
  end
  local c=require('shimaenaga.colors').setup({style=style})
  assert(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg==tonumber(c.bg_dark:sub(2),16))
  assert(fg('@punctuation.bracket')==c.bracket)
  assert(fg('@function.builtin')==p.blue and fg('@lsp.type.parameter')==p.fg)
  assert(fg('@variable.typescript')==p.fg, 'language-specific override survived')
  assert(vim.api.nvim_get_hl(0,{name='Visual',link=false}).bg~=nil)
  assert(vim.api.nvim_get_hl(0,{name='DiffAdd',link=false}).bg~=nil)
  assert(fg('CoveragePartial')==p.yellow and fg('NeotestRunning')==p.blue)
  assert(fg('NeotestSkipped')==p.fg_dark)
  theme.setup({transparent=true,styles={floats='dark',sidebars='normal'}})
  vim.cmd.colorscheme('shimaenaga-'..style)
  assert(vim.api.nvim_get_hl(0,{name='NormalFloat',link=false}).bg==tonumber((p.bg_menu or p.bg_dark):sub(2),16))
  assert(vim.api.nvim_get_hl(0,{name='NormalSB',link=false}).bg==tonumber(p.bg:sub(2),16))
  theme.setup()
  vim.o.background = style == 'yukiyo' and 'dark' or 'light'
  vim.cmd.colorscheme('shimaenaga')
  assert(vim.g.colors_name=='shimaenaga','alias name must support background-triggered reload')
  assert(fg('Normal')==p.fg,'alias did not follow background')
  vim.o.background = style=='yukiyo' and 'light' or 'dark'
  local other=require('shimaenaga.palette')[style=='yukiyo' and 'ryuhyo' or 'yukiyo']
  assert(fg('Normal')==other.fg,'background change failed to reload alias')
end
-- User overrides run after semantic defaults.
theme.setup({on_highlights=function(h) h.Keyword={fg='#123456'} end})
vim.cmd.colorscheme('shimaenaga-yukiyo')
assert(fg('Keyword')=='#123456')
theme.setup({on_colors=function(c) c.blue='#123456' end})
vim.cmd.colorscheme('shimaenaga-yukiyo')
assert(fg('Function')=='#123456','on_colors override ignored')
theme.setup({plugins={all=true,auto=false,oil=false},styles={keywords={italic=true}}})
local c=require('shimaenaga.colors').setup({style='yukiyo'})
local groups=require('shimaenaga.groups').setup(c,require('shimaenaga.config').options)
assert(groups.OilDir==nil,'disabled plugin still defined')
vim.cmd.colorscheme('shimaenaga-yukiyo')
assert(vim.api.nvim_get_hl(0,{name='Keyword',link=false}).italic,'keyword style option ignored')
local count = 0
for _, file in ipairs(vim.fn.globpath(root..'/lua','**/*.lua',false,true)) do assert(loadfile(file));count=count+1 end
print('PASS: both variants, anchors, plugins, transparency, background alias, overrides, '..count..' Lua files.')

-- Modified for Shimaenaga: namespace and adopted palette.
-- Lightline shares the same foreground mode accents and surrounding surface.
local c=require('shimaenaga.colors').setup({style=(vim.g.colors_name or ''):match('^shimaenaga%-(.+)$')})
local M={}
for mode,key in pairs({normal='blue',insert='green',visual='magenta',replace='red',command='yellow',inactive='fg_dark'}) do
  M[mode]={left={{c[key],c.bg_statusline},{c.fg_dark,c.bg_statusline}},middle={{c.fg,c.bg_statusline}},right={{c.fg,c.bg_statusline}},error={{c.red,c.bg_statusline}},warning={{c.yellow,c.bg_statusline}}}
end
M.tabline={left={{c.fg_dark,c.bg_statusline}},middle={{c.fg,c.bg_statusline}},right={{c.fg_dark,c.bg_statusline}},tabsel={{c.blue,c.bg_statusline}}}
return M

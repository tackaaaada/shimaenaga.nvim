-- Modified for Shimaenaga: mode bands and adopted palette.
-- Colored bands keep mode/branch/content distinct even in a transparent editor.
local c=require('shimaenaga.colors').setup({style=(vim.g.colors_name or ''):match('^shimaenaga%-(.+)$')})
local M={}
for mode,key in pairs({normal='blue',insert='green',visual='magenta',command='yellow',replace='red',terminal='green',inactive='fg_dark'}) do
  if mode == 'inactive' then
    M[mode]={a={fg=c.fg_dark,bg=c.bg_dark},b={fg=c.fg_dark,bg=c.bg_dark},c={fg=c.fg_dark,bg=c.bg_dark}}
  else
    M[mode]={a={fg=c.bg,bg=c[key],gui='bold'},b={fg=c.bg,bg=c.fg_dark},c={fg=c.fg,bg=c.bg_dark}}
  end
end
return M

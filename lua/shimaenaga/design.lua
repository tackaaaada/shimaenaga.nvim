-- Shared adopted color arithmetic; no theme/config/plugin side effects.
local M = {}
function M.blend(a,b,amount)
  local out='#'
  for i=2,6,2 do
    local x,y=tonumber(a:sub(i,i+1),16),tonumber(b:sub(i,i+1),16)
    out=out..string.format('%02x',math.floor(x+(y-x)*amount+0.5))
  end
  return out
end
function M.make(palette)
  local c=vim.deepcopy(palette)
  c.bracket=M.blend(c.orange,c.fg,0.20)
  c.selection=M.blend(c.bg,c.blue,0.22)
  c.search=M.blend(c.bg,c.yellow,0.22)
  c.diff_add=M.blend(c.bg,c.green,0.12)
  c.diff_change=M.blend(c.bg,c.blue,0.12)
  c.diff_delete=M.blend(c.bg,c.red,0.12)
  c.diff_text=M.blend(c.bg,c.blue,0.24)
  c.border=M.blend(c.bg,c.fg,0.35)
  c.diff={add=c.diff_add,change=c.diff_change,delete=c.diff_delete,text=c.diff_text}
  return c
end
return M

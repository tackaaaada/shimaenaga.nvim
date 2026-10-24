-- ANSI palette shared by Neovim :terminal and terminal-app exporters.
local M = {}
M.names = {'black','red','green','yellow','blue','magenta','cyan','white'}
function M.palette(c)
  return {
    foreground=c.fg,background=c.bg,cursor=c.base4,cursor_text=c.bg,
    selection_foreground=c.fg,selection_background=c.selection,
    normal={c.bg,c.red,c.green,c.yellow,c.blue,c.magenta,c.cyan,c.fg},
    bright={c.comment,c.red300,c.green300,c.yellow300,c.blue300,c.magenta300,c.cyan300,c.base4},
  }
end
return M

-- Final editor roles; input colors/options are never modified.
local M = {}
function M.apply(groups, c, opts)
  local set = require('shimaenaga.highlights.writer').for_groups(groups)
  local surface = opts.transparent and c.none or c.bg
  set('Normal NormalNC', {fg=c.fg,bg=surface})
  set('NormalSB', {fg=c.fg,bg=c.bg_sidebar})
  set('NormalFloat', {fg=c.fg,bg=c.bg_float})
  set('SignColumn FoldColumn EndOfBuffer Whitespace NonText', {fg=c.fg_dark,bg=surface})
  set('LineNr', {fg=c.fg_dark,bg=surface})
  set('CursorLineNr', {fg=c.yellow,bg=surface})
  set('CursorLine CursorColumn', {bg=c.bg_highlight})
  set('Visual VisualNOS', {fg=c.fg,bg=c.selection})
  set('Search', {fg=c.fg,bg=c.search})
  set('IncSearch CurSearch Substitute', {fg=c.bg,bg=c.yellow,bold=true})
  set('MatchParen', {fg=c.bracket,bg=c.selection,bold=true})
  set('DiffAdd', {bg=c.diff.add})
  set('DiffChange', {bg=c.diff.change})
  set('DiffDelete', {bg=c.diff.delete})
  set('DiffText', {bg=c.diff.text})
  set('Pmenu', {fg=c.fg,bg=c.bg_float})
  set('PmenuSel QuickFixLine', {fg=c.fg,bg=c.selection})
  set('PmenuSbar', {bg=c.bg_float})
  set('PmenuThumb', {bg=c.border})
  set('WinSeparator', {fg=c.border,bg=surface})
  set('FloatBorder', {fg=c.border,bg=c.bg_float})
  set('FloatTitle', {fg=c.purple,bg=c.bg_float,bold=true})
  set('WinBar TabLineFill', {fg=c.fg,bg=surface})
  set('StatusLine', {fg=c.fg,bg=c.bg_dark})
  set('WinBarNC TabLine', {fg=c.fg_dark,bg=surface})
  set('StatusLineNC', {fg=c.fg_dark,bg=c.bg_dark})
  set('TabLineSel', {fg=c.blue,bg=surface,bold=true})
  set('Title @markup.heading', {fg=c.purple,bold=true})
  for i=1,6 do set('@markup.heading.'..i..' markdownH'..i..' htmlH'..i,{fg=c.purple,bold=true}) end
  set('Underlined @markup.link @markup.link.url', {fg=c.blue,underline=true})
  set('@markup.raw.markdown_inline markdownCode markdownCodeBlock mkdCode', {fg=c.fg,bg=c.bg_highlight})
  set('@markup.list.checked', {fg=c.green})
  set('@markup.list.unchecked Todo @comment.todo', {fg=c.yellow})
  for severity,key in pairs({Error='red',Warn='yellow',Info='blue',Hint='cyan',Ok='green'}) do
    local color=c[key]
    set('Diagnostic'..severity..' DiagnosticSign'..severity..' DiagnosticVirtualText'..severity..' DiagnosticFloating'..severity,{fg=color})
    set('DiagnosticUnderline'..severity,{sp=color,undercurl=true})
  end
  set('@comment.error',{fg=c.red})
  set('@comment.warning',{fg=c.yellow})
  set('@comment.info',{fg=c.blue})
  set('@comment.hint @comment.note',{fg=c.cyan})
  return groups
end
return M

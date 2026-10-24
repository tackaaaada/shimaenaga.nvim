-- Shimaenaga integration: semantic links, no fixed upstream colors.
local M = {}
function M.get(c, opts)
  local groups = {}
  groups.RenderMarkdownCode = {fg=c.fg,bg=c.bg_highlight}
  groups.RenderMarkdownCodeInline = {fg=c.fg,bg=c.bg_highlight}
  groups.RenderMarkdownCodeBorder = {fg=c.border}
  groups.RenderMarkdownDash = {fg=c.border}
  groups.RenderMarkdownTableHead = {fg=c.border}
  groups.RenderMarkdownTableRow = {fg=c.border}
  groups.RenderMarkdownIndent = {fg=c.border}
  groups.RenderMarkdownBullet = "Delimiter"
  groups.RenderMarkdownChecked = "DiagnosticOk"
  groups.RenderMarkdownSuccess = "DiagnosticOk"
  groups.RenderMarkdownUnchecked = "DiagnosticWarn"
  groups.RenderMarkdownTodo = "DiagnosticWarn"
  groups.RenderMarkdownWarn = "DiagnosticWarn"
  groups.RenderMarkdownError = "DiagnosticError"
  groups.RenderMarkdownInfo = "DiagnosticInfo"
  groups.RenderMarkdownHint = "DiagnosticHint"
  groups.RenderMarkdownLink = "Underlined"
  groups.RenderMarkdownWikiLink = "Underlined"
  groups.RenderMarkdownHtmlComment = "Comment"
  groups.RenderMarkdownCodeInfo = "Type"
  groups.RenderMarkdownQuote = "Comment"
  groups.RenderMarkdownH1 = "Title"
  groups.RenderMarkdownH2 = "Title"
  groups.RenderMarkdownH3 = "Title"
  groups.RenderMarkdownH4 = "Title"
  groups.RenderMarkdownH5 = "Title"
  groups.RenderMarkdownH6 = "Title"
  groups.RenderMarkdownH1Bg = {bg=c.none}
  groups.RenderMarkdownH2Bg = {bg=c.none}
  groups.RenderMarkdownH3Bg = {bg=c.none}
  groups.RenderMarkdownH4Bg = {bg=c.none}
  groups.RenderMarkdownH5Bg = {bg=c.none}
  groups.RenderMarkdownH6Bg = {bg=c.none}
  return groups
end
return M

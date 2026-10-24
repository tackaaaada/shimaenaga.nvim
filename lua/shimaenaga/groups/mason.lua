-- Shimaenaga integration: semantic links, no fixed upstream colors.
local M = {}
function M.get(c, opts)
  local groups = {}
  groups.MasonNormal = "NormalFloat"
  groups.MasonBackdrop = "NormalFloat"
  groups.MasonHeader = "Title"
  groups.MasonHeaderSecondary = "Title"
  groups.MasonHeading = "Title"
  groups.MasonError = "DiagnosticError"
  groups.MasonWarning = "DiagnosticWarn"
  groups.MasonMuted = "Comment"
  groups.MasonHighlight = "Function"
  groups.MasonHighlightSecondary = "Function"
  groups.MasonLink = "Underlined"
  return groups
end
return M

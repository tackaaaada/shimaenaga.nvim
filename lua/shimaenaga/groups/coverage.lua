-- Shimaenaga integration: semantic links, no fixed upstream colors.
local M = {}
function M.get(c, opts)
  local groups = {}
  groups.CoverageCovered = "DiagnosticOk"
  groups.CoverageSummaryPass = "DiagnosticOk"
  groups.CoverageUncovered = "DiagnosticError"
  groups.CoverageSummaryFail = "DiagnosticError"
  groups.CoveragePartial = "DiagnosticWarn"
  groups.CoverageSummaryNormal = "NormalFloat"
  groups.CoverageSummaryBorder = "FloatBorder"
  groups.CoverageSummaryCursorLine = "Visual"
  groups.CoverageSummaryHeader = "Title"
  return groups
end
return M

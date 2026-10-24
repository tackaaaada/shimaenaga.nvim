-- Shimaenaga integration: semantic links, no fixed upstream colors.
local M = {}
function M.get(c, opts)
  local groups = {}
  groups.GrugFarResultsChangeIndicator = "DiagnosticInfo"
  groups.GrugFarResultsRemoveIndicator = "DiagnosticError"
  groups.GrugFarResultsAddIndicator = "DiagnosticOk"
  groups.GrugFarResultsMatch = "DiffText"
  groups.GrugFarResultsMatchAdded = "DiffAdd"
  groups.GrugFarResultsMatchRemoved = "DiffDelete"
  return groups
end
return M

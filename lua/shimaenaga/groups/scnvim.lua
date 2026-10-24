-- Shimaenaga integration: semantic links, no fixed upstream colors.
local M = {}
function M.get(c, opts)
  local groups = {}
  groups.scKeyword = "Keyword"
  groups.scControl = "Keyword"
  groups.scVar = "Keyword"
  groups.scInteger = "Constant"
  groups.scFloat = "Constant"
  groups.scBoolean = "Constant"
  groups.scInfinity = "Constant"
  groups.scSymbol = "Constant"
  groups.scArg = "Identifier"
  groups.scVariable = "Identifier"
  groups.scGlobVariable = "Identifier"
  groups.scGlobvariable = "Identifier"
  groups.scString = "String"
  groups.scChar = "String"
  groups.scComment = "Comment"
  groups.scLineComment = "Comment"
  groups.scCommentTodo = "Todo"
  groups.scObject = "Type"
  groups.scAoperator = "Operator"
  groups.scBinaryoperator = "Operator"
  groups.scUnaryoperator = "Operator"
  return groups
end
return M

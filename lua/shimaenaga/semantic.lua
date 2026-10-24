-- Rule order is part of the contract: syntax, editor UI, then enabled plugins.
local rules = {
  require('shimaenaga.highlights.syntax'),
  require('shimaenaga.highlights.editor'),
  require('shimaenaga.highlights.plugins'),
}
local M = {}
function M.apply(groups, colors, options)
  for _,rule in ipairs(rules) do rule.apply(groups,colors,options) end
  return groups
end
return M

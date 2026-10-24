-- Each highlight owns its attributes, so changing one cannot mutate a sibling.
local M = {}
function M.for_groups(groups)
  return function(names, attributes)
    for name in names:gmatch('%S+') do
      groups[name] = vim.deepcopy(attributes)
    end
  end
end
return M

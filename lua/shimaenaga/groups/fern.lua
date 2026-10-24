-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    FernBranchText = { fg = c.blue },
  }
end

return M

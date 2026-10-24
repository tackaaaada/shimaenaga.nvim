-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    InclineNormal = { bg = c.magenta500, fg = c.base04 },
    InclineNormalNC = { fg = c.violet500, bg = c.base03 },
  }
end

return M

-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    MiniAnimateCursor      = { reverse = true, nocombine = true },
    MiniAnimateNormalFloat = "NormalFloat",
  }
end

return M

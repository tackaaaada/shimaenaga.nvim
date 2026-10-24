-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    MiniCursorword        = { underline = true },
    MiniCursorwordCurrent = { underline = true },
  }
end

return M

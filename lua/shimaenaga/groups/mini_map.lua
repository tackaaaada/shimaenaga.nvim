-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    MiniMapNormal      = "NormalFloat",
    MiniMapSymbolCount = "Special",
    MiniMapSymbolLine  = "Title",
    MiniMapSymbolView  = "Delimiter",
  }
end

return M

-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  return {
    NeotestPassed       = { fg = c.green500 },
    NeotestRunning      = { fg = c.blue },
    NeotestFailed       = { fg = c.red500 },
    NeotestSkipped      = { fg = c.fg_dark },
    NeotestTest         = { fg = c.base00 },
    NeotestNamespace    = { fg = c.cyan500 },
    NeotestFocused      = { fg = c.yellow500 },
    NeotestFile         = { fg = c.cyan500 },
    NeotestDir          = { fg = c.blue500 },
    NeotestBorder       = { fg = c.blue500 },
    NeotestIndent       = { fg = c.base00 },
    NeotestExpandMarker = { fg = c.base0 },
    NeotestAdapterName  = { fg = c.violet500, bold = true },
    NeotestWinSelect    = { fg = c.blue500 },
    NeotestMarked       = { fg = c.blue500 },
    NeotestTarget       = { fg = c.blue500 },
    --[[ NeotestUnknown = {}, ]]
  }
end

return M

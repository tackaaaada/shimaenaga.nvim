-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.get(c, opts)
  -- stylua: ignore
  local groups = {
    SnacksDashboardNormal     = { fg = c.fg, bg = c.bg_float },
    SnacksDashboardNormalNC   = { fg = c.fg, bg = c.bg_float },
    SnacksDashboardDesc       = { fg = c.cyan500 },
    SnacksDashboardKey        = { fg = c.orange500 },
    SnacksDashboardFooter     = { fg = c.red, italic = true },
    SnacksDashboardSpecial    = { fg = c.yellow500 },
    SnacksDashboardHeader     = { fg = c.blue },
    SnacksDashboardTitle      = { fg = c.yellow, bold = true },
    SnacksDashboardIcon       = { fg = c.cyan500, bold = true },
    SnacksNotifierBorderTrace = { fg = c.magenta500 },
    SnacksNotifierIconTrace   = { fg = c.magenta500 },
    SnacksNotifierTitleTrace  = { fg = c.magenta500 },
    SnacksIndentScope         = { fg = c.violet700, nocombine = true },
    SnacksIndent              = { fg = c.base03, nocombine = true },
    SnacksPickerBorder        = { fg = c.base02, bg = c.bg_float },
    SnacksPickerTitle         = "Title",
    SnacksPickerPreviewTitle  = { fg = c.blue, bg = c.bg_float },
  }
  for severity,key in pairs({Error='red',Warn='yellow',Info='blue',Debug='fg_dark',Trace='fg_dark'}) do
    groups['SnacksNotifier'..severity]={fg=c.fg,bg=c.bg_float}
    groups['SnacksNotifierBorder'..severity]={fg=c[key],bg=c.bg_float}
    groups['SnacksNotifierIcon'..severity]={fg=c[key]}
    groups['SnacksNotifierTitle'..severity]={fg=c[key]}
  end
  return groups
end

return M

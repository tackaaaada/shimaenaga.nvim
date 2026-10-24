-- shimaenaga.nvim adopted palette
-- 雪夜 yukiyo (dark) / 流氷 ryuhyo (light)
--
-- Colorschemes:
--   shimaenaga-yukiyo  (dark)
--   shimaenaga-ryuhyo  (light)
--   shimaenaga         (alias: follows vim.o.background)
--
-- Inspired by Solarized: accent hues follow its 8 accents:
--   magenta=桜 / violet=ラベンダー / blue=摩周ブルー / cyan=青い池
--   green=エゾマツ / red=ナナカマド / orange=カエデ / yellow=イチョウ・カラマツ
--
-- Accents: OKLCH lightness kept, chroma x1.7 (gamut-clipped).
-- Designed for use with a translucent terminal (~80% opacity + blur).
--
-- Canonical adopted colors. Derived semantic colors live in colors.lua.
-- Comments and Ryuhyo were refined during the design preview.

local M = {}

-- 雪夜 (dark): deeper blue-black background, refined after desktop preview.
M.yukiyo = {
  bg = "#070c17",
  bg_dark = "#111b2f", -- secondary surfaces and statusline (lighter than main background)
  bg_menu = "#0b1221", -- menus/dashboard/floats, independent of the statusline
  bg_highlight = "#19253d", -- cursorline: subtle separation from the deeper background
  fg = "#a8b6b7", -- ポプラ
  fg_dark = "#8d9ba0", -- secondary foreground
  comment = "#7d8f92",

  magenta = "#e277aa", -- 桜 (operators, special)
  purple = "#8f91e0", -- ラベンダー (keywords)
  blue = "#3c9ee3", -- 摩周ブルー (functions, info)
  cyan = "#23b4a9", -- 青い池 (types, builtins, hint)
  green = "#99a921", -- エゾマツ (strings)
  red = "#f84e4e", -- ナナカマド (errors / failures / deletions)
  orange = "#e77121", -- カエデ (numbers, constants)
  yellow = "#cc9e07", -- イチョウ・カラマツ (warnings / active search)
}

-- 流氷 (light): same hue as 雪夜 (~263 deg), whitened (B2)
M.ryuhyo = {
  bg = "#e9eef5",
  bg_dark = "#dfe5ee", -- sidebars, floats (candidate: #e5ebf8 for a clearer edge)
  bg_highlight = "#d5deeb", -- cursorline (candidate: #dbe2f1 for stronger)
  fg = "#44556a",
  fg_dark = "#5c6c80", -- secondary foreground
  comment = "#657488",

  magenta = "#b51070",
  purple = "#5146c7",
  blue = "#005cad",
  cyan = "#00756b",
  green = "#526700",
  red = "#b80018",
  orange = "#a63f00",
  yellow = "#785800",
}

return M

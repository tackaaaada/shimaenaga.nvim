-- Assemble a complete scheme from input values; no config/editor mutation.
local design = require('shimaenaga.design')
local M = {}
local accents = {'yellow','orange','red','magenta','violet','blue','cyan','green'}
local function add_foreground_tones(c, toward)
  for _,name in ipairs(accents) do
    for _,tier in ipairs({50,100,200,300,400,500}) do
      c[name..tier] = tier == 500 and c[name] or design.blend(c[name],toward,(500-tier)/1500)
    end
  end
end
local function add_background_tones(c)
  for _,name in ipairs(accents) do
    for _,tier in ipairs({600,700,800,900,950}) do
      c[name..tier] = design.blend(c.bg,c[name],(1000-tier)/1000)
    end
  end
  c.blue0, c.blue7 = c.blue600, c.blue700
end
function M.build(palette, style, config)
  local p = design.make(palette)
  local light = style == 'ryuhyo'
  local toward = light and '#000000' or '#ffffff'
  p.none, p._style, p._style_name = 'NONE', style, 'Shimaenaga ' .. (light and 'Ryuhyo' or 'Yukiyo')
  -- Base slots keep their semantic roles in both variants (not RGB inversion).
  p.base04, p.base03, p.base02 = p.bg_dark, p.bg, p.bg_highlight
  p.base01, p.base00, p.base0, p.base1 = p.comment, p.fg_dark, p.fg, p.fg
  p.base2, p.base3, p.base4 = p.fg_dark, p.fg, design.blend(p.fg, toward, 0.2)
  p.violet = p.purple
  add_foreground_tones(p, toward)
  add_background_tones(p)
  p.bg_statusline = config.transparent and p.none or p.bg
  for _, key in ipairs({'sidebar','float'}) do
    local setting = config.styles[key == 'sidebar' and 'sidebars' or 'floats']
    if setting == 'auto' then setting = config.transparent and 'transparent' or 'dark' end
    local dark = key == 'float' and (p.bg_menu or p.bg_dark) or p.bg_dark
    p['bg_'..key] = setting == 'transparent' and p.none or setting == 'dark' and dark or p.bg
  end
  p.bg_popup = p.bg_float
  p.fg_float = p.fg
  p.error, p.warning, p.info, p.hint, p.todo = p.red, p.yellow, p.blue, p.cyan, p.yellow
  p.git = {add=p.green, change=p.blue, delete=p.red}
  -- Compatibility aliases for integrations using Tokyo Night-style names.
  p.blue1, p.blue2 = p.blue, p.blue300
  p.green1, p.green2, p.teal, p.red1 = p.green300, p.green, p.cyan, p.red
  p.magenta2 = p.magenta300
  p.bg_dark1, p.dark5, p.pink = p.bg_dark, p.fg_dark, p.magenta
  p._name = "shimaenaga_" .. style
  p._colors_name = p._style_name
  return p
end

-- Rebuild only background-dependent values, preserving user color overrides.
function M.with_background(colors, background)
  local old = colors.bg
  local palette = vim.deepcopy(colors)
  palette.bg = background
  local c = design.make(palette)
  c.base03 = c.bg
  for _,key in ipairs({'bg_float','bg_sidebar','bg_popup','bg_statusline'}) do
    if c[key] == old then c[key] = c.bg end
  end
  add_background_tones(c)
  return c
end
return M

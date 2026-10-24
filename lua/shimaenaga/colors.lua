-- Modified for Shimaenaga: adopted palette and pure color assembly.
-- Resolve the requested style and invoke user customization at the API boundary.
local M = {}
M.blend = require('shimaenaga.design').blend
function M.setup(opts)
  opts = opts or {}
  local config = require('shimaenaga.config').options
  local style = opts.style or config.style
  if not style or style == 'auto' then
    style = vim.o.background == 'light' and 'ryuhyo' or 'yukiyo'
  end
  assert(style == 'yukiyo' or style == 'ryuhyo', 'Unknown Shimaenaga style: '..tostring(style))
  local colors = require('shimaenaga.color_scheme').build(require('shimaenaga.palette')[style],style,config)
  config.on_colors(colors)
  return colors
end
return M

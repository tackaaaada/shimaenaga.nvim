-- Modified for Shimaenaga: variant loading and configuration isolation.
local M = {}
M.setup = require('shimaenaga.config').setup
function M.load(opts)
  local config = require('shimaenaga.config')
  -- A named :colorscheme affects this load only; the alias follows background.
  local previous = vim.deepcopy(config.options)
  if opts then config.extend(opts) end
  local style = config.options.style
  if style == 'yukiyo' or style == 'ryuhyo' then
    -- Avoid recursively reloading the previous colorscheme while updating &background.
    local name = vim.g.colors_name
    vim.g.colors_name = nil
    vim.o.background = style == 'ryuhyo' and 'light' or 'dark'
    vim.g.colors_name = name
  end
  local ok, result = pcall(require('shimaenaga.theme').setup)
  config.options = previous
  if not ok then error(result) end
  return result
end
M.colorscheme = M.load
return M

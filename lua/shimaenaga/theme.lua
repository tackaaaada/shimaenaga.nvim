-- Modified for Shimaenaga: namespace and palette integration.
local M = {}

function M.setup()
  local colors = require("shimaenaga.colors").setup()
  local opts = require("shimaenaga.config")
  local groups = require("shimaenaga.groups").setup(colors, opts.options)

  if vim.g.loaded_lightline then
    vim.g.lightline = { colorscheme = "shimaenaga" }
  end

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = opts.options.style == "auto" and "shimaenaga" or "shimaenaga-" .. colors._style

  groups = require("shimaenaga.semantic").apply(groups, colors, opts.options)
  opts.options.on_highlights(groups, colors)

  for group, hl in pairs(groups) do
    hl = type(hl) == "string" and { link = hl } or hl
    vim.api.nvim_set_hl(0, group, hl)
  end

  local oil = groups.OilNormal and require('shimaenaga.integrations.oil')
    or package.loaded['shimaenaga.integrations.oil']
  if oil then oil.setup(groups.OilNormal ~= nil) end

  if opts.options.terminal_colors then
    M.terminal(colors)
  end

  return colors, groups, opts
end

---@param colors ColorScheme
function M.terminal(colors)
  local terminal = require('shimaenaga.terminal').palette(colors)
  for index,color in ipairs(terminal.normal) do vim.g['terminal_color_'..(index-1)] = color end
  for index,color in ipairs(terminal.bright) do vim.g['terminal_color_'..(index+7)] = color end
end

return M

-- Session-local background comparison. Never write the theme's canonical palette.
local M = {}
M.values = {'#090f1c', '#070c17', '#050910'}
M.index = 2
function M.install()
  local config = require('shimaenaga.config')
  local previous = config.options.on_colors
  config.options.on_colors = function(c)
    previous(c)
    if c._style ~= 'yukiyo' then return end
    local colors = require('shimaenaga.color_scheme').with_background(c,M.values[M.index])
    for key,value in pairs(colors) do c[key] = value end
  end
  local function cycle()
    if vim.g.colors_name ~= 'shimaenaga-yukiyo' and not (vim.g.colors_name == 'shimaenaga' and vim.o.background == 'dark') then
      vim.notify('雪夜に切り替えてから F6 を押してください。')
      return
    end
    M.index = M.index % #M.values + 1
    vim.cmd.colorscheme('shimaenaga-yukiyo')
    vim.notify(('雪夜の背景 %d/3: %s'):format(M.index,M.values[M.index]))
  end
  vim.keymap.set('n','<F6>',cycle,{desc='Compare Shimaenaga Yukiyo backgrounds'})
  vim.api.nvim_create_user_command('ShimaenagaBackground',cycle,{desc='Cycle the three Yukiyo backgrounds'})
end
return M

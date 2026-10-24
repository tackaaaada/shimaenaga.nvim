-- Apply/restore Oil window mappings only while Shimaenaga is active.
local M = {}
local saved = {}
local enabled = false
local mapping={Normal='OilNormal',NormalNC='OilNormalNC',NormalFloat='OilNormal',EndOfBuffer='OilNormal',FloatBorder='OilFloatBorder',FloatTitle='OilFloatTitle',FloatFooter='OilWinBar',WinBar='OilWinBar',WinBarNC='OilWinBar',CursorLine='OilCursorLine'}
function M.refresh()
  local active=enabled and (vim.g.colors_name or ''):match('^shimaenaga')
  for _,win in ipairs(vim.api.nvim_list_wins()) do
    local oil=vim.bo[vim.api.nvim_win_get_buf(win)].filetype=='oil'
    if active and oil then
      if saved[win]==nil then saved[win]=vim.wo[win].winhighlight end
      local parts={}
      for item in saved[win]:gmatch('[^,]+') do
        if not mapping[item:match('^([^:]+):')] then parts[#parts+1]=item end
      end
      for from,to in pairs(mapping) do parts[#parts+1]=from..':'..to end
      table.sort(parts)
      vim.wo[win].winhighlight=table.concat(parts,',')
    elseif saved[win]~=nil then
      vim.wo[win].winhighlight=saved[win]
      saved[win]=nil
    end
  end
  for win in pairs(saved) do if not vim.api.nvim_win_is_valid(win) then saved[win]=nil end end
end
function M.setup(is_enabled)
  enabled=is_enabled
  local group=vim.api.nvim_create_augroup('ShimaenagaOilSurfaces',{clear=true})
  vim.api.nvim_create_autocmd({'BufWinEnter','WinEnter','ColorScheme'},{group=group,callback=function() vim.schedule(M.refresh) end})
  vim.api.nvim_create_autocmd('FileType',{group=group,pattern='oil',callback=function() vim.schedule(M.refresh) end})
  M.refresh()
end
return M

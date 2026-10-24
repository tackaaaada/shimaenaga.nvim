local root=vim.g.validation_root
require('lazy').load({plugins={'oil.nvim'}})
-- An unrelated mapping must survive while the theme applies its own mappings.
require('oil.config').float.win_options.winhighlight='Search:IncSearch'
local counts=0
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  for _,transparent in ipairs({false,true}) do
    require('shimaenaga').setup({transparent=transparent,plugins={all=true,auto=false}})
    vim.cmd.colorscheme('shimaenaga-'..style)
    require('oil').open_float(root..'/build/verification/samples')
    vim.wait(500,function() return false end,50)
    local win=vim.api.nvim_get_current_win()
    local buf=vim.api.nvim_win_get_buf(win)
    assert(vim.bo[buf].filetype=='oil')
    assert(vim.wo[win].winhighlight:find('Normal:OilNormal',1,true))
    local c=require('shimaenaga.colors').setup({style=style})
    for _,name in ipairs({'OilNormal','OilNormalNC','OilFloatBorder','OilFloatTitle','OilWinBar'}) do
      local bg=vim.api.nvim_get_hl(0,{name=name,link=false}).bg
      if transparent then assert(bg==nil,name) else assert(bg==tonumber(c.bg_float:sub(2),16),name) end
    end
    for _,name in ipairs({'OilFile','OilDir','OilLink','OilHidden','OilEmpty'}) do
      assert(vim.api.nvim_get_hl(0,{name=name,link=false}).bg==nil,name..' entry has a background')
    end
    assert(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg==tonumber(c.bg_dark:sub(2),16))
    -- Reopening and theme changes must preserve the menu surface mapping.
    vim.cmd.colorscheme('shimaenaga-'..style)
    vim.wait(50,function() return false end,10)
    assert(vim.wo[win].winhighlight:find('NormalNC:OilNormalNC',1,true))
    local saved='Search:IncSearch'
    vim.cmd.colorscheme('default')
    vim.wait(50,function() return false end,10)
    assert(vim.wo[win].winhighlight==saved,'mapping not restored on theme change')
    require('oil').close()
    vim.wait(50,function() return false end,10)
    counts=counts+1
  end
end
print('PASS: '..counts..' actual Oil floats; uniform menu/background-free entry highlights, fixed statusline, reload and mapping restoration.')
vim.cmd('qa!')

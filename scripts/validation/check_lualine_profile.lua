-- Inspect the actual LazyVim pretty_path renderer, including its dynamic highlights.
local root=vim.g.validation_root
local path=root..'/build/verification/samples/typescript/sample.ts'
vim.cmd.edit(vim.fn.fnameescape(path))
require('lazy').load({plugins={'lualine.nvim'}})
vim.wait(350,function() return false end,50)
local original=vim.deepcopy(require('lualine').get_config().sections)
local cases=0
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  for _,transparent in ipairs({true,false}) do
    require('shimaenaga').setup({transparent=transparent})
    vim.cmd.colorscheme('shimaenaga-'..style)
    local c=require('shimaenaga.colors').setup({style=style})
    for _,state in ipairs({'saved','modified','readonly'}) do
      vim.bo.modified=state=='modified'
      vim.bo.readonly=state=='readonly'
      require('lualine').refresh({place={'statusline'},scope='window',force=true})
      local result=vim.api.nvim_eval_statusline(vim.o.statusline,{highlights=true,maxwidth=200})
      local first,last=result.str:find('samples/typescript/sample.ts',1,true)
      assert(first,'path not rendered: '..state)
      local active
      for i,span in ipairs(result.highlights) do
        local next_start=result.highlights[i+1] and result.highlights[i+1].start or #result.str
        if span.start<last and next_start>first-1 then
          local hl=vim.api.nvim_get_hl(0,{name=span.group,link=false})
          assert(hl.bg==tonumber(c.bg_dark:sub(2),16),style..' '..state..' path background: '..span.group)
          active=true
        end
      end
      assert(active)
      assert(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg==tonumber(c.bg_dark:sub(2),16))
      cases=cases+1
    end
  end
end
vim.bo.modified,vim.bo.readonly=false,false
assert(vim.deep_equal(original,require('lualine').get_config().sections),'section items changed')
print('PASS: '..cases..' actual LazyVim path renderings (saved/modified/readonly), uniform information background, and unchanged section items.')
vim.cmd('qa!')

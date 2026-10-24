-- Traditional syntax is tested without the user's config or theme overrides.
local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h:h')
vim.opt.rtp:prepend(root)
for _,plugin in ipairs({'lean.nvim','vim-review'}) do vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/lazy/')..plugin) end
vim.cmd('syntax enable')
local inventory=vim.json.decode(table.concat(vim.fn.readfile(root..'/build/verification/inventory.json'),'\n'))
local results={}
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  require('shimaenaga').setup()
  vim.cmd.colorscheme('shimaenaga-'..style)
  for _,lang in ipairs({'lean','review'}) do
    vim.cmd.edit(vim.fn.fnameescape(inventory[lang]))
    vim.bo.syntax=lang
    local found={}
    for row,line in ipairs(vim.api.nvim_buf_get_lines(0,0,-1,false)) do
      for col=1,#line do
        local id=vim.fn.synID(row,col,1)
        local name=vim.fn.synIDattr(id,'name')
        if name~='' then found[name]=vim.fn.synIDattr(vim.fn.synIDtrans(id),'fg#') end
      end
    end
    assert(next(found),lang..': no actual syntax matches')
    results[#results+1]={style=style,language=lang,groups=found}
  end
end
vim.fn.writefile({vim.json.encode(results)},root..'/build/verification/reports/traditional-syntax.json')
print('PASS: actual Lean and Re:VIEW syntax matches in both themes.')

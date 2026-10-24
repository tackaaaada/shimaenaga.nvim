-- Check band colors standalone; optionally check rendering with an installed Lualine.
local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h')
vim.opt.rtp:prepend(root)
local lualine_path=vim.env.SHIMAENAGA_LUALINE_PATH
if lualine_path and lualine_path~='' then vim.opt.rtp:append(vim.fn.fnamemodify(lualine_path,':p')) end
local has_lualine,lualine=pcall(require,'lualine')
if lualine_path and lualine_path~='' then assert(has_lualine,'Lualine is not available at SHIMAENAGA_LUALINE_PATH') end
vim.opt.laststatus=2
vim.cmd.file('bird.lua')
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  for _,transparent in ipairs({true,false}) do
    require('shimaenaga').setup({transparent=transparent})
    vim.cmd.colorscheme('shimaenaga-'..style)
    package.loaded['lualine.themes.shimaenaga']=nil
    local palette=require('shimaenaga.colors').setup({style=style})
    local theme=require('lualine.themes.shimaenaga')
    for mode,key in pairs({normal='blue',insert='green',visual='magenta',command='yellow',replace='red'}) do
      assert(theme[mode].a.bg==palette[key])
      assert(theme[mode].b.bg==palette.fg_dark)
      assert(theme[mode].c.bg==palette.bg_dark)
      assert(theme[mode].a.bg~=theme[mode].b.bg and theme[mode].b.bg~=theme[mode].c.bg)
    end
    if has_lualine then
      lualine.setup({options={theme='shimaenaga',section_separators={left='',right=''},component_separators={left='',right=''}}})
      lualine.refresh({place={'statusline'},scope='window',force=true})
      local config=lualine.get_config()
      assert(config.sections.lualine_a[1]=='mode')
      assert(config.sections.lualine_b[1]=='branch')
      local rendered=vim.api.nvim_eval_statusline(vim.o.statusline,{highlights=true})
      assert(rendered.str:find('NORMAL',1,true))
      assert(rendered.str:find('',1,true) and rendered.str:find('',1,true))
    end
    local bg=vim.api.nvim_get_hl(0,{name='Normal',link=false}).bg
    if transparent then assert(bg==nil) else assert(bg==tonumber(palette.bg:sub(2),16)) end
  end
end
print('PASS: Lualine mode bands and backgrounds in both themes/transparency states.')
if has_lualine then
  print('PASS: Lualine section content and rendered arrow separators.')
else
  print('SKIP: external Lualine rendering; set SHIMAENAGA_LUALINE_PATH to an installed checkout to include it.')
end

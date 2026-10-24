local root=vim.g.validation_root
local base=root..'/build/verification'
local report={style=vim.env.SHIMAENAGA_STYLE or 'yukiyo',transparent=vim.env.SHIMAENAGA_TRANSPARENT=='1',parsers={},plugins={},lsp={},formats={},notes={}}
local inventory=vim.json.decode(table.concat(vim.fn.readfile(base..'/inventory.json'),'\n'))
local function error_text(err) return tostring(err):gsub('\n',' '):sub(1,800) end
local function open_file(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/site'))
  vim.bo.swapfile=false
  vim.wait(150,function() return false end,30)
  return vim.api.nvim_get_current_buf()
end
local languages=vim.tbl_keys(inventory);table.sort(languages)
for _,lang in ipairs(languages) do
  if lang~='lean' and lang~='review' and lang~='jsx' and lang~='jsonc' then
    local item={language=lang,file=inventory[lang]}
    local ok,err=pcall(function()
      local buf=open_file(item.file)
      local parser=vim.treesitter.get_parser(buf,lang)
      local trees=parser:parse()
      local query=vim.treesitter.query.get(lang,'highlights')
      assert(trees[1] and query,'no parse tree or highlights query')
      local count=0
      for _ in query:iter_captures(trees[1]:root(),buf,0,-1) do count=count+1 end
      item.captures=count
      item.parse_has_error=trees[1]:root():has_error()
      vim.treesitter.start(buf,lang)
      item.status=count==0 and 'no-captures' or item.parse_has_error and 'parse-errors' or 'pass'
    end)
    if not ok then item.status='blocked';item.reason=error_text(err) end
    report.parsers[#report.parsers+1]=item
  end
end
for _,entry in ipairs({{'jsx','tsx'},{'jsonc','json'},{'lean',nil},{'review',nil}}) do
  local lang,parser=entry[1],entry[2]
  local item={language=lang}
  local ok,err=pcall(function()
    local buf=open_file(inventory[lang])
    if parser then
      vim.treesitter.start(buf,parser)
      local tree=vim.treesitter.get_parser(buf,parser):parse()[1]
      item.parse_has_error=tree:root():has_error()
    else
      vim.cmd('syntax enable')
      vim.cmd('setlocal syntax='..(lang=='review' and 'review' or 'lean'))
      item.syntax=vim.bo[buf].syntax
    end
    item.status='pass'
  end)
  if not ok then item.status='blocked';item.reason=error_text(err) end
  report.formats[#report.formats+1]=item
end
-- Load installed plugins through lazy.nvim, recording actual load/config failures.
local targets={'blink.cmp','fzf-lua','snacks.nvim','oil.nvim','noice.nvim','bufferline.nvim','lualine.nvim','gitsigns.nvim','trouble.nvim','which-key.nvim','render-markdown.nvim','neotest','nvim-coverage','grug-far.nvim','lean.nvim','scnvim','todo-comments.nvim','zen-mode.nvim','mason.nvim','yanky.nvim','mini.icons','nvim-web-devicons','vim-review'}
for _,name in ipairs(targets) do
  local item={name=name}
  local ok,err=pcall(function()
    require('lazy').load({plugins={name}})
    local p=require('lazy.core.config').plugins[name]
    assert(p and p._.loaded,'not loaded')
    item.status='loaded'
  end)
  if not ok then item.status='blocked';item.reason=error_text(err) end
  report.plugins[#report.plugins+1]=item
end
-- Capture actual TS roles from the TypeScript parser, not annotated preview strings.
vim.opt.rtp:append(vim.fn.expand('~/.local/share/nvim/site'))
local tsbuf=open_file(inventory.typescript)
vim.treesitter.start(tsbuf,'typescript')
vim.treesitter.get_parser(tsbuf,'typescript'):parse()
report.typescript={}
report.palette=require('shimaenaga.colors').setup({style=report.style})
for _,token in ipairs({'type','Bird','name','string','{','}','greet','bird','count'}) do
  local lines=vim.api.nvim_buf_get_lines(tsbuf,0,-1,false)
  for row,line in ipairs(lines) do
    local col=line:find(token,1,true)
    if col then
      local captures=vim.treesitter.get_captures_at_pos(tsbuf,row-1,col-1)
      local info={text=token,row=row,col=col,captures={}}
      for _,capture in ipairs(captures) do
        local group='@'..capture.capture..'.'..capture.lang
        local hl=vim.api.nvim_get_hl(0,{name=group,link=false})
        info.captures[#info.captures+1]={capture=capture.capture,language=capture.lang,group=group,fg=hl.fg and string.format('#%06x',hl.fg)}
      end
      local c=report.palette
      local expected_color=({type=c.purple,Bird=c.cyan,name=c.fg,string=c.cyan,['{']=c.bracket,['}']=c.bracket,greet=c.blue,bird=c.fg,count=c.fg})[token]
      info.expected=expected_color
      info.status='mismatch'
      for _,capture in ipairs(info.captures) do if capture.fg==expected_color then info.status='pass' end end
      report.typescript[#report.typescript+1]=info
      break
    end
  end
end
-- Invoke real plugin views. "opened" means a real buffer/window, not a visual verdict.
report.views={}
local view_cases={
  {'oil.nvim',function() require('oil').open_float(base..'/samples') end},
  {'snacks.nvim',function() Snacks.notifier.notify('Shimaenaga verification',vim.log.levels.INFO,{timeout=10000}) end},
  {'grug-far.nvim',function() require('grug-far').open() end},
  {'neotest',function() require('neotest').summary.open() end},
  {'mason.nvim',function() vim.cmd('Mason') end},
  {'scnvim',function() open_file(inventory.supercollider);require('scnvim.postwin').open() end},
  {'lean.nvim',function() open_file(inventory.lean);require('lean.infoview').open() end},
  {'noice.nvim',function() vim.cmd('Noice history') end},
  {'nvim-coverage',function() require('coverage').summary() end},
}
for _,case in ipairs(view_cases) do
  local before={};for _,win in ipairs(vim.api.nvim_list_wins()) do before[win]=true end
  local item={name=case[1],windows={}}
  local ok,err=pcall(case[2])
  vim.wait(350,function() return false end,50)
  for _,win in ipairs(vim.api.nvim_list_wins()) do
    if not before[win] then
      local buf=vim.api.nvim_win_get_buf(win)
      item.windows[#item.windows+1]={filetype=vim.bo[buf].filetype,winhighlight=vim.wo[win].winhighlight,float=vim.api.nvim_win_get_config(win).relative~=''}
    end
  end
  if #item.windows==0 and case[1]=='lean.nvim' then
    for _,win in ipairs(vim.api.nvim_list_wins()) do
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype=='leaninfo' then
        item.windows[#item.windows+1]={filetype='leaninfo',existing=true}
      end
    end
  end
  item.status=ok and (#item.windows>0 and 'opened' or 'no-new-window') or 'blocked'
  if not ok then item.reason=error_text(err) end
  report.views[#report.views+1]=item
  for _,win in ipairs(vim.api.nvim_list_wins()) do
    if not before[win] then pcall(vim.api.nvim_win_close,win,true) end
  end
end
report.surfaces={}
for _,name in ipairs({'Normal','NormalFloat','Pmenu','BlinkCmpMenu','StatusLine','TabLine','WinBar','SnacksNotifierInfo','CoverageSummaryNormal','MasonNormal','BufferLineBufferSelected','BlinkCmpMenuSelection'}) do
  local hl=vim.api.nvim_get_hl(0,{name=name,link=false})
  report.surfaces[name]={fg=hl.fg and string.format('#%06x',hl.fg),bg=hl.bg and string.format('#%06x',hl.bg)}
end
report.renderers={}
for name,option in pairs({lualine='statusline',bufferline='tabline'}) do
  local ok,value=pcall(vim.api.nvim_eval_statusline,vim.o[option],{use_tabline=option=='tabline',highlights=true})
  report.renderers[name]={status=ok and 'evaluated' or 'blocked',result=ok and value or error_text(value)}
end

-- Existing LazyVim server configurations are allowed to attach; no server installation.
for _,lang in ipairs(vim.env.SHIMAENAGA_QUICK=='1' and {} or {'typescript','javascript','python','rust','go','lua','bash','lean'}) do
  local item={language=lang}
  local buf=open_file(inventory[lang])
  vim.api.nvim_exec_autocmds('FileType',{buffer=buf})
  vim.wait(6000,function()
    for _,client in ipairs(vim.lsp.get_clients({bufnr=buf})) do if client.initialized then return true end end
    return false
  end,100)
  local clients=vim.lsp.get_clients({bufnr=buf})
  item.clients={}
  for _,client in ipairs(clients) do
    local server={name=client.name,semantic_tokens=not not client.server_capabilities.semanticTokensProvider}
    item.clients[#item.clients+1]=server
    if server.semantic_tokens then
      pcall(vim.lsp.semantic_tokens.start,buf,client.id)
      vim.wait(2500,function()
        for row=0,vim.api.nvim_buf_line_count(buf)-1 do
          local info=vim.inspect_pos(buf,row,0,{treesitter=false,syntax=false,semantic_tokens=true,extmarks=false})
          if info.semantic_tokens and #info.semantic_tokens>0 then return true end
        end
        return false
      end,100)
      local found={}
      for row,line in ipairs(vim.api.nvim_buf_get_lines(buf,0,-1,false)) do
        for col=0,#line-1 do
          local info=vim.inspect_pos(buf,row-1,col,{treesitter=false,syntax=false,semantic_tokens=true,extmarks=false})
          for _,t in ipairs(info.semantic_tokens or {}) do
            local name=t.opts and t.opts.hl_group or t.hl_group
            if name then found[name]=true end
          end
        end
      end
      server.groups=vim.tbl_keys(found);table.sort(server.groups)
      server.colors={}
      for group in pairs(found) do
        local hl=vim.api.nvim_get_hl(0,{name=group,link=false})
        if hl.fg then server.colors[group]=string.format('#%06x',hl.fg) end
      end
      server.tokens_received=#server.groups>0
    end
  end
  item.status=#clients>0 and 'attached' or 'blocked'
  if #clients==0 then item.reason='No configured server attached within 6 seconds' end
  report.lsp[#report.lsp+1]=item
end
report.lsp[#report.lsp+1]={language='ruby',status='blocked',reason='Ruby LSP automatically composes/installs a bundle; disabled to preserve the offline constraint. Ruby syntax is tested.'}
report.messages=vim.api.nvim_exec2('messages',{output=true}).output
for _,plugin in ipairs(report.plugins) do
  if report.messages:find('Failed to run `config` for '..plugin.name,1,true) then
    plugin.status='blocked';plugin.reason='Plugin config failed; see captured messages (runtime socket permissions for fzf-lua).'
  end
end
vim.fn.mkdir(base..'/reports','p')
local file=base..'/reports/'..report.style..'-'..(report.transparent and 'transparent' or 'opaque')..'.json'
vim.fn.writefile({vim.json.encode(report)},file)
for _,client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
print('Verification report: '..file)
vim.cmd('qa!')

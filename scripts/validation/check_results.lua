-- Check observable results, keeping blocked integrations distinct from passing checks.
local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h:h')
vim.opt.rtp:prepend(root)
local base=root..'/build/verification/reports/'
local function read(file) return vim.json.decode(table.concat(vim.fn.readfile(file),'\n')) end
local function hex(value) return value and string.format('#%06x',value) end
local role={type='cyan',class='cyan',struct='cyan',interface='cyan',typeParameter='cyan',namespace='cyan',function_='blue',method='blue',variable='fg',property='fg',parameter='fg',keyword='purple',operator='magenta',macro='magenta',formatSpecifier='magenta',string='green',number='orange',boolean='orange',enumMember='orange'}
role['function']=role.function_
local protocol=read(base..'lsp-protocol.json')
local vtsls
for _,server in ipairs(protocol) do if server.name=='vtsls' then vtsls=server end end
assert(vtsls and vtsls.status=='tokens-received')
local token_checks=0
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  for _,transparent in ipairs({true,false}) do
    local result=read(base..style..'-'..(transparent and 'transparent' or 'opaque')..'.json')
    assert(#result.parsers==41)
    for _,parser in ipairs(result.parsers) do assert(parser.status=='pass',parser.language..': '..parser.status) end
    for _,capture in ipairs(result.typescript) do assert(capture.status=='pass',capture.text..' color mismatch') end
    for _,name in ipairs({'Normal','NormalFloat','Pmenu','BlinkCmpMenu','TabLine','WinBar','SnacksNotifierInfo','CoverageSummaryNormal','MasonNormal','BufferLineBufferSelected'}) do
      local actual=result.surfaces[name]
      assert(actual,name..' not measured')
      if transparent then assert(actual.bg==nil,name..' unexpectedly opaque') else assert(actual.bg~=nil,name..' missing background') end
    end
    require('shimaenaga').setup({transparent=transparent,plugins={all=true,auto=false}})
    vim.cmd.colorscheme('shimaenaga-'..style)
    local c=require('shimaenaga.colors').setup({style=style})
    assert(hex(vim.api.nvim_get_hl(0,{name='StatusLine',link=false}).bg)==c.bg_dark)
    -- Resolve real vtsls token kinds and modifiers through the final theme groups.
    local types=vtsls.semantic_provider.legend.tokenTypes
    local modifiers=vtsls.semantic_provider.legend.tokenModifiers
    local data=vtsls.tokens.data
    for i=1,#data,5 do
      local kind=types[data[i+3]+1]
      local key=role[kind]
      if key then
        local group='@lsp.type.'..kind..'.typescript'
        assert(hex(vim.api.nvim_get_hl(0,{name=group,link=false}).fg)==c[key],group)
        for bit,modifier in ipairs(modifiers) do
          if math.floor(data[i+4]/2^(bit-1))%2==1 then
            local hl=vim.api.nvim_get_hl(0,{name='@lsp.typemod.'..kind..'.'..modifier..'.typescript',link=false})
            if hl.fg then assert(hex(hl.fg)==c[key],kind..'.'..modifier) end
          end
        end
        token_checks=token_checks+1
      end
    end
    if style=='yukiyo' and transparent then
      for _,server in ipairs(result.lsp) do
        for _,client in ipairs(server.clients or {}) do
          for group,color in pairs(client.colors or {}) do
            local kind=group:match('^@lsp%.type%.([^.]+)%.')
            if role[kind] then assert(color==c[role[kind]],group..' actual token color mismatch') end
          end
        end
      end
    end
  end
end
print('PASS: 164 real parser runs, 36 TypeScript capture checks, 4 surface profiles, '..token_checks..' real vtsls token-to-theme mappings, and attached LSP colors.')

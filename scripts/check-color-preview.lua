-- Behavioral checks for the design preview, separate from theme verification.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local original_normal = vim.api.nvim_get_hl(0,{name='Normal',link=false})
local original_name = vim.g.colors_name
local preview = dofile(root..'/scripts/color-preview.lua')
-- Inspect explicit namespace attributes; link=false can merge the StatusLine fallback for TabLine.
local function hl(name) return vim.api.nvim_get_hl(preview.ns,{name=name}) end
local function hex(value) return value and string.format('#%06x',value) or nil end
local function role(name) return hl('ShimaenagaPreview'..name) end
local function press(key)
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(preview.buf,'n')) do
    if vim.keycode(map.lhs)==vim.keycode(key) then assert(map.callback)(); return end
  end
  error('Missing preview key: '..key)
end
local function luminance(color)
  local channels = {}
  for i=2,6,2 do
    local v=tonumber(color:sub(i,i+1),16)/255
    channels[#channels+1]=v<=0.04045 and v/12.92 or ((v+0.055)/1.055)^2.4
  end
  return channels[1]*0.2126+channels[2]*0.7152+channels[3]*0.0722
end
local function contrast(a,b)
  local x,y=luminance(a),luminance(b)
  return (math.max(x,y)+0.05)/(math.min(x,y)+0.05)
end
local expected={
  yukiyo={comment='#7d8f92',selection='#132c44',search='#322c13',diff_add='#191f18',diff_change='#0d1e2f',diff_delete='#24141e',diff_text='#142f48',border='#3f484f'},
  ryuhyo={comment='#657488',selection='#c0d6ed',search='#dad6c7',diff_add='#e2e7e0',diff_change='#d8e6f5',diff_delete='#efdbe3',diff_text='#bbd3eb',border='#b8c0cb'},
}
local legacy_accents={purple="#6663cb",blue="#166eb7",cyan="#088179",green="#657200",orange="#b54c00",magenta="#c52e7c",yellow="#876804",red="#c60217"}
local revised_accents={purple='#5146c7',blue='#005cad',cyan='#00756b',green='#526700',orange='#a63f00',magenta='#b51070',yellow='#785800',red='#b80018'}
local function saturation(color)
  local r,g,b=tonumber(color:sub(2,3),16)/255,tonumber(color:sub(4,5),16)/255,tonumber(color:sub(6,7),16)/255
  local low,high=math.min(r,g,b),math.max(r,g,b)
  if low==high then return 0 end
  return (high-low)/(1-math.abs(high+low-1))
end
assert(#preview.pages==11)
assert(preview.state.style=='yukiyo' and preview.state.transparent)
assert(preview.state.yukiyo_background==2)
assert(preview.state.background=='soft')
preview.state.background='original' -- Check the reference palette independently of the chosen default.
assert(vim.api.nvim_get_hl_ns({winid=preview.win})==preview.ns)
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  local c=preview.colors(style,'original')
  for _,name in ipairs({'purple','blue','cyan','green','orange','yellow','red','magenta'}) do
    local original=preview.anchors[style][name]
    if style=='yukiyo' then
      assert(c[name]==original,style..': changed accent '..name)
    else
      assert(c[name]==revised_accents[name],style..': unexpected accent '..name)
      assert(luminance(c[name])<luminance(legacy_accents[name]),name..': not deeper')
      assert(saturation(c[name])+1e-9>=saturation(legacy_accents[name]),name..': reduced saturation')
      assert(contrast(c[name],c.bg)>contrast(legacy_accents[name],c.bg),name..': contrast did not improve')
    end
  end
  for name,value in pairs(expected[style]) do assert(c[name]==value,style..': '..name) end
  assert(contrast(c.comment,c.bg)>=4.5)
  assert(contrast(c.comment,c.bg)<contrast(c.fg,c.bg))
  for _,transparent in ipairs({true,false}) do
    preview.state.style,preview.state.transparent=style,transparent
    for page=1,#preview.pages do
      preview.state.page=page
      preview.render()
      local lines=vim.api.nvim_buf_get_lines(preview.buf,0,-1,false)
      assert(lines[1]:find(style,1,true) and lines[1]:find(preview.pages[page].name,1,true))
      for _,line in ipairs(lines) do assert(not line:find('{{%w+|'),'Unresolved role markup') end
      for _,mark in ipairs(vim.api.nvim_buf_get_extmarks(preview.buf,preview.ns,0,-1,{details=true})) do
        local row,col,details=mark[2],mark[3],mark[4]
        assert(row<#lines and col>=0 and details.end_col<=#lines[row+1])
        assert(next(hl(details.hl_group))~=nil)
      end
      assert(not vim.bo[preview.buf].modified and not vim.bo[preview.buf].modifiable)
      assert(hex(hl('Normal').bg)==(not transparent and c.bg or nil))
      assert(hex(hl('NormalNC').bg)==(not transparent and c.bg or nil))
      assert(hex(hl('Pmenu').bg)==(not transparent and (c.bg_menu or c.bg_dark) or nil))
      assert(hex(hl('NormalFloat').bg)==(not transparent and (c.bg_menu or c.bg_dark) or nil))
      assert(hex(role('Float').bg)==(not transparent and (c.bg_menu or c.bg_dark) or nil))
      for _,name in ipairs({'TabLine','TabLineFill','TabLineSel','WinBar','WinBarNC','LineNr','SignColumn','FloatBorder'}) do
        local bg=hl(name).bg
        if transparent then assert(bg==nil,name..' unexpectedly opaque') else assert(bg~=nil,name..' missing opaque background') end
      end
      for name,color in pairs({Keyword=c.purple,Function=c.blue,Type=c.cyan,Text=c.fg,Constant=c.orange,String=c.green,Operator=c.magenta,Punctuation=c.fg_dark,Bracket=c.bracket,Comment=c.comment,Error=c.red,Warn=c.yellow}) do
        assert(hex(role(name).fg)==color,name..' role mismatch')
      end
      assert(role('Comment').italic and not role('Keyword').italic)
      assert(not role('Text').bold and not role('Type').bold and not role('Function').bold)
      assert(role('Heading').bold and role('Link').underline and role('Deprecated').strikethrough)
      assert(c.bracket~=c.orange and c.bracket~=c.red and saturation(c.bracket)<saturation(c.orange))
      if page==2 then
        assert(table.concat(lines,'\n'):find('type BirdProfile = {',1,true))
        local count=0
        for _,mark in ipairs(vim.api.nvim_buf_get_extmarks(preview.buf,preview.ns,0,-1,{details=true})) do
          if mark[4].hl_group=='ShimaenagaPreviewBracket' then
            assert(mark[4].priority==210)
            count=count+1
          end
        end
        assert(count>=6,'TypeScript brackets not highlighted')
      end
      assert(hex(hl('StatusLine').bg)==c.bg_dark and hex(hl('StatusLineNC').bg)==c.bg_dark)
      assert(hex(role('Selected').bg)==c.selection)
      assert(hex(hl('PmenuSel').bg)==c.selection)
      assert(hex(hl('Search').bg)==c.search)
      assert(hex(hl('CurSearch').bg)==c.yellow and hex(hl('CurSearch').fg)==c.bg)
      assert(hex(role('Added').bg)==c.diff_add and hex(role('Deleted').bg)==c.diff_delete)
      assert(hex(role('Changed').bg)==c.diff_change and hex(role('DiffText').bg)==c.diff_text)
    end
  end
end
-- Exercise the actual buffer-local callbacks, including wraparound and reload.
preview.state.style,preview.state.transparent,preview.state.page='yukiyo',true,1
preview.render()
press('<Tab>');assert(preview.state.style=='ryuhyo')
press('t');assert(not preview.state.transparent and hl('Normal').bg~=nil)
local original_light=hl('Normal').bg
press('b');assert(preview.state.background=='soft' and hex(hl('Normal').bg)=='#e9eef5')
assert(hex(hl('NormalFloat').bg)=='#dfe5ee' and hex(hl('CursorLine').bg)=='#d5deeb')
assert(hex(role('Function').fg)==revised_accents.blue)
assert(hl('Normal').bg~=original_light)
for page=1,#preview.pages do
  preview.state.page=page
  preview.render()
  local c=preview.colors('ryuhyo','soft')
  assert(hex(role('Selected').bg)==c.selection and hex(role('DiffText').bg)==c.diff_text)
end
press('t');assert(hl('Normal').bg==nil and hl('NormalFloat').bg==nil)
press('t');assert(hex(hl('Normal').bg)=='#e9eef5')
press('b');assert(preview.state.background=='original' and hl('Normal').bg==original_light)
preview.state.page=1
press('[');assert(preview.state.page==#preview.pages)
press(']');assert(preview.state.page==1)
press('<Tab>');press('t')
assert(preview.state.style=='yukiyo' and preview.state.transparent and hl('Normal').bg==nil)
-- Cycle all three dark backgrounds using the real preview mapping.
preview.state.yukiyo_background=3
preview.render()
for index,background in ipairs({'#090f1c','#070c17','#050910'}) do
  press('b')
  assert(preview.state.yukiyo_background==index)
  local c=preview.colors('yukiyo',preview.state.background,index)
  assert(c.bg==background and c.bg_dark=='#111b2f')
  assert(hex(role('Selected').bg)==c.selection)
end
assert(vim.deep_equal(original_normal,vim.api.nvim_get_hl(0,{name='Normal',link=false})))
assert(vim.g.colors_name==original_name)
assert(package.loaded['shimaenaga']==nil and package.loaded['shimaenaga.theme']==nil)
print('PASS: 11 pages × 4 states; palette, contrast, role colors, transparent surfaces, state backgrounds, key callbacks, and global highlight isolation.')

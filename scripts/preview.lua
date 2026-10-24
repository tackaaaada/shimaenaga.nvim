local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.cmd('syntax on')
local style = 'yukiyo'
local function apply()
  vim.cmd.colorscheme('shimaenaga-'..style)
  vim.o.statusline = ' Shimaenaga / '..style..' | Tab: 雪夜 / 流氷 | :q: close %=%l:%c '
end
vim.api.nvim_buf_set_lines(0,0,-1,false,{
  '-- Shimaenaga: 雪夜 Yukiyo / 流氷 Ryuhyo',
  '-- Tab: switch variants. :q: close.',
  '',
  'local bird = { name = "シマエナガ", wings = 2, fluffy = true }',
  '',
  'local function greet(name)',
  '  if name ~= nil then',
  '    return "Hello, " .. name',
  '  end',
  'end',
  '',
  'print(greet(bird.name))',
  '-- TODO: enjoy the snowy forest',
  '',
  'Keywords   Functions   Strings   Numbers   Types   Parameters',
  '',
  'Error      Warning     Info      Hint',
  '',
  'Select text with v to preview selection.',
})
vim.bo.filetype = 'lua'
local ns = vim.api.nvim_create_namespace('shimaenaga-preview')
for _, row in ipairs({{14, {'Keyword','Function','String','Number','Type','@variable.parameter'}}, {16, {'DiagnosticError','DiagnosticWarn','DiagnosticInfo','DiagnosticHint'}}}) do
  local line = vim.api.nvim_buf_get_lines(0,row[1],row[1]+1,false)[1]
  local index = 1
  for start, word in line:gmatch('()(%S+)') do
    vim.api.nvim_buf_add_highlight(0,ns,row[2][index],row[1],start-1,start-1+#word)
    index = index+1
  end
end
vim.bo.buftype = 'nofile'
vim.bo.swapfile = false
vim.bo.modified = false
vim.keymap.set('n','<Tab>',function()
  style = style == 'yukiyo' and 'ryuhyo' or 'yukiyo'
  apply()
end)
apply()

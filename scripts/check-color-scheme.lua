-- Contracts for pure color assembly and background replacement.
local root=vim.fn.fnamemodify(debug.getinfo(1,'S').source:sub(2),':p:h:h')
vim.opt.rtp:prepend(root)
local scheme=require('shimaenaga.color_scheme')
local palette=require('shimaenaga.palette')
for _,style in ipairs({'yukiyo','ryuhyo'}) do
  for _,transparent in ipairs({false,true}) do
    for _,surface in ipairs({'auto','normal','dark','transparent'}) do
      local config={transparent=transparent,styles={floats=surface,sidebars=surface}}
      local original_palette,original_config=vim.deepcopy(palette[style]),vim.deepcopy(config)
      local c=scheme.build(palette[style],style,config)
      assert(vim.deep_equal(original_palette,palette[style]),'builder mutated input palette')
      assert(vim.deep_equal(original_config,config),'builder mutated options')
      c.error='#abcdef' -- Unrelated user overrides survive a background-only change.
      c.custom={fg='#123456'}
      local original=vim.deepcopy(c)
      local next_colors=scheme.with_background(c,'#090f1c')
      assert(vim.deep_equal(original,c),'background replacement mutated its source')
      assert(next_colors.bg=='#090f1c' and next_colors.base03=='#090f1c')
      assert(next_colors.error=='#abcdef' and next_colors.custom.fg=='#123456')
      assert(next_colors.bg_dark==c.bg_dark and next_colors.bg_menu==c.bg_menu)
      assert(next_colors.blue0==next_colors.blue600 and next_colors.blue7==next_colors.blue700)
      if surface=='normal' then
        assert(next_colors.bg_float==next_colors.bg and next_colors.bg_sidebar==next_colors.bg)
      elseif surface=='transparent' or surface=='auto' and transparent then
        assert(next_colors.bg_float=='NONE' and next_colors.bg_sidebar=='NONE')
      else
        assert(next_colors.bg_float==(c.bg_menu or c.bg_dark) and next_colors.bg_sidebar==c.bg_dark)
      end
      next_colors.diff.add='#fedcba';next_colors.custom.fg='#654321'
      assert(c.diff.add==original.diff.add and c.custom.fg=='#123456','returned tables share mutable children')
    end
  end
end
local assign=require('shimaenaga.highlights.writer').for_groups
local groups={};local attrs={fg='#123456'}
assign(groups)('First Second',attrs)
groups.First.fg='#abcdef'
assert(groups.Second.fg=='#123456' and attrs.fg=='#123456','highlight rules share mutable attributes')
print('PASS: 16 pure color configurations, input/child-table isolation, override preservation, surface rules, and independent highlight attributes.')

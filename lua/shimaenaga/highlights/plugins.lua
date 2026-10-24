-- Final plugins roles; input colors/options are never modified.
local M = {}
function M.apply(groups, c, opts)
  local surface = opts.transparent and c.none or c.bg
  -- Existing plugin definitions retain their names and enable/disable behavior.
  local kinds={Variable='fg',Property='fg',Field='fg',Reference='fg',Constant='orange',Value='orange',EnumMember='orange',Function='blue',Method='blue',Constructor='cyan',Class='cyan',Interface='cyan',Struct='cyan',Enum='cyan',TypeParameter='cyan',Module='cyan',Keyword='purple',Operator='magenta',Snippet='purple'}
  for suffix,key in pairs(kinds) do
    for _,prefix in ipairs({'BlinkCmpKind','CmpItemKind'}) do
      local name=prefix..suffix
      if groups[name] then groups[name]={fg=c[key]} end
    end
  end
  local replacements={
    BlinkCmpMenu={fg=c.fg,bg=c.bg_float},BlinkCmpMenuBorder={fg=c.border,bg=c.bg_float},
    BlinkCmpMenuSelection={fg=c.fg,bg=c.selection},BlinkCmpDoc={fg=c.fg,bg=c.bg_float},
    BlinkCmpDocBorder={fg=c.border,bg=c.bg_float},BlinkCmpGhostText={fg=c.comment},
    BlinkCmpSignatureHelp={fg=c.fg,bg=c.bg_float},BlinkCmpSignatureHelpBorder={fg=c.border,bg=c.bg_float},
    BlinkCmpSignatureHelpActiveParameter={fg=c.fg,bold=true},
    SnacksPickerNormal={fg=c.fg,bg=c.bg_float},SnacksPickerBorder={fg=c.border,bg=c.bg_float},
    SnacksPickerListCursorLine={bg=c.selection},SnacksNotifierNormal={fg=c.fg,bg=c.bg_float},
    BufferLineFill={bg=surface},BufferLineBackground={fg=c.fg_dark,bg=surface},
    BufferLineBufferSelected={fg=c.blue,bg=surface,bold=true},
  }
  for name,hl in pairs(replacements) do
    -- Menu groups omitted by the upstream integration still belong to blink/snacks.
    if groups[name] or (name:match('^Blink') and groups.BlinkCmpMenu) or (name:match('^Snacks') and groups.SnacksPickerBorder) or (name:match('^BufferLine') and groups.BufferLineIndicatorSelected) then groups[name]=hl end
  end
  return groups
end
return M

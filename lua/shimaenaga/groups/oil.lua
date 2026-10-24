-- Oil windows have their own surface; entry highlights never borrow Normal's bg.
local M = {}
function M.get(c, opts)
  return {
    OilNormal={fg=c.fg,bg=c.bg_float}, OilNormalNC={fg=c.fg,bg=c.bg_float},
    OilFloatBorder={fg=c.border,bg=c.bg_float},OilFloatTitle={fg=c.purple,bg=c.bg_float,bold=true},
    OilWinBar={fg=c.fg_dark,bg=c.bg_float},OilCursorLine={bg=c.selection},
    OilDir={fg=c.blue},OilDirIcon={fg=c.blue},OilFile={fg=c.fg},OilLink={fg=c.fg},
    OilHidden={fg=c.comment},OilEmpty={fg=c.comment},OilLinkTarget={fg=c.comment},OilVtext={fg=c.comment},
    OilOrphanLink={fg=c.red},OilOrphanLinkTarget={fg=c.red},OilDelete={fg=c.red},OilPurge={fg=c.red},
    OilCreate={fg=c.green},OilRestore={fg=c.green},OilChange={fg=c.blue},OilMove={fg=c.blue},OilCopy={fg=c.blue},
    OilPreviewCursor='Visual',
  }
end
return M

-- Isolated color-design preview. No theme loader, parser, or plugin is required.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local anchors = dofile(root .. '/lua/shimaenaga/palette.lua')
local ns = vim.api.nvim_create_namespace('shimaenaga-color-design')
local state = { style = 'yukiyo', transparent = true, page = 1, background = 'soft', yukiyo_background = 2 }
local yukiyo_backgrounds = {'#090f1c', '#070c17', '#050910'}
local design = dofile(root .. '/lua/shimaenaga/design.lua')
local function colors(style, background, yukiyo_background)
  local palette = vim.deepcopy(assert(anchors[style]))
  if style == 'yukiyo' and yukiyo_background then
    palette.bg = assert(yukiyo_backgrounds[yukiyo_background])
  end
  if style == 'ryuhyo' and background == 'original' then
    palette.bg, palette.bg_dark, palette.bg_highlight = '#f6f9ff', '#e9eef7', '#e2e9f6'
  end
  return design.make(palette)
end

-- Markup describes intended roles; this is not syntax-token detection.
local pages = {
  { name = 'Palette / roles', lines = {
    '{{Heading|静かな基本色に、役割のある少数のアクセント}}', '',
    '{{Keyword|keyword / return / if}}     制御構造・修飾子',
    '{{Function|function / method / builtin()}}     関数・組み込み関数',
    '{{Type|Type / Class / Interface / Namespace}}     型・名前空間',
    '{{String|"string" / character}}     文字列・文字',
    '{{Constant|42 / true / null / nil / Enum.Value}}     値・定数',
    '{{Text|variable / parameter / property / self / this}}     基本文字色',
    '{{Operator|+ - * / = == => &&}}     演算子',
    '{{Special|escape / attribute / decorator / macro}}     特殊要素',
    '{{Bracket|( ) [ ] { }}}     カエデ系の括弧',
    '{{Punctuation|, . : ;}}     控えめな区切り',
    '{{Comment|コメント：本文より控えめ、ただし読める明るさ。italic}}', '',
    '{{Error|ERROR / failed / deleted}}    {{Warn|WARNING / partial / TODO}}',
    '{{Info|INFO / changed / running}}    {{Hint|HINT}}    {{Success|SUCCESS / added}}',
    '{{Muted|skipped / inactive}}    {{Deprecated|deprecated}}', '',
    '雪夜は元のアクセント、流氷は濃さ・彩度を調整した採用色です。',
    'コメント色と派生背景はテーマ本体と共通です。',
  } },
  { name = 'TypeScript / TSX', lines = {
    '{{Comment|// Explicit role colors, including builtins and parameters}}',
    '{{Keyword|type}} {{Type|BirdProfile}} {{Operator|=}} {{Punctuation|{}}',
    '  name{{Punctuation|:}} {{Type|string}}{{Punctuation|;}}',
    '  wings{{Punctuation|:}} {{Type|number}}{{Punctuation|;}}',
    '{{Punctuation|};}}', '',
    '{{Keyword|interface}} {{Type|Bird}} {{Punctuation|{}} name{{Punctuation|:}} {{Type|string}} {{Punctuation|} }}',
    '{{Keyword|function}} {{Function|greet}}{{Punctuation|(}}bird{{Punctuation|:}} {{Type|Bird}}{{Punctuation|):}} {{Type|string}} {{Punctuation|{}}',
    '  {{Keyword|const}} count {{Operator|=}} {{Constant|2}}{{Punctuation|;}}',
    '  {{Keyword|if}} {{Punctuation|(}}bird.name {{Operator|!==}} {{Constant|null}}{{Punctuation|)}} {{Punctuation|{}}',
    '    {{Function|String}}{{Punctuation|(}}count{{Punctuation|);}} {{Comment|// builtin function uses function blue}}',
    '    {{Keyword|return}} {{String|"Hello, "}} {{Operator|+}} bird.name{{Punctuation|;}}',
    '  {{Punctuation|} }}',
    '  {{Keyword|return}} {{String|"Snowy forest"}}{{Punctuation|;}}',
    '{{Punctuation|} }}', '',
    '{{Keyword|const}} card {{Operator|=}} {{Punctuation|<}}{{Type|BirdCard}} name{{Operator|=}}{{String|"shimaenaga"}} {{Punctuation|/>;}}',
    '{{Special|@memoized}}',
    '{{Keyword|class}} {{Type|Nest}} {{Punctuation|{}} {{Function|size}}{{Punctuation|() {}} {{Keyword|return}} {{Text|this}}.birds.length {{Punctuation|} } }}',
  } },
  { name = 'Python', lines = {
    '{{Comment|# Variables, parameters, properties, and self share the base foreground}}',
    '{{Keyword|from}} {{Type|dataclasses}} {{Keyword|import}} {{Function|dataclass}}',
    '{{Special|@dataclass}}',
    '{{Keyword|class}} {{Type|Bird}}{{Punctuation|:}}',
    '    name{{Punctuation|:}} {{Type|str}} {{Operator|=}} {{String|"shimaenaga"}}',
    '    wings{{Punctuation|:}} {{Type|int}} {{Operator|=}} {{Constant|2}}', '',
    '    {{Keyword|def}} {{Function|greet}}{{Punctuation|(}}self, name{{Punctuation|:}} {{Type|str}}{{Punctuation|)}} {{Operator|->}} {{Type|str}}{{Punctuation|:}}',
    '        {{Keyword|if}} name {{Keyword|is not}} {{Constant|None}}{{Punctuation|:}}',
    '            {{Function|print}}{{Punctuation|(}}{{Function|len}}{{Punctuation|(}}name{{Punctuation|))}}',
    '            {{Keyword|return}} {{String|"Hello, "}} {{Operator|+}} name',
    '        {{Keyword|return}} {{String|"Snow"}}',
  } },
  { name = 'Ruby', lines = {
    '{{Comment|# Class references are types; value constants are orange}}',
    '{{Keyword|module}} {{Type|Hokkaido}}',
    '  {{Constant|MAX_WINGS}} {{Operator|=}} {{Constant|2}}',
    '  {{Keyword|class}} {{Type|Bird}}',
    '    {{Keyword|def}} {{Function|greet}}{{Punctuation|(}}name{{Punctuation|)}}',
    '      {{Function|puts}} {{String|"Hello, "}} {{Operator|+}} name',
    '      {{Keyword|return}} {{Constant|nil}} {{Keyword|if}} name {{Operator|==}} {{String|""}}',
    '      self.name',
    '    {{Keyword|end}}',
    '  {{Keyword|end}}',
    '{{Keyword|end}}',
  } },
  { name = 'Rust', lines = {
    '{{Comment|// Types and traits share cyan; generics do not add a new accent}}',
    '{{Keyword|struct}} {{Type|Bird}} {{Punctuation|{}} name{{Punctuation|:}} {{Type|String}} {{Punctuation|} }}',
    '{{Keyword|fn}} {{Function|greet}}{{Punctuation|(}}bird{{Punctuation|:}} {{Operator|&}}{{Type|Bird}}{{Punctuation|)}} {{Operator|->}} {{Type|String}} {{Punctuation|{}}',
    '    {{Keyword|let}} wings {{Operator|=}} {{Constant|2}}{{Punctuation|;}}',
    '    {{Keyword|if}} wings {{Operator|>}} {{Constant|0}} {{Punctuation|{}}',
    '        {{Special|format!}}{{Punctuation|(}}{{String|"Hello, {}"}}, bird.name{{Punctuation|)}}',
    '    {{Punctuation|} }} {{Keyword|else}} {{Punctuation|{}} {{Type|String}}{{Punctuation|::}}{{Function|new}}{{Punctuation|() } }}',
    '{{Punctuation|} }}', '',
    '{{Keyword|impl}}{{Punctuation|<}}{{Type|T}}{{Punctuation|:}} {{Type|Display}}{{Punctuation|>}} {{Type|Nest}}{{Punctuation|<}}{{Type|T}}{{Punctuation|> { } }}',
  } },
  { name = 'Go', lines = {
    '{{Comment|// Builtin functions keep the function color; nil is a value}}',
    '{{Keyword|package}} {{Type|forest}}',
    '{{Keyword|type}} {{Type|Bird}} {{Keyword|struct}} {{Punctuation|{}} Name {{Type|string}} {{Punctuation|} }}',
    '{{Keyword|func}} {{Function|greet}}{{Punctuation|(}}bird {{Type|Bird}}{{Punctuation|)}} {{Type|string}} {{Punctuation|{}}',
    '    wings {{Operator|:=}} {{Constant|2}}',
    '    {{Function|println}}{{Punctuation|(}}wings, {{Function|len}}{{Punctuation|(}}bird.Name{{Punctuation|))}}',
    '    {{Keyword|return}} {{String|"Hello, "}} {{Operator|+}} bird.Name',
    '{{Punctuation|} }}',
    '{{Keyword|var}} flock {{Punctuation|[]}}{{Type|Bird}} {{Operator|=}} {{Constant|nil}}',
  } },
  { name = 'Lua', lines = {
    '{{Comment|-- Strings and values differ; arguments remain quiet}}',
    '{{Keyword|local}} bird {{Operator|=}} {{Punctuation|{}} name {{Operator|=}} {{String|"シマエナガ"}}, wings {{Operator|=}} {{Constant|2}}, fluffy {{Operator|=}} {{Constant|true}} {{Punctuation|} }}',
    '{{Keyword|local function}} {{Function|greet}}{{Punctuation|(}}name{{Punctuation|)}}',
    '  {{Keyword|if}} name {{Operator|~=}} {{Constant|nil}} {{Keyword|then}}',
    '    {{Keyword|return}} {{String|"Hello, "}} {{Operator|..}} name',
    '  {{Keyword|end}}',
    '  {{Keyword|return}} {{String|"Snow"}}',
    '{{Keyword|end}}',
    '{{Function|print}}{{Punctuation|(}}{{Function|greet}}{{Punctuation|(}}bird.name{{Punctuation|))}}',
    '{{String|"snow}}{{Special|\\n}}{{String|forest"}}',
  } },
  { name = 'Lean', lines = {
    '{{Comment|-- Lean role illustration; no Lean server is started}}',
    '{{Keyword|namespace}} {{Type|Forest}}',
    '{{Keyword|structure}} {{Type|Bird}} {{Keyword|where}}',
    '  name {{Punctuation|:}} {{Type|String}}',
    '  wings {{Punctuation|:}} {{Type|Nat}}',
    '{{Keyword|def}} {{Function|greet}} {{Punctuation|(}}bird {{Punctuation|:}} {{Type|Bird}}{{Punctuation|)}} {{Punctuation|:}} {{Type|String}} {{Operator|:=}} {{String|"Hello, "}} {{Operator|++}} bird.name',
    '{{Keyword|theorem}} {{Function|wings_nonnegative}} {{Punctuation|(}}n {{Punctuation|:}} {{Type|Nat}}{{Punctuation|)}} {{Punctuation|:}} {{Constant|0}} {{Operator|≤}} n {{Operator|:=}} {{Keyword|by}}',
    '  {{Function|exact}} {{Type|Nat}}.{{Function|zero_le}} n',
    '{{Keyword|end}} {{Type|Forest}}', '',
    '{{Heading|infoview / widget 配色の見本}}',
    '{{Float|n : Nat}}',
    '{{Hint|⊢ 0 ≤ n}}',
    '{{Selected| selected hypothesis / widget }}',
    '{{Error|LSP disconnected}}    {{Warn|paused / imports out of date}}',
  } },
  { name = 'SuperCollider', lines = {
    '{{Comment|// SuperCollider role illustration; no audio or sclang is started}}',
    '{{Type|SynthDef}}{{Punctuation|(}}{{Constant|\\shimaenaga}}, {{Punctuation|{}} {{Punctuation||}}freq {{Operator|=}} {{Constant|880}}, amp {{Operator|=}} {{Constant|0.1}} {{Punctuation||}}',
    '    {{Keyword|var}} signal {{Operator|=}} {{Type|SinOsc}}.{{Function|ar}}{{Punctuation|(}}freq{{Punctuation|)}} {{Operator|*}} amp{{Punctuation|;}}',
    '    {{Type|Out}}.{{Function|ar}}{{Punctuation|(}}{{Constant|0}}, signal {{Operator|!}} {{Constant|2}}{{Punctuation|);}}',
    '{{Punctuation|}).}}{{Function|add}}{{Punctuation|;}}', '',
    '{{Heading|post window / evaluation 配色の見本}}',
    '{{Float|a SynthDef}}',
    '{{Info|server running}}',
    '{{Success|compiled successfully}}',
    '{{Error|ERROR: Message not understood}}',
    '{{CurrentSearch| evaluation flash / fade endpoint }}',
  } },
  { name = 'Documents / configuration', lines = {
    '{{Heading|# 北海道の雪景色}}',
    '{{Text|本文と変数は静かな基本色。}} {{Emphasis|文書の強調は文書の意味として扱います。}}',
    '{{Link|https://example.com/forest}}',
    '{{Code| inline code / fenced code surface }}',
    '{{Success|[x] complete}}   {{Warn|[ ] TODO}}', '',
    '{{Comment|# TOML / YAML / JSON: representative key and value roles}}',
    'name {{Operator|=}} {{String|"shimaenaga"}}',
    'wings {{Operator|=}} {{Constant|2}}',
    'fluffy {{Operator|=}} {{Constant|true}}',
    '{{Punctuation|{}} {{Text|"name"}}{{Punctuation|:}} {{String|"shimaenaga"}}, {{Text|"nest"}}{{Punctuation|:}} {{Constant|null}} {{Punctuation|} }}', '',
    '{{Comment|-- SQL}}',
    '{{Keyword|SELECT}} name {{Keyword|FROM}} {{Type|birds}} {{Keyword|WHERE}} wings {{Operator|=}} {{Constant|2}}{{Punctuation|;}}',
  } },
  { name = 'UI / operation states', lines = {
    '{{Heading|UI 配色の見本 — 実プラグインの画面ではありません}}', '',
    '{{Float| Completion / sidebar / float: normal surface }}',
    '{{Selected| > greet(name)                  function }}',
    '{{Float|   Bird                         type     }}',
    '{{Comment| ghost text / documentation comment }}', '',
    'Search: {{Search| other match }}   {{CurrentSearch| current match }}',
    'Selection: {{Selected| selected text }}',
    '{{Added| + added line / successful result }}',
    '{{Changed| ~ changed line }}  {{DiffText| changed text }}',
    '{{Deleted| - deleted line / failed result }}', '',
    '{{Error|ERROR}}  {{Warn|WARNING}}  {{Info|INFO}}  {{Hint|HINT}}',
    '{{DiagnosticError|error underline}}   {{DiagnosticWarn|warning underline}}',
    '{{Success|PASS}}  {{Error|FAIL}}  {{Info|RUNNING}}  {{Muted|SKIPPED}}  {{Warn|PARTIAL}}', '',
    '{{ModeNormal| NORMAL }} {{ModeInsert| INSERT }} {{ModeVisual| VISUAL }} {{ModeCommand| COMMAND }} {{ModeReplace| REPLACE }}',
    '{{ActiveTab| active.lua }} {{Muted| inactive.lua }}  {{Text|status / tab surfaces are transparent}}',
    '{{Border|────────────────────────────────────────────────────────────}}',
  } },
}

local buf = vim.api.nvim_create_buf(false, true)
local win = vim.api.nvim_get_current_win()
vim.api.nvim_win_set_buf(win, buf)
vim.api.nvim_win_set_hl_ns(win, ns)
vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = 'nofile', 'wipe', false
vim.bo[buf].filetype = 'shimaenaga-color-preview'
vim.wo[win].number, vim.wo[win].relativenumber = true, false
vim.wo[win].cursorline, vim.wo[win].wrap = true, false
vim.wo[win].signcolumn, vim.wo[win].foldcolumn = 'no', '0'
vim.o.termguicolors, vim.o.laststatus = true, 2

local function render()
  local c = colors(state.style, state.background, state.yukiyo_background)
  local surface = state.transparent and 'NONE' or c.bg
  local float = state.transparent and 'NONE' or (c.bg_menu or c.bg_dark)
  local groups = {
    Normal={fg=c.fg,bg=surface}, NormalNC={fg=c.fg,bg=surface}, EndOfBuffer={fg=c.fg_dark,bg=surface},
    LineNr={fg=c.fg_dark,bg=surface}, CursorLineNr={fg=c.yellow,bg=surface}, CursorLine={bg=c.bg_highlight},
    SignColumn={bg=surface}, NormalFloat={fg=c.fg,bg=float}, FloatBorder={fg=c.border,bg=float},
    StatusLine={fg=c.fg,bg=c.bg_dark}, StatusLineNC={fg=c.fg_dark,bg=c.bg_dark},
    TabLine={fg=c.fg_dark,bg=surface}, TabLineFill={bg=surface}, TabLineSel={fg=c.blue,bg=surface,bold=true},
    WinBar={fg=c.fg,bg=surface}, WinBarNC={fg=c.fg_dark,bg=surface},
    Pmenu={fg=c.fg,bg=float}, PmenuSel={fg=c.fg,bg=c.selection},
    Visual={fg=c.fg,bg=c.selection}, Search={fg=c.fg,bg=c.search},
    CurSearch={fg=c.bg,bg=c.yellow,bold=true}, IncSearch={fg=c.bg,bg=c.yellow,bold=true},
  }
  for name, attrs in pairs(groups) do vim.api.nvim_set_hl(ns, name, attrs) end
  local roles = {
    Text={fg=c.fg}, Muted={fg=c.fg_dark}, Keyword={fg=c.purple}, Function={fg=c.blue},
    Type={fg=c.cyan}, String={fg=c.green}, Constant={fg=c.orange},
    Operator={fg=c.operator}, Special={fg=c.magenta}, Punctuation={fg=c.fg_dark}, Bracket={fg=c.bracket},
    Comment={fg=c.comment,italic=true}, Heading={fg=c.purple,bold=true},
    Link={fg=c.blue,underline=true}, Emphasis={fg=c.fg,italic=true}, Deprecated={fg=c.fg_dark,strikethrough=true},
    Error={fg=c.red}, Warn={fg=c.yellow}, Info={fg=c.blue}, Hint={fg=c.cyan}, Success={fg=c.green},
    Float={fg=c.fg,bg=float}, Selected=groups.Visual, Search=groups.Search, CurrentSearch=groups.CurSearch,
    Added={fg=c.fg,bg=c.diff_add}, Changed={fg=c.fg,bg=c.diff_change}, Deleted={fg=c.fg,bg=c.diff_delete},
    DiffText={fg=c.fg,bg=c.diff_text}, Code={fg=c.fg,bg=c.bg_highlight},
    DiagnosticError={fg=c.red,sp=c.red,undercurl=true}, DiagnosticWarn={fg=c.yellow,sp=c.yellow,undercurl=true},
    ActiveTab={fg=c.blue,bold=true}, Border={fg=c.border},
    ModeNormal={fg=c.bg,bg=c.blue,bold=true},ModeInsert={fg=c.bg,bg=c.green,bold=true},
    ModeVisual={fg=c.bg,bg=c.magenta,bold=true},ModeCommand={fg=c.bg,bg=c.yellow,bold=true},
    ModeReplace={fg=c.bg,bg=c.red,bold=true},StatusBranch={fg=c.bg,bg=c.fg_dark},
    StatusContent={fg=c.fg,bg=c.bg_dark},StatusArrowA={fg=c.blue,bg=c.fg_dark},
    StatusArrowB={fg=c.fg_dark,bg=c.bg_dark},
  }
  for name, attrs in pairs(roles) do vim.api.nvim_set_hl(ns, 'ShimaenagaPreview'..name, attrs) end
  local page = pages[state.page]
  local lines = {
    ('Shimaenaga / %s / %s / %d:%d %s'):format(state.style, state.transparent and 'transparent' or 'opaque', state.page, #pages, page.name),
    'Tab: 雪夜/流氷   t: 透過/非透過   b: 背景候補   [ / ]: サンプル   :q!: 終了',
    '役割を明示して着色した配色見本です。Treesitter / LSP / 実プラグインの検証ではありません。',
    '',
  }
  local spans = {}
  for _, source in ipairs(page.lines) do
    local text, from = '', 1
    while true do
      local first, last, role, content = source:find('{{(%w+)|(.-)}}', from)
      if not first then text = text .. source:sub(from); break end
      assert(roles[role], 'Unknown preview role: '..role)
      text = text .. source:sub(from, first - 1)
      spans[#spans+1] = {#lines, #text, #text+#content, 'ShimaenagaPreview'..role}
      if role == 'Punctuation' then
        local brackets = {['(']=true,[')']=true,['[']=true,[']']=true,['{']=true,['}']=true}
        for offset, character in content:gmatch('()(.)') do
          if brackets[character] then
            spans[#spans+1] = {#lines, #text+offset-1, #text+offset, 'ShimaenagaPreviewBracket'}
          end
        end
      end
      text, from = text .. content, last + 1
    end
    lines[#lines+1] = text
  end
  lines[#lines+1] = ''
  lines[#lines+1] = ('comment %s | fg %s | bg %s | selection %s'):format(c.comment,c.fg,c.bg,c.selection)
  if state.style == 'yukiyo' then
    lines[#lines+1] = '雪夜の背景 '..state.yukiyo_background..'/3: '..c.bg..' / bで切り替え。tで非透過にすると比較できます。'
  else
    lines[#lines+1] = '背景: '..state.background..' / 通常面の違いは t で非透過にすると確認できます。'
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf,0,-1,false,lines)
  vim.api.nvim_buf_clear_namespace(buf,ns,0,-1)
  for _, span in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(buf,ns,span[1],span[2],{end_col=span[3],hl_group=span[4],priority=span[4]=='ShimaenagaPreviewBracket' and 210 or 200})
  end
  vim.bo[buf].modifiable, vim.bo[buf].modified = false, false
  vim.wo[win].statusline = '%#ShimaenagaPreviewModeNormal# NORMAL %#ShimaenagaPreviewStatusArrowA#%#ShimaenagaPreviewStatusBranch# Shimaenaga / '..state.style..' %#ShimaenagaPreviewStatusArrowB#%#ShimaenagaPreviewStatusContent# '..page.name..' %=%l:%c '
end

vim.keymap.set('n','<Tab>',function() state.style=state.style=='yukiyo' and 'ryuhyo' or 'yukiyo'; render() end,{buffer=buf})
vim.keymap.set('n','t',function() state.transparent=not state.transparent; render() end,{buffer=buf})
vim.keymap.set('n','b',function()
  if state.style == 'yukiyo' then
    state.yukiyo_background=state.yukiyo_background%#yukiyo_backgrounds+1
  else
    state.background=state.background=='original' and 'soft' or 'original'
  end
  render()
end,{buffer=buf})
for key, step in pairs({['[']=-1,[']']=1}) do
  vim.keymap.set('n',key,function()
    state.page=(state.page-1+step)%#pages+1
    render()
    vim.api.nvim_win_set_cursor(win,{1,0})
  end,{buffer=buf})
end
render()

-- Returned only for the standalone preview's headless verification.
return {state=state,colors=colors,anchors=anchors,pages=pages,ns=ns,buf=buf,win=win,render=render}

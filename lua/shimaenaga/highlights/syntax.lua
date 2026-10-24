-- Final syntax roles; input colors/options are never modified.
local M = {}
function M.apply(groups, c, opts)
  local set = require('shimaenaga.highlights.writer').for_groups(groups)
  set('Comment @comment @comment.documentation', vim.tbl_extend('force', {fg=c.comment}, opts.styles.comments))
  set('Constant Number Float Boolean @constant @constant.builtin @constant.macro @number @number.float @boolean @lsp.type.enumMember', {fg=c.orange})
  set('String Character @string @character @string.documentation', {fg=c.green})
  set('Identifier @variable @variable.member @property @variable.parameter @variable.parameter.builtin @variable.builtin @lsp.type.parameter @lsp.type.property @lsp.type.variable @lsp.type.selfKeyword', vim.tbl_extend('force',{fg=c.fg},opts.styles.variables))
  set('Function @function @function.call @function.method @function.method.call @function.builtin @lsp.type.function @lsp.type.method', vim.tbl_extend('force', {fg=c.blue}, opts.styles.functions))
  set('Statement Conditional Repeat Label Keyword Exception StorageClass @label @keyword @keyword.function @keyword.return @keyword.conditional @keyword.repeat @keyword.exception @keyword.import @keyword.directive @keyword.directive.define @keyword.storage @keyword.modifier @keyword.type @keyword.coroutine', vim.tbl_extend('force', {fg=c.purple}, opts.styles.keywords))
  set('PreProc Include Define Macro PreCondit Special SpecialChar @punctuation.special @attribute @constant.macro @function.macro @string.escape @lsp.type.decorator @lsp.type.macro @lsp.type.formatSpecifier @lsp.typemod.macro.defaultLibrary', {fg=c.magenta})
  set('Operator @operator @keyword.operator', {fg=c.operator})
  set('Type Structure Typedef @type @type.builtin @type.definition @constructor @module @module.builtin @lsp.type.class @lsp.type.struct @lsp.type.enum @lsp.type.interface @lsp.type.type @lsp.type.typeParameter @lsp.type.namespace @lsp.type.selfTypeKeyword', {fg=c.cyan})
  set('@string.regexp', {fg=c.cyan})
  set('Delimiter @punctuation.delimiter @tag.delimiter', {fg=c.fg_dark})
  set('@punctuation.bracket', {fg=c.bracket})
  set('@tag', {fg=c.cyan})
  set('@tag.attribute', {fg=c.fg})
  -- Modifiers must preserve the underlying role (readonly variables are still variables).
  set('@lsp.mod.readonly @lsp.mod.static @lsp.mod.defaultLibrary', {})
  set('@lsp.typemod.variable.readonly @lsp.typemod.variable.static @lsp.typemod.variable.constant @lsp.typemod.variable.defaultLibrary @lsp.typemod.property.readonly', {fg=c.fg})
  set('@lsp.typemod.type.defaultLibrary @lsp.typemod.typeAlias.defaultLibrary @lsp.typemod.class.defaultLibrary @lsp.typemod.struct.defaultLibrary @lsp.typemod.typeParameter.defaultLibrary', {fg=c.cyan})
  set('@lsp.typemod.enumMember.defaultLibrary', {fg=c.orange})
  set('@lsp.typemod.function.defaultLibrary @lsp.typemod.method.defaultLibrary @lsp.typemod.variable.callable', {fg=c.blue})
  set('@lsp.mod.deprecated DiagnosticDeprecated', {fg=c.fg_dark,strikethrough=true})
  return groups
end
return M

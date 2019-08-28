local m = require 'init'
local coder = require 'coder'
local util = require'util'


-- Removed label 'AssignAssign' in rule statement because the correct matching
-- of varlist depends on a semantic action in rule var

g = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* (!.)^Err_EOF
  toplevelfunc    <-  localopt 'function' NAME^Err_NameFunc '('^Err_LParPList paramlist ')'^Err_RParPList rettypeopt block 'end'^Err_EndFunc
  ]]--added predicate in 'toplevalvar' to label 'exp'
  ..[[
  toplevelvar     <-  localopt decl '='^Err_AssignVar !('import' / 'foreign') exp^Err_ExpVarDec
  toplevelrecord  <-  'record' NAME^Err_NameRecord recordfields^Err_FieldRecord 'end'^Err_EndRecord
  localopt        <-  'local'?
  ]]--added predicate in 'import' to label 'import'
  ..[[
  import          <-  'local' NAME^Err_NameImport '='^Err_AssignImport !'foreign' 'import'^Err_ImportImport ('(' STRINGLIT^Err_StringLParImport ')'^Err_RParImport / STRINGLIT^Err_StringImport)
  foreign         <-  'local' NAME^Err_NameImport '='^Err_AssignImport 'foreign' 'import'^Err_ImportImport  ('(' STRINGLIT^Err_StringLParImport ')'^Err_RParImport / STRINGLIT^Err_StringImport)
  rettypeopt      <-  (':' rettype^Err_TypeFunc)?
  paramlist       <-  (param (',' param^Err_DeclParList)*)?
  param           <-  NAME ':'^Err_ParamSemicolon type^Err_TypeDecl
  decl            <-  NAME (':' type^Err_TypeDecl)?
  decllist        <-  decl (',' decl^Err_DeclParList)*
  simpletype      <-  'nil' / 'boolean' / 'integer' / 'float' / 'string' / 'value' / NAME / '{' type^Err_TypeType '}'^Err_RCurlyType
  typelist        <-  '(' (type (',' type^Err_TypelistType)*)? ')'^Err_RParenTypelist
  rettype         <-  typelist '->' rettype^Err_TypeReturnTypes  /  simpletype '->' rettype^Err_TypeReturnTypes  /  typelist  /  simpletype
  type            <-  typelist '->' rettype^Err_TypeReturnTypes  /  simpletype '->' rettype^Err_TypeReturnTypes  /  simpletype
  recordfields    <-  recordfield+
  recordfield     <-  NAME ':'^Err_ColonRecordField type^Err_TypeRecordField ';'?
  block           <-  statement* returnstat?]] -- added predicates in statement to add error productions
	..[[
  statement       <-  ';'  /  'do' block 'end'^Err_EndBlock  /  'while' exp^Err_ExpWhile 'do'^Err_DoWhile block 'end'^Err_EndWhile  /  'repeat' block 'until'^Err_UntilRepeat exp^Err_ExpRepeat  /  'if' exp^Err_ExpIf 'then'^Err_ThenIf block elseifstats elseopt 'end'^Err_EndIf  /  'for' decl^Err_DeclFor '='^Err_AssignFor exp^Err_Exp1For ','^Err_CommaFor exp^Err_Exp2For (',' exp^Err_Exp3For)? 'do'^Err_DoFor block 'end'^Err_EndFor  /  'local' decllist^Err_DeclLocal '='^Err_AssignLocal explist^Err_ExpLocal  /  varlist '=' explist^Err_ExpAssign  /  &(exp '=') exp '=' %{Err_ExpAssign}  /  suffixedexp  /  &exp exp %{Err_ExpStat}
  elseifstats     <-  elseifstat*
  elseifstat      <-  'elseif' exp^Err_ExpElseIf 'then'^Err_ThenElseIf block
  elseopt         <-  ('else' block)?
  returnstat      <-  'return' explist? ';'?
  exp             <-  e1
  e1              <-  e2  ('or'  e2^Err_OpExp)*
  e2              <-  e3  ('and' e3^Err_OpExp)*
  e3              <-  e4  (('==' / '~=' / '<=' / '>=' / '<' / '>') e4^Err_OpExp)*
  e4              <-  e5  ('|'   e5^Err_OpExp)*
  e5              <-  e6  ('~'!'='   e6^Err_OpExp)*
  e6              <-  e7  ('&'   e7^Err_OpExp)*
  e7              <-  e8  (('<<' / '>>') e8^Err_OpExp)*
  e8              <-  e9  ('..'  e8^Err_OpExp)?
  e9              <-  e10 (('+' / '-') e10^Err_OpExp)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11^Err_OpExp)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11^Err_OpExp)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME^Err_NameColonExpSuf funcargs^Err_FuncArgsExpSuf  /  '[' exp^Err_ExpExpSuf ']'^Err_RBracketExpSuf  /  '.'!'.' NAME^Err_NameDotExpSuf
  prefixexp       <-  NAME  /  '(' exp^Err_ExpSimpleExp ')'^Err_RParSimpleExp
  castexp         <-  simpleexp 'as' type^Err_CastMissingType  /  simpleexp
  simpleexp       <-  'nil' / 'false' / 'true' / NUMBER / STRINGLIT / initlist / suffixedexp / prefixexp
  var             <-  suffixedexp  /  NAME !expsuffix
  varlist         <-  var (',' var^Err_ExpVarList)*               
  funcargs        <-  '(' explist? ')'^Err_RParFuncArgs  /  initlist  /  STRINGLIT
  explist         <-  exp (',' exp^Err_ExpExpList)*
  initlist        <-  '{' fieldlist? '}'^Err_RCurlyInitList 
  ]]--added predicate in 'fieldlist' to throw a label
  ..[[fieldlist       <-  field (fieldsep (field / !'}' %{Err_ExpFieldList}))* fieldsep?
  field           <-  (NAME '=')? exp
  fieldsep        <-  ';' / ','
  STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  RESERVED        <-  ('and'  / 'as' / 'boolean' / 'break' / 'do' / 'elseif' / 'else' / 'end' / 'float' / 'foreign' / 'for' / 'false'
                     / 'function' / 'goto' / 'if' / 'import' / 'integer' / 'in' / 'local' / 'nil' / 'not' / 'or'
                     / 'record' / 'repeat' / 'return' / 'string' / 'then' / 'true' / 'until' / 'value' / 'while') ![a-zA-Z_0-9]
  NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  COMMENT         <- '--' (!%nl .)* 
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
  Token           <-  '~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'value'  /  'until'  /  'true'  /  'then'  /  'string'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'not'  /  'nil'  /  'local'  /  'integer'  /  'import'  /  'if'  /  'function'  /  'foreign'  /  'for'  /  'float'  /  'false'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'boolean'  /  'as'  /  'and'  /  STRINGLIT  /  RESERVED  /  NUMBER  /  NAME  /  COMMENT  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  '#'
EatToken        <-  (Token  /  (!SKIP .)+) SKIP
Err_EOF         <-  (!(!.) EatToken)*
Err_NameFunc         <-  (!'(' EatToken)*
Err_LParPList         <-  (!(NAME  /  ')') EatToken)*
Err_RParPList         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_EndFunc         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_AssignVar         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_ExpVarDec         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_NameRecord         <-  (!NAME EatToken)*
Err_FieldRecord         <-  (!'end' EatToken)*
Err_EndRecord         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_NameImport         <-  (!'=' EatToken)*
Err_AssignImport         <-  (!'import' EatToken)*
Err_ImportImport         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_StringLParImport         <-  (!')' EatToken)*
Err_RParImport         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_StringImport         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_TypeFunc         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_DeclParList         <-  (!(','  /  ')') EatToken)*
Err_ParamSemicolon         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_TypeDecl         <-  (!(','  /  ')') EatToken)*
Err_TypeType         <-  (!'}' EatToken)*
Err_RCurlyType         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_TypelistType         <-  (!(','  /  ')') EatToken)*
Err_RParenTypelist         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_TypeReturnTypes         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_ColonRecordField         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_TypeRecordField         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_EndBlock         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_ExpWhile         <-  (!'do' EatToken)*
Err_DoWhile         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_EndWhile         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_UntilRepeat         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_ExpRepeat         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_ExpIf         <-  (!'then' EatToken)*
Err_ThenIf         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_EndIf         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_DeclFor         <-  (!'=' EatToken)*
Err_AssignFor         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_Exp1For         <-  (!',' EatToken)*
Err_CommaFor         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_Exp2For         <-  (!('do'  /  ',') EatToken)*
Err_Exp3For         <-  (!'do' EatToken)*
Err_DoFor         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_EndFor         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_DeclLocal         <-  (!'=' EatToken)*
Err_AssignLocal         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_ExpLocal         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_ExpAssign         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_ExpStat         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_ExpElseIf         <-  (!'then' EatToken)*
Err_ThenElseIf         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_OpExp         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_NameColonExpSuf         <-  (!('{'  /  STRINGLIT  /  '(') EatToken)*
Err_FuncArgsExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_ExpExpSuf         <-  (!']' EatToken)*
Err_RBracketExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_NameDotExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_ExpSimpleExp         <-  (!')' EatToken)*
Err_RParSimpleExp         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_CastMissingType         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_ExpVarList         <-  (!('='  /  ',') EatToken)*
Err_RParFuncArgs         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_ExpExpList         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  ','  /  ')'  /  '(') EatToken)*
Err_RCurlyInitList         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_ExpFieldList         <-  (!('}'  /  ';'  /  ',') EatToken)*
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNoRec(dir, 'titan', p)

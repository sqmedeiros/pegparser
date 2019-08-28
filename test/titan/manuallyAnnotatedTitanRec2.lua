local m = require 'init'
local coder = require 'coder'
local util = require'util'


-- Removed label 'AssignAssign' in rule statement because the correct matching
-- of varlist depends on a semantic action in rule var

g = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* (!.)^Err_EOF
  toplevelfunc    <-  localopt 'function' NAME^NameFunc '('^LParPList paramlist ')'^RParPList rettypeopt block 'end'^EndFunc
  ]]--added predicate in 'toplevalvar' to label 'exp'
  ..[[
  toplevelvar     <-  localopt decl '='^AssignVar !('import' / 'foreign') exp^ExpVarDec
  toplevelrecord  <-  'record' NAME^NameRecord recordfields^FieldRecord 'end'^EndRecord
  localopt        <-  'local'?
  ]]--added predicate in 'import' to label 'import'
  ..[[
  import          <-  'local' NAME^NameImport '='^AssignImport !'foreign' 'import'^ImportImport ('(' STRINGLIT^StringLParImport ')'^RParImport / STRINGLIT^StringImport)
  foreign         <-  'local' NAME^NameImport '='^AssignImport 'foreign' 'import'^ImportImport  ('(' STRINGLIT^StringLParImport ')'^RParImport / STRINGLIT^StringImport)
  rettypeopt      <-  (':' rettype^TypeFunc)?
  paramlist       <-  (param (',' param^DeclParList)*)?
  param           <-  NAME ':'^ParamSemicolon type^TypeDecl
  decl            <-  NAME (':' type^TypeDecl)?
  decllist        <-  decl (',' decl^DeclParList)*
  simpletype      <-  'nil' / 'boolean' / 'integer' / 'float' / 'string' / 'value' / NAME / '{' type^TypeType '}'^RCurlyType
  typelist        <-  '(' (type (',' type^TypelistType)*)? ')'^RParenTypelist
  rettype         <-  typelist '->' rettype^TypeReturnTypes  /  simpletype '->' rettype^TypeReturnTypes  /  typelist  /  simpletype
  type            <-  typelist '->' rettype^TypeReturnTypes  /  simpletype '->' rettype^TypeReturnTypes  /  simpletype
  recordfields    <-  recordfield+
  recordfield     <-  NAME ':'^ColonRecordField type^TypeRecordField ';'?
  block           <-  statement* returnstat?]] -- added predicates in statement to add error productions
	..[[
  statement       <-  ';'  /  'do' block 'end'^EndBlock  /  'while' exp^ExpWhile 'do'^DoWhile block 'end'^EndWhile  /  'repeat' block 'until'^UntilRepeat exp^ExpRepeat  /  'if' exp^ExpIf 'then'^ThenIf block elseifstats elseopt 'end'^EndIf  /  'for' decl^DeclFor '='^AssignFor exp^Exp1For ','^CommaFor exp^Exp2For (',' exp^Exp3For)? 'do'^DoFor block 'end'^EndFor  /  'local' decllist^DeclLocal '='^AssignLocal explist^ExpLocal  /  varlist '=' explist^ExpAssign  /  &(exp '=') exp '=' %{ExpAssign}  /  suffixedexp  /  &exp exp %{ExpStat}
  elseifstats     <-  elseifstat*
  elseifstat      <-  'elseif' exp^ExpElseIf 'then'^ThenElseIf block
  elseopt         <-  ('else' block)?
  returnstat      <-  'return' explist? ';'?
  exp             <-  e1
  e1              <-  e2  ('or'  e2^OpExp)*
  e2              <-  e3  ('and' e3^OpExp)*
  e3              <-  e4  (('==' / '~=' / '<=' / '>=' / '<' / '>') e4^OpExp)*
  e4              <-  e5  ('|'   e5^OpExp)*
  e5              <-  e6  ('~'!'='   e6^OpExp)*
  e6              <-  e7  ('&'   e7^OpExp)*
  e7              <-  e8  (('<<' / '>>') e8^OpExp)*
  e8              <-  e9  ('..'  e8^OpExp)?
  e9              <-  e10 (('+' / '-') e10^OpExp)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11^OpExp)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11^OpExp)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME^NameColonExpSuf funcargs^FuncArgsExpSuf  /  '[' exp^ExpExpSuf ']'^RBracketExpSuf  /  '.'!'.' NAME^NameDotExpSuf
  prefixexp       <-  NAME  /  '(' exp^ExpSimpleExp ')'^RParSimpleExp
  castexp         <-  simpleexp 'as' type^CastMissingType  /  simpleexp
  simpleexp       <-  'nil' / 'false' / 'true' / NUMBER / STRINGLIT / initlist / suffixedexp / prefixexp
  var             <-  suffixedexp  /  NAME !expsuffix
  varlist         <-  var (',' var^ExpVarList)*               
  funcargs        <-  '(' explist? ')'^RParFuncArgs  /  initlist  /  STRINGLIT
  explist         <-  exp (',' exp^ExpExpList)*
  initlist        <-  '{' fieldlist? '}'^RCurlyInitList 
  ]]--added predicate in 'fieldlist' to throw a label
  ..[[fieldlist       <-  field (fieldsep (field / !'}' %{ExpFieldList}))* fieldsep?
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
NameFunc         <-  (!'(' EatToken)*
LParPList         <-  (!(NAME  /  ')') EatToken)*
RParPList         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
EndFunc         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
AssignVar         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
ExpVarDec         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
NameRecord         <-  (!NAME EatToken)*
FieldRecord         <-  (!'end' EatToken)*
EndRecord         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
NameImport         <-  (!'=' EatToken)*
AssignImport         <-  (!'import' EatToken)*
ImportImport         <-  (!(STRINGLIT  /  '(') EatToken)*
StringLParImport         <-  (!')' EatToken)*
RParImport         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
StringImport         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
TypeFunc         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
DeclParList         <-  (!(','  /  ')') EatToken)*
ParamSemicolon         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
TypeDecl         <-  (!(','  /  ')') EatToken)*
TypeType         <-  (!'}' EatToken)*
RCurlyType         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
TypelistType         <-  (!(','  /  ')') EatToken)*
RParenTypelist         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
TypeReturnTypes         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
ColonRecordField         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
TypeRecordField         <-  (!('end'  /  NAME  /  ';') EatToken)*
EndBlock         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
ExpWhile         <-  (!'do' EatToken)*
DoWhile         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
EndWhile         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
UntilRepeat         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
ExpRepeat         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
ExpIf         <-  (!'then' EatToken)*
ThenIf         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
EndIf         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
DeclFor         <-  (!'=' EatToken)*
AssignFor         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Exp1For         <-  (!',' EatToken)*
CommaFor         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Exp2For         <-  (!('do'  /  ',') EatToken)*
Exp3For         <-  (!'do' EatToken)*
DoFor         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
EndFor         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
DeclLocal         <-  (!'=' EatToken)*
AssignLocal         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
ExpLocal         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
ExpAssign         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
ExpStat         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
ExpElseIf         <-  (!'then' EatToken)*
ThenElseIf         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
OpExp         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
NameColonExpSuf         <-  (!('{'  /  STRINGLIT  /  '(') EatToken)*
FuncArgsExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
ExpExpSuf         <-  (!']' EatToken)*
RBracketExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
NameDotExpSuf         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
ExpSimpleExp         <-  (!')' EatToken)*
RParSimpleExp         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
CastMissingType         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
ExpVarList         <-  (!('='  /  ',') EatToken)*
RParFuncArgs         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
ExpExpList         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  ','  /  ')'  /  '(') EatToken)*
RCurlyInitList         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
ExpFieldList         <-  (!('}'  /  ';'  /  ',') EatToken)*
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNoRec(dir, 'titan', p)

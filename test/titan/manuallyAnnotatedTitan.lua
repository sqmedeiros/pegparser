local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

-- Removed label 'AssignAssign' in rule statement because the correct matching
-- of varlist depends on a semantic action in rule var

g = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import / foreign)* !.
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
  statement       <-  ';'  /  'do' block 'end'^EndBlock  /  'while' exp^ExpWhile 'do'^DoWhile block 'end'^EndWhile  /  'repeat' block 'until'^UntilRepeat exp^ExpRepeat  /  'if' exp^ExpIf 'then'^ThenIf block elseifstats elseopt 'end'^EndIf  /  'for' decl^DeclFor '='^AssignFor exp^Exp1For ','^CommaFor exp^Exp2For (',' exp^Exp3For)? 'do'^DoFor block 'end'^EndFor  /  'local' decllist^DeclLocal '='^AssignLocal explist^ExpLocal  /  varlist '=' explist^ExpAssign  /  &(exp '=') %{ExpAssign}  /  suffixedexp  /  &exp %{ExpStat}
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
  COMMENT         <- '--' (!%nl .)* ]]


local g = m.match(g)
print("Manually Annotated Grammar")
print(pretty.printg(g), '\n')

local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'titan', p)

util.testNo(dir, 'titan', p, 'strict', 'AssignAssign')


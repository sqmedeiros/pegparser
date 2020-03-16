local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import / foreign)* !.
  toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
  ]]--predicate in 'toplevalvar' is related to the use of labels
  --toplevelvar     <-  <localopt> <decl> '=' !('import' / 'foreign') <exp>
  ..[[
  toplevelvar     <-  localopt decl '=' exp
  toplevelrecord  <-  'record' NAME recordfields 'end'
  localopt        <-  'local'?
  ]]--predicate in 'import' is related to the use of labels
  --import          <-  'local' <NAME> '=' !'foreign' 'import' ('(' <STRINGLIT> ')' / <STRINGLIT>)
  ..[[
  import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')' / STRINGLIT)
  foreign         <-  'local' NAME '=' 'foreign' 'import' ('(' STRINGLIT ')' / STRINGLIT)
  rettypeopt      <-  (':' rettype)?
  paramlist       <-  (param (',' param)*)?
  param           <-  NAME ':' type
  decl            <-  NAME (':' type)?
  decllist        <-  decl (',' decl)*
  simpletype      <-  'nil' / 'boolean' / 'integer' / 'float' / 'string' / 'value' / NAME / '{' type '}'
  typelist        <-  '(' (type (',' type)*)? ')'
  rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
  type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
  recordfields    <-  recordfield+
  recordfield     <-  NAME ':' type ';'?
  block           <-  statement* returnstat?
  statement       <-  ';'  /  'do' block 'end'  /  'while' exp 'do' block 'end'  /  'repeat' block 'until' exp  /  'if' exp 'then' block elseifstats elseopt 'end'  /  'for' decl '=' exp ',' exp (',' exp)? 'do' block 'end'  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
  elseifstats     <-  elseifstat*
  elseifstat      <-  'elseif' exp 'then' block
  elseopt         <-  ('else' block)?
  returnstat      <-  'return' explist? ';'?
  exp             <-  e1
  e1              <-  e2  ('or'  e2)*
  e2              <-  e3  ('and' e3)*
  e3              <-  e4  (('==' / '~=' / '<=' / '>=' / '<' / '>') e4)*
  e4              <-  e5  ('|'   e5)*
  e5              <-  e6  ('~'!'='   e6)*
  e6              <-  e7  ('&'   e7)*
  e7              <-  e8  (('<<' / '>>') e8)*
  e8              <-  e9  ('..'  e8)?
  e9              <-  e10 (('+' / '-') e10)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp ']'  /  '.'!'.' NAME
  prefixexp       <-  NAME  /  '(' exp ')'
  castexp         <-  simpleexp 'as' type  /  simpleexp
  simpleexp       <-  'nil' / 'false' / 'true' / NUMBER / STRINGLIT / initlist / suffixedexp / prefixexp
  var             <-  suffixedexp  /  NAME !expsuffix
  varlist         <-  var (',' var)*               
  funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
  explist         <-  exp (',' exp)*
  initlist        <-  '{' fieldlist? '}' 
  ]]--predicate in 'fieldlist' is related to the use of labels
  --fieldlist       <-  <field> (<fieldsep> (<field> / !'}' %ExpFieldList)* <fieldsep>?
  ..[[fieldlist       <-  field (fieldsep field)* fieldsep?
  field           <-  (NAME '=')? exp
  fieldsep        <-  ';' / ','
  STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  RESERVED        <-  ('and'  / 'as' / 'boolean' / 'break' / 'do' / 'elseif' / 'else' / 'end' / 'float' / 'foreign' / 'for' / 'false'
                     / 'function' / 'goto' / 'if' / 'import' / 'integer' / 'in' / 'local' / 'nil' / 'not' / 'or'
                     / 'record' / 'repeat' / 'return' / 'string' / 'then' / 'true' / 'until' / 'value' / 'while') ![a-zA-Z_0-9]
  NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  COMMENT         <- '--' (!%nl .)* ]]


--print("Original Grammar")
--local g = m.match(s)
--print(pretty.printg(g), '\n')



print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
print(pretty.printg(gupath, true, 'unique'), '\n')
print(pretty.printg(gupath, true, 'uniqueEq'), '\n')
pretty.printToFile(g, nil, 'titan')

print("End UPath\n")


g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

--util.testYes(dir .. '/test/yes/', 'titan', p)

--util.testNo(dir .. '/test/no/', 'titan', p)

util.testNoRecDist(dir .. '/test/noTmp/', 'titan', p)


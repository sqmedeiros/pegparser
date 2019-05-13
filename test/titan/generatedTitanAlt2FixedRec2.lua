local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Does not need to remove labels manually
-- Add label Err_EOF and the corresponding recovery rule

g = [[

program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* (!.)^Err_EOF
toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_001 recordfields^Err_002 'end'^Err_003
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')'  /  STRINGLIT)
foreign         <-  'local' NAME^Err_004 '='^Err_005 'foreign'^Err_006 'import'^Err_007 ('(' STRINGLIT^Err_008 ')'^Err_009  /  STRINGLIT)^Err_010
rettypeopt      <-  (':' rettype^Err_011)?
paramlist       <-  (param (',' param^Err_012)*)?
param           <-  NAME ':'^Err_013 type^Err_014
decl            <-  NAME (':' type^Err_015)?
decllist        <-  decl (',' decl^Err_016)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_017 type^Err_018 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_019  /  'while' exp^Err_020 'do'^Err_021 block 'end'^Err_022  /  'repeat' block 'until'^Err_023 exp^Err_024  /  'if' exp^Err_025 'then'^Err_026 block elseifstats elseopt 'end'^Err_027  /  'for' decl^Err_028 '='^Err_029 exp^Err_030 ','^Err_031 exp^Err_032 (',' exp^Err_033)? 'do'^Err_034 block 'end'^Err_035  /  'local' decllist^Err_036 '='^Err_037 explist^Err_038  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_039 'then'^Err_040 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2)*
e2              <-  e3 ('and' e3)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4)*
e4              <-  e5 ('|' e5)*
e5              <-  e6 ('~' !'=' e6)*
e6              <-  e7 ('&' e7)*
e7              <-  e8 (('<<'  /  '>>') e8)*
e8              <-  e9 ('..' e8)?
e9              <-  e10 (('+'  /  '-') e10)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME^Err_041 funcargs^Err_042  /  '[' exp^Err_043 ']'^Err_044  /  '.' !'.' NAME^Err_045
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var)*
funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp)*
initlist        <-  '{' fieldlist? '}'
fieldlist       <-  field (fieldsep field)* fieldsep?
field           <-  (NAME '=')? exp
fieldsep        <-  ';'  /  ','
STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
RESERVED        <-  ('and'  /  'as'  /  'boolean'  /  'break'  /  'do'  /  'elseif'  /  'else'  /  'end'  /  'float'  /  'foreign'  /  'for'  /  'false'  /  'function'  /  'goto'  /  'if'  /  'import'  /  'integer'  /  'in'  /  'local'  /  'nil'  /  'not'  /  'or'  /  'record'  /  'repeat'  /  'return'  /  'string'  /  'then'  /  'true'  /  'until'  /  'value'  /  'while') ![a-zA-Z_0-9]
NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
NUMBER          <-  [0-9]+ ('.' !'.' [0-9]*)?
COMMENT         <-  '--' (!%nl .)*
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'value'  /  'until'  /  'true'  /  'then'  /  'string'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'not'  /  'nil'  /  'local'  /  'integer'  /  'import'  /  'if'  /  'function'  /  'foreign'  /  'for'  /  'float'  /  'false'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'boolean'  /  'as'  /  'and'  /  STRINGLIT  /  RESERVED  /  NUMBER  /  NAME  /  COMMENT  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  '#'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_EOF         <-  (!(!.) EatToken)*
Err_001         <-  (!NAME EatToken)*
Err_002         <-  (!'end' EatToken)*
Err_003         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_004         <-  (!'=' EatToken)*
Err_005         <-  (!'foreign' EatToken)*
Err_006         <-  (!'import' EatToken)*
Err_007         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_008         <-  (!')' EatToken)*
Err_009         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_010         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_011         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_012         <-  (!')' EatToken)*
Err_013         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_014         <-  (!(','  /  ')') EatToken)*
Err_015         <-  (!('='  /  ',') EatToken)*
Err_016         <-  (!'=' EatToken)*
Err_017         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_018         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_019         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_020         <-  (!'do' EatToken)*
Err_021         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_022         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_023         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_024         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_025         <-  (!'then' EatToken)*
Err_026         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_027         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_028         <-  (!'=' EatToken)*
Err_029         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_030         <-  (!',' EatToken)*
Err_031         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_032         <-  (!('do'  /  ',') EatToken)*
Err_033         <-  (!'do' EatToken)*
Err_034         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_035         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_036         <-  (!'=' EatToken)*
Err_037         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_038         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_039         <-  (!'then' EatToken)*
Err_040         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_041         <-  (!('{'  /  STRINGLIT  /  '(') EatToken)*
Err_042         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_043         <-  (!']' EatToken)*
Err_044         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_045         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*	
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNoRec(dir, 'titan', p)



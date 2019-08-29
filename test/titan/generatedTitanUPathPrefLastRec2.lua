local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Added 63 labels
-- Did not have to remove rules manually
-- Added label Err_EOF and the corresponding recovery rule

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* (!.)^Err_EOF
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_005 recordfields^Err_006 'end'^Err_007
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT^Err_008 ')'^Err_009  /  STRINGLIT)^Err_010
foreign         <-  'local' NAME^Err_011 '='^Err_012 'foreign'^Err_013 'import'^Err_014 ('(' STRINGLIT^Err_015 ')'^Err_016  /  STRINGLIT)^Err_017
rettypeopt      <-  (':' rettype^Err_018)?
paramlist       <-  (param (',' param^Err_019)*)?
param           <-  NAME ':'^Err_020 type^Err_021
decl            <-  NAME (':' type)?
decllist        <-  decl^Err_022 (',' decl^Err_023)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_024
recordfield     <-  NAME ':'^Err_025 type^Err_026 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_027  /  'while' exp^Err_028 'do'^Err_029 block 'end'^Err_030  /  'repeat' block 'until'^Err_031 exp^Err_032  /  'if' exp^Err_033 'then'^Err_034 block elseifstats elseopt 'end'^Err_035  /  'for' decl^Err_036 '='^Err_037 exp^Err_038 ','^Err_039 exp^Err_040 (',' exp^Err_041)? 'do'^Err_042 block 'end'^Err_043  /  'local' decllist^Err_044 '='^Err_045 explist^Err_046  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_047 'then'^Err_048 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_049)*
e2              <-  e3 ('and' e3^Err_050)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_051)*
e4              <-  e5 ('|' e5^Err_052)*
e5              <-  e6 ('~' !'=' e6^Err_053)*
e6              <-  e7 ('&' e7^Err_054)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_055)*
e8              <-  e9 ('..' e8^Err_056)?
e9              <-  e10 (('+'  /  '-') e10^Err_057)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_058)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_059)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_060 ']'^Err_061  /  '.' !'.' NAME^Err_062
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_063  /  simpleexp
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
Token           <-  '~='  /  '~'  /  '}'  /  '|'  /  '{'  /  STRINGLIT  /  RESERVED  /  NUMBER  /  NAME  /  COMMENT  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  '#'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_EOF         <-  (!(!.) EatToken)*
Err_001         <-  (!'(' EatToken)*
Err_002         <-  (!(NAME  /  ')') EatToken)*
Err_003         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_004         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_005         <-  (!NAME EatToken)*
Err_006         <-  (!'end' EatToken)*
Err_007         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_008         <-  (!')' EatToken)*
Err_009         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_010         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_011         <-  (!'=' EatToken)*
Err_012         <-  (!'foreign' EatToken)*
Err_013         <-  (!'import' EatToken)*
Err_014         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_015         <-  (!')' EatToken)*
Err_016         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_017         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_018         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_019         <-  (!(','  /  ')') EatToken)*
Err_020         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_021         <-  (!(','  /  ')') EatToken)*
Err_022         <-  (!('='  /  ',') EatToken)*
Err_023         <-  (!('='  /  ',') EatToken)*
Err_024         <-  (!('end'  /  NAME) EatToken)*
Err_025         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_026         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_027         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_028         <-  (!'do' EatToken)*
Err_029         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_030         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_031         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_032         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_033         <-  (!'then' EatToken)*
Err_034         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_035         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_036         <-  (!'=' EatToken)*
Err_037         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_038         <-  (!',' EatToken)*
Err_039         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_040         <-  (!('do'  /  ',') EatToken)*
Err_041         <-  (!'do' EatToken)*
Err_042         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_043         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_044         <-  (!'=' EatToken)*
Err_045         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_046         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_047         <-  (!'then' EatToken)*
Err_048         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_049         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_050         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_051         <-  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_052         <-  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_053         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_054         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_055         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_056         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_057         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_058         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_059         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_060         <-  (!']' EatToken)*
Err_061         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_062         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_063         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*	
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNoRec(dir, 'titan', p)

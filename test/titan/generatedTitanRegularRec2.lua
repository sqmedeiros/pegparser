local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Remove Err_006 ('exp' in rule toplevelvar), Err_012 ('import' in rule import)
-- Add label Err_EOF and the corresponding recovery rule

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* (!.)^Err_EOF
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '='^Err_005 exp
toplevelrecord  <-  'record' NAME^Err_007 recordfields^Err_008 'end'^Err_009
localopt        <-  'local'?
import          <-  'local' NAME^Err_010 '='^Err_011 'import' ('(' STRINGLIT^Err_013 ')'^Err_014  /  STRINGLIT)^Err_015
foreign         <-  'local' NAME^Err_016 '='^Err_017 'foreign'^Err_018 'import'^Err_019 ('(' STRINGLIT^Err_020 ')'^Err_021  /  STRINGLIT)^Err_022
rettypeopt      <-  (':' rettype^Err_023)?
paramlist       <-  (param (',' param^Err_024)*)?
param           <-  NAME ':'^Err_025 type^Err_026
decl            <-  NAME (':' type^Err_027)?
decllist        <-  decl (',' decl^Err_028)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type^Err_029 '}'^Err_030
typelist        <-  '(' (type (',' type^Err_031)*)? ')'^Err_032
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->'^Err_033 rettype^Err_034  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_035 type^Err_036 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_037  /  'while' exp^Err_038 'do'^Err_039 block 'end'^Err_040  /  'repeat' block 'until'^Err_041 exp^Err_042  /  'if' exp^Err_043 'then'^Err_044 block elseifstats elseopt 'end'^Err_045  /  'for' decl^Err_046 '='^Err_047 exp^Err_048 ','^Err_049 exp^Err_050 (',' exp^Err_051)? 'do'^Err_052 block 'end'^Err_053  /  'local' decllist^Err_054 '='^Err_055 explist^Err_056  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_057 'then'^Err_058 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_059)*
e2              <-  e3 ('and' e3^Err_060)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_061)*
e4              <-  e5 ('|' e5^Err_062)*
e5              <-  e6 ('~' !'=' e6^Err_063)*
e6              <-  e7 ('&' e7^Err_064)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_065)*
e8              <-  e9 ('..' e8^Err_066)?
e9              <-  e10 (('+'  /  '-') e10^Err_067)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_068)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_069)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME^Err_070 funcargs^Err_071  /  '[' exp^Err_072 ']'^Err_073  /  '.' !'.' NAME^Err_074
prefixexp       <-  NAME  /  '(' exp^Err_075 ')'^Err_076
castexp         <-  simpleexp 'as' type  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var^Err_077)*
funcargs        <-  '(' explist? ')'^Err_078  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_079)*
initlist        <-  '{' fieldlist? '}'^Err_080
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
Err_EOF         <-  (!!. EatToken)*
Err_001         <-  (!'(' EatToken)*
Err_002         <-  (!(NAME  /  ')') EatToken)*
Err_003         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_004         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_005         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_006         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_007         <-  (!NAME EatToken)*
Err_008         <-  (!'end' EatToken)*
Err_009         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_010         <-  (!'=' EatToken)*
Err_011         <-  (!'import' EatToken)*
Err_012         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_013         <-  (!')' EatToken)*
Err_014         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_015         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_016         <-  (!'=' EatToken)*
Err_017         <-  (!'foreign' EatToken)*
Err_018         <-  (!'import' EatToken)*
Err_019         <-  (!(STRINGLIT  /  '(') EatToken)*
Err_020         <-  (!')' EatToken)*
Err_021         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_022         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_023         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_024         <-  (!(','  /  ')') EatToken)*
Err_025         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_026         <-  (!(','  /  ')') EatToken)*
Err_027         <-  (!('='  /  ',') EatToken)*
Err_028         <-  (!('='  /  ',') EatToken)*
Err_029         <-  (!'}' EatToken)*
Err_030         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_031         <-  (!(','  /  ')') EatToken)*
Err_032         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '->'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_033         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_034         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_035         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_036         <-  (!('end'  /  NAME  /  ';') EatToken)*
Err_037         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_038         <-  (!'do' EatToken)*
Err_039         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_040         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_041         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_042         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_043         <-  (!'then' EatToken)*
Err_044         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_045         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_046         <-  (!'=' EatToken)*
Err_047         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_048         <-  (!',' EatToken)*
Err_049         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_050         <-  (!('do'  /  ',') EatToken)*
Err_051         <-  (!'do' EatToken)*
Err_052         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_053         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_054         <-  (!'=' EatToken)*
Err_055         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_056         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_057         <-  (!'then' EatToken)*
Err_058         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_059         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_060         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_061         <-  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_062         <-  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_063         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_064         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_065         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_066         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_067         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_068         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_069         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_070         <-  (!('{'  /  STRINGLIT  /  '(') EatToken)*
Err_071         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_072         <-  (!']' EatToken)*
Err_073         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_074         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_075         <-  (!')' EatToken)*
Err_076         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_077         <-  (!('='  /  ',') EatToken)*
Err_078         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_079         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  ','  /  ')'  /  '(') EatToken)*
Err_080         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNoRec(dir, 'titan', p)

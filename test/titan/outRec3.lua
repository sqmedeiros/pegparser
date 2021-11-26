local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign  /  !(!.) %{Err_001} EatToken Err_001_Rec)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_002 '('^Err_003 paramlist ')'^Err_004 rettypeopt block 'end'^Err_005
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_006 recordfields^Err_007 'end'^Err_008
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT^Err_011)^Err_012
foreign         <-  'local' NAME^Err_013 '='^Err_014 'foreign'^Err_015 'import'^Err_016 ('(' STRINGLIT^Err_017 ')'^Err_018  /  STRINGLIT^Err_019)^Err_020
rettypeopt      <-  (':' rettype^Err_021  /  !('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '('  /  !.) %{Err_022} EatToken Err_022_Rec)?
paramlist       <-  (param (',' param^Err_023  /  !(')'  /  !.) %{Err_024} EatToken Err_024_Rec)*  /  !(')'  /  !.) %{Err_025} EatToken Err_025_Rec)?
param           <-  NAME ':'^Err_026 type^Err_027
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  (recordfield  /  !('end'  /  !.) %{Err_028} EatToken Err_028_Rec)+
recordfield     <-  NAME ':'^Err_029 type^Err_030 (';'  /  !('end'  /  NAME  /  !.) %{Err_031} EatToken Err_031_Rec)?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_032 'do'^Err_033 block 'end'^Err_034  /  'repeat' block 'until'^Err_035 exp^Err_036  /  'if' exp^Err_037 'then'^Err_038 block elseifstats elseopt 'end'^Err_039  /  'for' decl^Err_040 '='^Err_041 exp^Err_042 ','^Err_043 exp^Err_044 (',' exp^Err_045  /  !('do'  /  !.) %{Err_046} EatToken Err_046_Rec)? 'do'^Err_047 block 'end'^Err_048  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  (elseifstat  /  !('end'  /  'else'  /  !.) %{Err_049} EatToken Err_049_Rec)*
elseifstat      <-  'elseif' exp^Err_050 'then'^Err_051 block
elseopt         <-  ('else' block  /  !('end'  /  !.) %{Err_052} EatToken Err_052_Rec)?
returnstat      <-  'return' (explist  /  !('until'  /  'end'  /  'elseif'  /  'else'  /  ';'  /  !.) %{Err_053} EatToken Err_053_Rec)? (';'  /  !('until'  /  'end'  /  'elseif'  /  'else'  /  !.) %{Err_054} EatToken Err_054_Rec)?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_055)*
e2              <-  e3 ('and' e3^Err_056)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_057)*
e4              <-  e5 ('|' e5^Err_058)*
e5              <-  e6 ('~' !'=' e6^Err_059)*
e6              <-  e7 ('&' e7^Err_060)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_061)*
e8              <-  e9 ('..' e8^Err_062)?
e9              <-  e10 (('+'  /  '-') e10^Err_063)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_064)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_065)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_066 ']'^Err_067  /  '.' !'.' NAME^Err_068
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_069  /  simpleexp
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
Err_001         <-  ''
Err_001_Rec     <-  (!('record'  /  'local'  /  'function'  /  NAME) !(!.) EatToken)*
Err_002         <-  (!'(' EatToken SKIP)*
Err_003         <-  (!(NAME  /  ')') EatToken SKIP)*
Err_004         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken SKIP)*
Err_005         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_006         <-  (!NAME EatToken SKIP)*
Err_007         <-  (!'end' EatToken SKIP)*
Err_008         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_009         <-  (!')' EatToken SKIP)*
Err_010         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_011         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_012         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_013         <-  (!'=' EatToken SKIP)*
Err_014         <-  (!'foreign' EatToken SKIP)*
Err_015         <-  (!'import' EatToken SKIP)*
Err_016         <-  (!(STRINGLIT  /  '(') EatToken SKIP)*
Err_017         <-  (!')' EatToken SKIP)*
Err_018         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_019         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_020         <-  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken SKIP)*
Err_021         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_022         <-  ''
Err_022_Rec     <-  (!':' !('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '('  /  !.) EatToken)?
Err_023         <-  (!')' EatToken SKIP)*
Err_024         <-  ''
Err_024_Rec     <-  (!',' !(')'  /  !.) EatToken)*
Err_025         <-  ''
Err_025_Rec     <-  (!NAME !(')'  /  !.) EatToken)?
Err_026         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken SKIP)*
Err_027         <-  (!(','  /  ')') EatToken SKIP)*
Err_028         <-  ''
Err_028_Rec     <-  (!NAME !('end'  /  !.) EatToken)*
Err_029         <-  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken SKIP)*
Err_030         <-  (!('end'  /  NAME  /  ';') EatToken SKIP)*
Err_031         <-  ''
Err_031_Rec     <-  (!';' !('end'  /  NAME  /  !.) EatToken)?
Err_032         <-  (!'do' EatToken SKIP)*
Err_033         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_034         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_035         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken SKIP)*
Err_036         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_037         <-  (!'then' EatToken SKIP)*
Err_038         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_039         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_040         <-  (!'=' EatToken SKIP)*
Err_041         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken SKIP)*
Err_042         <-  (!',' EatToken SKIP)*
Err_043         <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken SKIP)*
Err_044         <-  (!('do'  /  ',') EatToken SKIP)*
Err_045         <-  (!'do' EatToken SKIP)*
Err_046         <-  ''
Err_046_Rec     <-  (!',' !('do'  /  !.) EatToken)?
Err_047         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_048         <-  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_049         <-  ''
Err_049_Rec     <-  (!'elseif' !('end'  /  'else'  /  !.) EatToken)*
Err_050         <-  (!'then' EatToken SKIP)*
Err_051         <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken SKIP)*
Err_052         <-  ''
Err_052_Rec     <-  (!'else' !('end'  /  !.) EatToken)?
Err_053         <-  ''
Err_053_Rec     <-  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') !('until'  /  'end'  /  'elseif'  /  'else'  /  ';'  /  !.) EatToken)?
Err_054         <-  ''
Err_054_Rec     <-  (!';' !('until'  /  'end'  /  'elseif'  /  'else'  /  !.) EatToken)?
Err_055         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_056         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_057         <-  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_058         <-  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_059         <-  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_060         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken SKIP)*
Err_061         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken SKIP)*
Err_062         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken SKIP)*
Err_063         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken SKIP)*
Err_064         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken SKIP)*
Err_065         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken SKIP)*
Err_066         <-  (!']' EatToken SKIP)*
Err_067         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken SKIP)*
Err_068         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken SKIP)*
Err_069         <-  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken SKIP)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'titan', p)
util.setVerbose(true)
util.testNoRec(dir .. '/test/no/', 'titan', p)

local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign  /  !(!.) %{Err_001} Err_001_Rec)* (!.)^Err_EOF
toplevelfunc    <-  localopt 'function' NAME^Err_002 '('^Err_003 paramlist ')'^Err_004 rettypeopt block 'end'^Err_005
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME recordfields 'end'
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT^Err_011)^Err_012
foreign         <-  'local' NAME^Err_013 '='^Err_014 'foreign'^Err_015 'import'^Err_016 ('(' STRINGLIT^Err_017 ')'^Err_018  /  STRINGLIT^Err_019)^Err_020
rettypeopt      <-  (':' rettype^Err_021  /  !('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') %{Err_022} Err_022_Rec)?
paramlist       <-  (param (',' param^Err_023  /  !')' %{Err_024} Err_024_Rec)*  /  !')' %{Err_025} Err_025_Rec)?
param           <-  NAME ':'^Err_026 type^Err_027
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  (recordfield  /  !'end' %{Err_028} Err_028_Rec)+
recordfield     <-  NAME ':'^Err_029 type^Err_030 (';'  /  !('end'  /  NAME) %{Err_031} Err_031_Rec)?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_032 'do'^Err_033 block 'end'^Err_034  /  'repeat' block 'until'^Err_035 exp^Err_036  /  'if' exp^Err_037 'then'^Err_038 block elseifstats elseopt 'end'^Err_039  /  'for' decl^Err_040 '='^Err_041 exp^Err_042 ','^Err_043 exp^Err_044 (',' exp^Err_045  /  !'do' %{Err_046} Err_046_Rec)? 'do'^Err_047 block 'end'^Err_048  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  (elseifstat  /  !('end'  /  'else') %{Err_049} Err_049_Rec)*
elseifstat      <-  'elseif' exp^Err_050 'then'^Err_051 block
elseopt         <-  ('else' block  /  !'end' %{Err_052} Err_052_Rec)?
returnstat      <-  'return' (explist  /  !('until'  /  'end'  /  'elseif'  /  'else'  /  ';') %{Err_053} Err_053_Rec)? (';'  /  !('until'  /  'end'  /  'elseif'  /  'else') %{Err_054} Err_054_Rec)?
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
Err_EOF         <-  (!!. EatToken)*
Err_001         <-  ''
Err_001_Rec     <-  (!(!.) EatToken)*
Err_002         <-  &(EatToken NAME) EatToken NAME SKIP  /  (!'(' EatToken)*
Err_003         <-  &(EatToken '(') EatToken '(' SKIP  /  (!(NAME  /  ')') EatToken)*
Err_004         <-  &(EatToken ')') EatToken ')' SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  ':'  /  '(') EatToken)*
Err_005         <-  &(EatToken 'end') EatToken 'end' SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_006         <-  &(EatToken NAME) EatToken NAME SKIP  /  (!NAME EatToken)*
Err_007         <-  &(EatToken recordfields) EatToken recordfields SKIP  /  (!'end' EatToken)*
Err_008         <-  %{Nada} 
Err_009         <-  &(EatToken STRINGLIT) EatToken STRINGLIT SKIP  /  (!')' EatToken)*
Err_010         <-  &(EatToken ')') EatToken ')' SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_011         <-  &(EatToken STRINGLIT) EatToken STRINGLIT SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_012         <-  &(EatToken ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT^Err_011)) EatToken ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT^Err_011) SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_013         <-  &(EatToken NAME) EatToken NAME SKIP  /  (!'=' EatToken)*
Err_014         <-  &(EatToken '=') EatToken '=' SKIP  /  (!'foreign' EatToken)*
Err_015         <-  &(EatToken 'foreign') EatToken 'foreign' SKIP  /  (!'import' EatToken)*
Err_016         <-  &(EatToken 'import') EatToken 'import' SKIP  /  (!(STRINGLIT  /  '(') EatToken)*
Err_017         <-  &(EatToken STRINGLIT) EatToken STRINGLIT SKIP  /  (!')' EatToken)*
Err_018         <-  &(EatToken ')') EatToken ')' SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_019         <-  &(EatToken STRINGLIT) EatToken STRINGLIT SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_020         <-  &(EatToken ('(' STRINGLIT^Err_017 ')'^Err_018  /  STRINGLIT^Err_019)) EatToken ('(' STRINGLIT^Err_017 ')'^Err_018  /  STRINGLIT^Err_019) SKIP  /  (!('record'  /  'local'  /  'function'  /  NAME  /  !.) EatToken)*
Err_021         <-  &(EatToken rettype) EatToken rettype SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_022         <-  ''
Err_022_Rec     <-  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_023         <-  &(EatToken param) EatToken param SKIP  /  (!')' EatToken)*
Err_024         <-  ''
Err_024_Rec     <-  (!')' EatToken)*
Err_025         <-  ''
Err_025_Rec     <-  (!')' EatToken)*
Err_026         <-  &(EatToken ':') EatToken ':' SKIP  /  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_027         <-  &(EatToken type) EatToken type SKIP  /  (!(','  /  ')') EatToken)*
Err_028         <-  ''
Err_028_Rec     <-  (!'end' EatToken)*
Err_029         <-  &(EatToken ':') EatToken ':' SKIP  /  (!('{'  /  'value'  /  'string'  /  'nil'  /  'integer'  /  'float'  /  'boolean'  /  NAME  /  '(') EatToken)*
Err_030         <-  &(EatToken type) EatToken type SKIP  /  (!('end'  /  NAME  /  ';') EatToken)*
Err_031         <-  ''
Err_031_Rec     <-  (!('end'  /  NAME) EatToken)*
Err_032         <-  &(EatToken exp) EatToken exp SKIP  /  (!'do' EatToken)*
Err_033         <-  &(EatToken 'do') EatToken 'do' SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_034         <-  &(EatToken 'end') EatToken 'end' SKIP  /  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_035         <-  &(EatToken 'until') EatToken 'until' SKIP  /  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_036         <-  &(EatToken exp) EatToken exp SKIP  /  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_037         <-  &(EatToken exp) EatToken exp SKIP  /  (!'then' EatToken)*
Err_038         <-  &(EatToken 'then') EatToken 'then' SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_039         <-  &(EatToken 'end') EatToken 'end' SKIP  /  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_040         <-  &(EatToken decl) EatToken decl SKIP  /  (!'=' EatToken)*
Err_041         <-  &(EatToken '=') EatToken '=' SKIP  /  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_042         <-  &(EatToken exp) EatToken exp SKIP  /  (!',' EatToken)*
Err_043         <-  &(EatToken ',') EatToken ',' SKIP  /  (!('~'  /  '{'  /  'true'  /  'not'  /  'nil'  /  'false'  /  STRINGLIT  /  NUMBER  /  NAME  /  '-'  /  '('  /  '#') EatToken)*
Err_044         <-  &(EatToken exp) EatToken exp SKIP  /  (!('do'  /  ',') EatToken)*
Err_045         <-  &(EatToken exp) EatToken exp SKIP  /  (!'do' EatToken)*
Err_046         <-  ''
Err_046_Rec     <-  (!'do' EatToken)*
Err_047         <-  &(EatToken 'do') EatToken 'do' SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_048         <-  &(EatToken 'end') EatToken 'end' SKIP  /  (!('while'  /  'until'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_049         <-  ''
Err_049_Rec     <-  (!('end'  /  'else') EatToken)*
Err_050         <-  &(EatToken exp) EatToken exp SKIP  /  (!'then' EatToken)*
Err_051         <-  &(EatToken 'then') EatToken 'then' SKIP  /  (!('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ';'  /  '(') EatToken)*
Err_052         <-  ''
Err_052_Rec     <-  (!'end' EatToken)*
Err_053         <-  ''
Err_053_Rec     <-  (!('until'  /  'end'  /  'elseif'  /  'else'  /  ';') EatToken)*
Err_054         <-  ''
Err_054_Rec     <-  (!('until'  /  'end'  /  'elseif'  /  'else') EatToken)*
Err_055         <-  &(EatToken e2) EatToken e2 SKIP  /  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_056         <-  &(EatToken e3) EatToken e3 SKIP  /  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_057         <-  &(EatToken e4) EatToken e4 SKIP  /  (!('}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_058         <-  &(EatToken e5) EatToken e5 SKIP  /  (!('~='  /  '}'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_059         <-  &(EatToken e6) EatToken e6 SKIP  /  (!('~='  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_060         <-  &(EatToken e7) EatToken e7 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  !.) EatToken)*
Err_061         <-  &(EatToken e8) EatToken e8 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_062         <-  &(EatToken e8) EatToken e8 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_063         <-  &(EatToken e10) EatToken e10 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  ','  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_064         <-  &(EatToken e11) EatToken e11 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '..'  /  '-'  /  ','  /  '+'  /  ')'  /  '('  /  '&'  /  !.) EatToken)*
Err_065         <-  &(EatToken e11) EatToken e11 SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_066         <-  &(EatToken exp) EatToken exp SKIP  /  (!']' EatToken)*
Err_067         <-  &(EatToken ']') EatToken ']' SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_068         <-  &(EatToken NAME) EatToken NAME SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'as'  /  'and'  /  STRINGLIT  /  NAME  /  '^'  /  ']'  /  '['  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '//'  /  '/'  /  '..'  /  '.'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
Err_069         <-  &(EatToken type) EatToken type SKIP  /  (!('~='  /  '~'  /  '}'  /  '|'  /  'while'  /  'until'  /  'then'  /  'return'  /  'repeat'  /  'record'  /  'or'  /  'local'  /  'if'  /  'function'  /  'for'  /  'end'  /  'elseif'  /  'else'  /  'do'  /  'and'  /  NAME  /  '^'  /  ']'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  '//'  /  '/'  /  '..'  /  '-'  /  ','  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '%%'  /  !.) EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'titan', p)

util.testNoRec(dir .. '/test/no/', 'titan', p)

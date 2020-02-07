local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign  /  !(!.) %{Err_001} .)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_002 '('^Err_003 paramlist ')'^Err_004 rettypeopt block 'end'^Err_005
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_006 recordfields^Err_007 'end'^Err_008
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT^Err_011)^Err_012
foreign         <-  'local' NAME^Err_013 '='^Err_014 'foreign'^Err_015 'import'^Err_016 ('(' STRINGLIT^Err_017 ')'^Err_018  /  STRINGLIT^Err_019)^Err_020
rettypeopt      <-  (':' rettype^Err_021  /  !('while'  /  'return'  /  'repeat'  /  'local'  /  'if'  /  'for'  /  'end'  /  'do'  /  NAME  /  ';'  /  '(') %{Err_022} .)?
paramlist       <-  (param (',' param^Err_023  /  !')' %{Err_024} .)*  /  !')' %{Err_025} .)?
param           <-  NAME ':'^Err_026 type^Err_027
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  (recordfield  /  !('end'  /  NAME) %{Err_028} .)+
recordfield     <-  NAME ':'^Err_029 type^Err_030 (';'  /  !('end'  /  NAME) %{Err_031} .)?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_032 'do'^Err_033 block 'end'^Err_034  /  'repeat' block 'until'^Err_035 exp^Err_036  /  'if' exp^Err_037 'then'^Err_038 block elseifstats elseopt 'end'^Err_039  /  'for' decl^Err_040 '='^Err_041 exp^Err_042 ','^Err_043 exp^Err_044 (',' exp^Err_045  /  !'do' %{Err_046} .)? 'do'^Err_047 block 'end'^Err_048  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  (elseifstat  /  !('end'  /  'else') %{Err_049} .)*
elseifstat      <-  'elseif' exp^Err_050 'then'^Err_051 block
elseopt         <-  ('else' block  /  !'end' %{Err_052} .)?
returnstat      <-  'return' (explist  /  !('until'  /  'end'  /  'elseif'  /  'else'  /  ';') %{Err_053} .)? (';'  /  !('until'  /  'end'  /  'elseif'  /  'else') %{Err_054} .)?
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
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'titan', p)

util.testNo(dir .. '/test/no/', 'titan', p)

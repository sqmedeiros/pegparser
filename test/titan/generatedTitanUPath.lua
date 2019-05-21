local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Does not need to remove labels manually

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_005 recordfields^Err_006 'end'^Err_007
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')'  /  STRINGLIT)
foreign         <-  'local' NAME '=' 'foreign' 'import'^Err_008 ('(' STRINGLIT^Err_009 ')'^Err_010  /  STRINGLIT)^Err_011
rettypeopt      <-  (':' rettype^Err_012)?
paramlist       <-  (param (',' param^Err_013)*)?
param           <-  NAME ':'^Err_014 type^Err_015
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_016
recordfield     <-  NAME ':'^Err_017 type^Err_018 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_019 'do'^Err_020 block 'end'^Err_021  /  'repeat' block 'until'^Err_022 exp^Err_023  /  'if' exp^Err_024 'then'^Err_025 block elseifstats elseopt 'end'^Err_026  /  'for' decl^Err_027 '='^Err_028 exp^Err_029 ','^Err_030 exp^Err_031 (',' exp^Err_032)? 'do'^Err_033 block 'end'^Err_034  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_035 'then'^Err_036 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_037)*
e2              <-  e3 ('and' e3^Err_038)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_039)*
e4              <-  e5 ('|' e5^Err_040)*
e5              <-  e6 ('~' !'=' e6)*
e6              <-  e7 ('&' e7^Err_041)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_042)*
e8              <-  e9 ('..' e8^Err_043)?
e9              <-  e10 (('+'  /  '-') e10)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_044)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_045)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_046 ']'^Err_047  /  '.' !'.' NAME^Err_048
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_049  /  simpleexp
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

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNo(dir, 'titan', p)

local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Added 57 labels
-- Did not have to remove rules manually

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_005 recordfields^Err_006 'end'^Err_007
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')'  /  STRINGLIT)
foreign         <-  'local' NAME^Err_008 '='^Err_009 'foreign'^Err_010 'import'^Err_011 ('(' STRINGLIT^Err_012 ')'^Err_013  /  STRINGLIT)^Err_014
rettypeopt      <-  (':' rettype^Err_015)?
paramlist       <-  (param (',' param^Err_016)*)?
param           <-  NAME ':'^Err_017 type^Err_018
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl^Err_019)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_020
recordfield     <-  NAME ':'^Err_021 type^Err_022 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_023  /  'while' exp^Err_024 'do'^Err_025 block 'end'^Err_026  /  'repeat' block 'until'^Err_027 exp^Err_028  /  'if' exp^Err_029 'then'^Err_030 block elseifstats elseopt 'end'^Err_031  /  'for' decl^Err_032 '='^Err_033 exp^Err_034 ','^Err_035 exp^Err_036 (',' exp^Err_037)? 'do'^Err_038 block 'end'^Err_039  /  'local' decllist^Err_040 '='^Err_041 explist^Err_042  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_043 'then'^Err_044 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_045)*
e2              <-  e3 ('and' e3^Err_046)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_047)*
e4              <-  e5 ('|' e5^Err_048)*
e5              <-  e6 ('~' !'=' e6)*
e6              <-  e7 ('&' e7^Err_049)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_050)*
e8              <-  e9 ('..' e8^Err_051)?
e9              <-  e10 (('+'  /  '-') e10)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_052)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_053)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_054 ']'^Err_055  /  '.' !'.' NAME^Err_056
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_057  /  simpleexp
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

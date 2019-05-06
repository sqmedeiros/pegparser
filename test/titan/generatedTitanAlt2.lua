local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Does not need to remove labels manually

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_001 recordfields^Err_002 'end'^Err_003
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')'  /  STRINGLIT)
foreign         <-  'local' NAME^Err_004 '='^Err_005 'foreign'^Err_006 'import'^Err_007 ('(' STRINGLIT^Err_008 ')'^Err_009  /  STRINGLIT)^Err_010
rettypeopt      <-  (':' rettype)?
paramlist       <-  (param (',' param)*)?
param           <-  NAME ':'^Err_011 type^Err_012
decl            <-  NAME (':' type)?
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_013 type^Err_014 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_015  /  'while' exp^Err_016 'do'^Err_017 block 'end'^Err_018  /  'repeat' block 'until'^Err_019 exp^Err_020  /  'if' exp^Err_021 'then'^Err_022 block elseifstats elseopt 'end'^Err_023  /  'for' decl^Err_024 '='^Err_025 exp^Err_026 ','^Err_027 exp^Err_028 (',' exp^Err_029)? 'do'^Err_030 block 'end'^Err_031  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_032 'then'^Err_033 block
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
expsuffix       <-  funcargs  /  ':' NAME^Err_034 funcargs^Err_035  /  '[' exp^Err_036 ']'^Err_037  /  '.' !'.' NAME^Err_038
prefixexp       <-  NAME  /  '(' exp^Err_039 ')'^Err_040
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
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/titan/test/yes/'
util.testYes(dir, 'titan', p)

local dir = lfs.currentdir() .. '/test/titan/test/no/'
util.testNo(dir, 'titan', p)

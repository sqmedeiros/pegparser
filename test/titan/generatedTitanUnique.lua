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
foreign         <-  'local' NAME '=' 'foreign' 'import'^Err_008 ('(' STRINGLIT ')'  /  STRINGLIT)^Err_009
rettypeopt      <-  (':' rettype^Err_010)?
paramlist       <-  (param (',' param^Err_011)*)?
param           <-  NAME ':' type
decl            <-  NAME (':' type^Err_012)?
decllist        <-  decl (',' decl^Err_013)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':' type ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_014 'do'^Err_015 block 'end'^Err_016  /  'repeat' block 'until'^Err_017 exp^Err_018  /  'if' exp^Err_019 'then'^Err_020 block elseifstats elseopt 'end'^Err_021  /  'for' decl^Err_022 '='^Err_023 exp^Err_024 ','^Err_025 exp^Err_026 (',' exp^Err_027)? 'do'^Err_028 block 'end'^Err_029  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_030 'then'^Err_031 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_032)*
e2              <-  e3 ('and' e3^Err_033)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_034)*
e4              <-  e5 ('|' e5^Err_035)*
e5              <-  e6 ('~' !'=' e6^Err_036)*
e6              <-  e7 ('&' e7^Err_037)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_038)*
e8              <-  e9 ('..' e8^Err_039)?
e9              <-  e10 (('+'  /  '-') e10^Err_040)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_041)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_042)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_043 ']'^Err_044  /  '.' !'.' NAME^Err_045
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_046  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var^Err_047)*
funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_048)*
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

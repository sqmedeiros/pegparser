local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Added 57 labels
-- Did not have to remove rules manually
-- UPathPref + Deep = 63

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
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
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_022
recordfield     <-  NAME ':'^Err_023 type^Err_024 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_025 'do'^Err_026 block 'end'^Err_027  /  'repeat' block 'until'^Err_028 exp^Err_029  /  'if' exp^Err_030 'then'^Err_031 block elseifstats elseopt 'end'^Err_032  /  'for' decl^Err_033 '='^Err_034 exp^Err_035 ','^Err_036 exp^Err_037 (',' exp^Err_038)? 'do'^Err_039 block 'end'^Err_040  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_041 'then'^Err_042 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_043)*
e2              <-  e3 ('and' e3^Err_044)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_045)*
e4              <-  e5 ('|' e5^Err_046)*
e5              <-  e6 ('~' !'=' e6^Err_047)*
e6              <-  e7 ('&' e7^Err_048)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_049)*
e8              <-  e9 ('..' e8^Err_050)?
e9              <-  e10 (('+'  /  '-') e10^Err_051)*
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

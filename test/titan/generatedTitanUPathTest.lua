local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Added 52 labels
-- Did not have to remove rules manually

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
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'^Err_022
typelist        <-  '(' (type (',' type^Err_023)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_024
recordfield     <-  NAME ':'^Err_025 type^Err_026 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_027 'do'^Err_028 block 'end'^Err_029  /  'repeat' block 'until'^Err_030 exp^Err_031  /  'if' exp^Err_032 'then'^Err_033 block elseifstats elseopt 'end'^Err_034  /  'for' decl^Err_035 '='^Err_036 exp^Err_037 ','^Err_038 exp^Err_039 (',' exp^Err_040)? 'do'^Err_041 block 'end'^Err_042  /  'local' decllist '='^Err_043 explist^Err_044  /  varlist '=' explist^Err_046  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_047 'then'^Err_048 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_049)*
e2              <-  e3 ('and' e3^Err_051)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_053)*
e4              <-  e5 ('|' e5^Err_055)*
e5              <-  e6 ('~' !'=' e6^Err_057)*
e6              <-  e7 ('&' e7^Err_059)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_061)*
e8              <-  e9 ('..' e8^Err_063)?
e9              <-  e10 (('+'  /  '-') e10^Err_065)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_067)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_070)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_071 ']'^Err_072  /  '.' !'.' NAME^Err_073
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  (simpleexp 'as' type^Err_074  /  simpleexp)
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  (suffixedexp  /  NAME !expsuffix)
varlist         <-  var (',' var^Err_077)*
funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_078)*
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

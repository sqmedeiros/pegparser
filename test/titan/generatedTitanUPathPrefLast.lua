local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

-- Added 63 labels
-- Did not have to remove rules manually
-- UPathPrefLast + Deep = 63

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
decllist        <-  decl^Err_022 (',' decl^Err_023)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_024
recordfield     <-  NAME ':'^Err_025 type^Err_026 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_027  /  'while' exp^Err_028 'do'^Err_029 block 'end'^Err_030  /  'repeat' block 'until'^Err_031 exp^Err_032  /  'if' exp^Err_033 'then'^Err_034 block elseifstats elseopt 'end'^Err_035  /  'for' decl^Err_036 '='^Err_037 exp^Err_038 ','^Err_039 exp^Err_040 (',' exp^Err_041)? 'do'^Err_042 block 'end'^Err_043  /  'local' decllist^Err_044 '='^Err_045 explist^Err_046  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_047 'then'^Err_048 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_049)*
e2              <-  e3 ('and' e3^Err_050)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_051)*
e4              <-  e5 ('|' e5^Err_052)*
e5              <-  e6 ('~' !'=' e6^Err_053)*
e6              <-  e7 ('&' e7^Err_054)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_055)*
e8              <-  e9 ('..' e8^Err_056)?
e9              <-  e10 (('+'  /  '-') e10^Err_057)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_058)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_059)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_060 ']'^Err_061  /  '.' !'.' NAME^Err_062
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_063  /  simpleexp
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

util.setVerbose(true)
util.testNo(dir .. '/test/no/', 'titan', p)

local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

-- Added 52 labels
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
decllist        <-  decl (',' decl)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+^Err_019
recordfield     <-  NAME ':'^Err_020 type^Err_021 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'  /  'while' exp^Err_022 'do'^Err_023 block 'end'^Err_024  /  'repeat' block 'until'^Err_025 exp^Err_026  /  'if' exp^Err_027 'then'^Err_028 block elseifstats elseopt 'end'^Err_029  /  'for' decl^Err_030 '='^Err_031 exp^Err_032 ','^Err_033 exp^Err_034 (',' exp^Err_035)? 'do'^Err_036 block 'end'^Err_037  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_038 'then'^Err_039 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_040)*
e2              <-  e3 ('and' e3^Err_041)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_042)*
e4              <-  e5 ('|' e5^Err_043)*
e5              <-  e6 ('~' !'=' e6)*
e6              <-  e7 ('&' e7^Err_044)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_045)*
e8              <-  e9 ('..' e8^Err_046)?
e9              <-  e10 (('+'  /  '-') e10)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_047)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_048)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp^Err_049 ']'^Err_050  /  '.' !'.' NAME^Err_051
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_052  /  simpleexp
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

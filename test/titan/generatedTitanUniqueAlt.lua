local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Does not need to remove labels manually

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_500 '('^Err_501 paramlist ')'^Err_502 rettypeopt block 'end'^Err_503
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_504 recordfields^Err_505 'end'^Err_506
localopt        <-  'local'?
import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')'  /  STRINGLIT)
foreign         <-  'local' NAME^Err_507 '='^Err_508 'foreign'^Err_509 'import'^Err_510 ('(' STRINGLIT^Err_511 ')'^Err_512  /  STRINGLIT)^Err_513
rettypeopt      <-  (':' rettype^Err_514)?
paramlist       <-  (param (',' param^Err_515)*)?
param           <-  NAME ':'^Err_516 type^Err_517
decl            <-  NAME (':' type^Err_518)?
decllist        <-  decl (',' decl^Err_519)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type '}'
typelist        <-  '(' (type (',' type)*)? ')'
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_520 type^Err_521 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_522  /  'while' exp^Err_523 'do'^Err_524 block 'end'^Err_525  /  'repeat' block 'until'^Err_526 exp^Err_527  /  'if' exp^Err_528 'then'^Err_529 block elseifstats elseopt 'end'^Err_530  /  'for' decl^Err_531 '='^Err_532 exp^Err_533 ','^Err_534 exp^Err_535 (',' exp^Err_536)? 'do'^Err_537 block 'end'^Err_538  /  'local' decllist^Err_539 '='^Err_540 explist^Err_541  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_542 'then'^Err_543 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_544)*
e2              <-  e3 ('and' e3^Err_545)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_546)*
e4              <-  e5 ('|' e5^Err_547)*
e5              <-  e6 ('~' !'=' e6)*
e6              <-  e7 ('&' e7^Err_548)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_549)*
e8              <-  e9 ('..' e8^Err_550)?
e9              <-  e10 (('+'  /  '-') e10)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_551)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_552)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME^Err_553 funcargs^Err_554  /  '[' exp^Err_555 ']'^Err_556  /  '.' !'.' NAME^Err_557
prefixexp       <-  NAME  /  '(' exp ')'
castexp         <-  simpleexp 'as' type^Err_558  /  simpleexp
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

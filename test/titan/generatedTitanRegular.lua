local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

-- Remove Err_006 ('exp' in rule toplevelvar), Err_012 ('import' in rule import)

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '='^Err_005 exp
toplevelrecord  <-  'record' NAME^Err_007 recordfields^Err_008 'end'^Err_009
localopt        <-  'local'?
import          <-  'local' NAME^Err_010 '='^Err_011 'import' ('(' STRINGLIT^Err_013 ')'^Err_014  /  STRINGLIT)^Err_015
foreign         <-  'local' NAME^Err_016 '='^Err_017 'foreign'^Err_018 'import'^Err_019 ('(' STRINGLIT^Err_020 ')'^Err_021  /  STRINGLIT)^Err_022
rettypeopt      <-  (':' rettype^Err_023)?
paramlist       <-  (param (',' param^Err_024)*)?
param           <-  NAME ':'^Err_025 type^Err_026
decl            <-  NAME (':' type^Err_027)?
decllist        <-  decl (',' decl^Err_028)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type^Err_029 '}'^Err_030
typelist        <-  '(' (type (',' type^Err_031)*)? ')'^Err_032
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->'^Err_033 rettype^Err_034  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_035 type^Err_036 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_037  /  'while' exp^Err_038 'do'^Err_039 block 'end'^Err_040  /  'repeat' block 'until'^Err_041 exp^Err_042  /  'if' exp^Err_043 'then'^Err_044 block elseifstats elseopt 'end'^Err_045  /  'for' decl^Err_046 '='^Err_047 exp^Err_048 ','^Err_049 exp^Err_050 (',' exp^Err_051)? 'do'^Err_052 block 'end'^Err_053  /  'local' decllist^Err_054 '='^Err_055 explist^Err_056  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_057 'then'^Err_058 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_059)*
e2              <-  e3 ('and' e3^Err_060)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_061)*
e4              <-  e5 ('|' e5^Err_062)*
e5              <-  e6 ('~' !'=' e6^Err_063)*
e6              <-  e7 ('&' e7^Err_064)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_065)*
e8              <-  e9 ('..' e8^Err_066)?
e9              <-  e10 (('+'  /  '-') e10^Err_067)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_068)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_069)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME^Err_070 funcargs^Err_071  /  '[' exp^Err_072 ']'^Err_073  /  '.' !'.' NAME^Err_074
prefixexp       <-  NAME  /  '(' exp^Err_075 ')'^Err_076
castexp         <-  simpleexp 'as' type  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var^Err_077)*
funcargs        <-  '(' explist? ')'^Err_078  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_079)*
initlist        <-  '{' fieldlist? '}'^Err_080
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
print("Original Grammar")
print(pretty.printg(g), '\n')

print("Regular Annotation (SBLP paper)")
local glabRegular = recovery.addlab(g, true, false)
print(pretty.printg(glabRegular, true), '\n')

print("Conservative Annotation (Hard)")
local glabHard = recovery.addlab(g, true, true)
print(pretty.printg(glabHard, true), '\n')

print("Conservative Annotation (Soft)")
local glabSoft = recovery.addlab(g, true, 'soft')
print(pretty.printg(glabSoft, true), '\n')

local p = coder.makeg(g)

local dir = lfs.currentdir() .. '/test/titan/test/yes/'	
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'titan' + 1) == 'titan' then
		print("Yes: ", file)
		local f = io.open(dir .. file)
		local s = f:read('a')
		f:close()
		local r, lab, pos = p:match(s)
		local line, col = '', ''
		if not r then
			line, col = re.calcline(s, pos)
		end
		assert(r ~= nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end

local dir = lfs.currentdir() .. '/test/titan/test/no/'	
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'titan' + 1) == 'titan' then
		print("No: ", file)
		local f = io.open(dir .. file)
		local s = f:read('a')
		f:close()
		local r, lab, pos = p:match(s)
		io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
		local line, col = '', ''
		if not r then
			line, col = re.calcline(s, pos)
			io.write(' line: ' .. line .. ' col: ' .. col)
		end
		io.write('\n')
		assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end


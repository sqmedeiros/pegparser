local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

-- Tirar Err_006 (em toplevelvar), Err_012 (em import)

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME^Err_001 '('^Err_002 paramlist ')'^Err_003 rettypeopt block 'end'^Err_004
toplevelvar     <-  localopt decl '='^Err_005 exp
toplevelrecord  <-  'record' NAME^Err_007 recordfields^Err_008 'end'^Err_009
localopt        <-  'local'?
import          <-  'local' NAME^Err_010 '='^Err_011 'import' ('(' STRINGLIT^Err_013 ')'^Err_014  /  STRINGLIT)^Err_015
foreign         <-  'local' NAME^Err_016 '='^Err_017 'foreign'^Err_018 ('(' STRINGLIT^Err_019 ')'^Err_020  /  STRINGLIT)^Err_021
rettypeopt      <-  (':' rettype^Err_022)?
paramlist       <-  (param (',' param^Err_023)*)?
param           <-  NAME ':'^Err_024 type^Err_025
decl            <-  NAME (':' type^Err_026)?
decllist        <-  decl (',' decl^Err_027)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type^Err_028 '}'^Err_029
typelist        <-  '(' (type (',' type^Err_030)*)? ')'^Err_031
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->'^Err_032 rettype^Err_033  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_034 type^Err_035 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_036  /  'while' exp^Err_037 'do'^Err_038 block 'end'^Err_039  /  'repeat' block 'until'^Err_040 exp^Err_041  /  'if' exp^Err_042 'then'^Err_043 block elseifstats elseopt 'end'^Err_044  /  'for' decl^Err_045 '='^Err_046 exp^Err_047 ','^Err_048 exp^Err_049 (',' exp^Err_050)? 'do'^Err_051 block 'end'^Err_052  /  'local' decllist^Err_053 '='^Err_054 explist^Err_055  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_056 'then'^Err_057 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_058)*
e2              <-  e3 ('and' e3^Err_059)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_060)*
e4              <-  e5 ('|' e5^Err_061)*
e5              <-  e6 ('~' !'=' e6^Err_062)*
e6              <-  e7 ('&' e7^Err_063)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_064)*
e8              <-  e9 ('..' e8^Err_065)?
e9              <-  e10 (('+'  /  '-') e10^Err_066)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_067)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_068)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME^Err_069 funcargs^Err_070  /  '[' exp^Err_071 ']'^Err_072  /  '.' !'.' NAME^Err_073
prefixexp       <-  NAME  /  '(' exp^Err_074 ')'^Err_075
castexp         <-  simpleexp 'as' type  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var^Err_076)*
funcargs        <-  '(' explist? ')'^Err_077  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_078)*
initlist        <-  '{' fieldlist? '}'^Err_079
fieldlist       <-  field (fieldsep field)* fieldsep?
field           <-  (NAME '=')? exp
fieldsep        <-  ';'  /  ','
STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
RESERVED        <-  ('and'  /  'as'  /  'boolean'  /  'break'  /  'do'  /  'else'  /  'elseif'  /  'end'  /  'float'  /  'foreign'  /  'for'  /  'false'  /  'function'  /  'goto'  /  'if'  /  'import'  /  'integer'  /  'in'  /  'local'  /  'nil'  /  'not'  /  'or'  /  'record'  /  'repeat'  /  'return'  /  'string'  /  'then'  /  'true'  /  'until'  /  'value'  /  'while') ![a-zA-Z_0-9]
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


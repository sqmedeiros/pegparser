local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

-- Tirar Err_006 (em import)

g = [[
program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* !.
toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
toplevelvar     <-  localopt decl '=' exp
toplevelrecord  <-  'record' NAME^Err_001 recordfields^Err_002 'end'^Err_003
localopt        <-  'local'?
import          <-  'local' NAME^Err_004 '='^Err_005 'import' ('(' STRINGLIT^Err_007 ')'^Err_008  /  STRINGLIT)^Err_009
foreign         <-  'local' NAME^Err_010 '='^Err_011 'foreign'^Err_012 ('(' STRINGLIT^Err_013 ')'^Err_014  /  STRINGLIT)^Err_015
rettypeopt      <-  (':' rettype^Err_016)?
paramlist       <-  (param (',' param^Err_017)*)?
param           <-  NAME ':'^Err_018 type^Err_019
decl            <-  NAME (':' type^Err_020)?
decllist        <-  decl (',' decl^Err_021)*
simpletype      <-  'nil'  /  'boolean'  /  'integer'  /  'float'  /  'string'  /  'value'  /  NAME  /  '{' type^Err_022 '}'^Err_023
typelist        <-  '(' (type (',' type^Err_024)*)? ')'^Err_025
rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
type            <-  typelist '->'^Err_026 rettype^Err_027  /  simpletype '->' rettype  /  simpletype
recordfields    <-  recordfield+
recordfield     <-  NAME ':'^Err_028 type^Err_029 ';'?
block           <-  statement* returnstat?
statement       <-  ';'  /  'do' block 'end'^Err_030  /  'while' exp^Err_031 'do'^Err_032 block 'end'^Err_033  /  'repeat' block 'until'^Err_034 exp^Err_035  /  'if' exp^Err_036 'then'^Err_037 block elseifstats elseopt 'end'^Err_038  /  'for' decl^Err_039 '='^Err_040 exp^Err_041 ','^Err_042 exp^Err_043 (',' exp^Err_044)? 'do'^Err_045 block 'end'^Err_046  /  'local' decllist^Err_047 '='^Err_048 explist^Err_049  /  varlist '=' explist  /  suffixedexp
elseifstats     <-  elseifstat*
elseifstat      <-  'elseif' exp^Err_050 'then'^Err_051 block
elseopt         <-  ('else' block)?
returnstat      <-  'return' explist? ';'?
exp             <-  e1
e1              <-  e2 ('or' e2^Err_052)*
e2              <-  e3 ('and' e3^Err_053)*
e3              <-  e4 (('=='  /  '~='  /  '<='  /  '>='  /  '<'  /  '>') e4^Err_054)*
e4              <-  e5 ('|' e5^Err_055)*
e5              <-  e6 ('~' !'=' e6^Err_056)*
e6              <-  e7 ('&' e7^Err_057)*
e7              <-  e8 (('<<'  /  '>>') e8^Err_058)*
e8              <-  e9 ('..' e8^Err_059)?
e9              <-  e10 (('+'  /  '-') e10^Err_060)*
e10             <-  e11 (('*'  /  '%%'  /  '/'  /  '//') e11^Err_061)*
e11             <-  ('not'  /  '#'  /  '-'  /  '~')* e12
e12             <-  castexp ('^' e11^Err_062)?
suffixedexp     <-  prefixexp expsuffix+
expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp ']'  /  '.' !'.' NAME
prefixexp       <-  NAME  /  '(' exp^Err_063 ')'^Err_064
castexp         <-  simpleexp 'as' type  /  simpleexp
simpleexp       <-  'nil'  /  'false'  /  'true'  /  NUMBER  /  STRINGLIT  /  initlist  /  suffixedexp  /  prefixexp
var             <-  suffixedexp  /  NAME !expsuffix
varlist         <-  var (',' var^Err_065)*
funcargs        <-  '(' explist? ')'^Err_066  /  initlist  /  STRINGLIT
explist         <-  exp (',' exp^Err_067)*
initlist        <-  '{' fieldlist? '}'^Err_068
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


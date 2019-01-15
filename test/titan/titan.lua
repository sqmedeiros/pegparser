local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

g = [[
  program         <-  SKIP (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import / foreign)* !.
  toplevelfunc    <-  localopt 'function' NAME '(' paramlist ')' rettypeopt block 'end'
  ]]--predicate in 'toplevalvar' is related to the use of labels
  --toplevelvar     <-  <localopt> <decl> '=' !('import' / 'foreign') <exp>
  ..[[
  toplevelvar     <-  localopt decl '=' exp
  toplevelrecord  <-  'record' NAME recordfields 'end'
  localopt        <-  'local'?
  ]]--predicate in 'import' is related to the use of labels
  --import          <-  'local' <NAME> '=' !'foreign' 'import' ('(' <STRINGLIT> ')' / <STRINGLIT>)
  ..[[
  import          <-  'local' NAME '=' 'import' ('(' STRINGLIT ')' / STRINGLIT)
  foreign         <-  'local' NAME '=' 'foreign' 'import' ('(' STRINGLIT ')' / STRINGLIT)
  rettypeopt      <-  (':' rettype)?
  paramlist       <-  (param (',' param)*)?
  param           <-  NAME ':' type
  decl            <-  NAME (':' type)?
  decllist        <-  decl (',' decl)*
  simpletype      <-  'nil' / 'boolean' / 'integer' / 'float' / 'string' / 'value' / NAME / '{' type '}'
  typelist        <-  '(' (type (',' type)*)? ')'
  rettype         <-  typelist '->' rettype  /  simpletype '->' rettype  /  typelist  /  simpletype
  type            <-  typelist '->' rettype  /  simpletype '->' rettype  /  simpletype
  recordfields    <-  recordfield+
  recordfield     <-  NAME ':' type ';'?
  block           <-  statement* returnstat?
  statement       <-  ';'  /  'do' block 'end'  /  'while' exp 'do' block 'end'  /  'repeat' block 'until' exp  /  'if' exp 'then' block elseifstats elseopt 'end'  /  'for' decl '=' exp ',' exp (',' exp)? 'do' block 'end'  /  'local' decllist '=' explist  /  varlist '=' explist  /  suffixedexp
  elseifstats     <-  elseifstat*
  elseifstat      <-  'elseif' exp 'then' block
  elseopt         <-  ('else' block)?
  returnstat      <-  'return' explist? ';'?
  exp             <-  e1
  e1              <-  e2  ('or'  e2)*
  e2              <-  e3  ('and' e3)*
  e3              <-  e4  (('==' / '~=' / '<=' / '>=' / '<' / '>') e4)*
  e4              <-  e5  ('|'   e5)*
  e5              <-  e6  ('~'!'='   e6)*
  e6              <-  e7  ('&'   e7)*
  e7              <-  e8  (('<<' / '>>') e8)*
  e8              <-  e9  ('..'  e8)?
  e9              <-  e10 (('+' / '-') e10)*
  e10             <-  e11 (('*' / '%%' / '/' / '//') e11)*
  e11             <-  ('not' / '#' / '-' / '~')* e12
  e12             <-  castexp ('^' e11)? 
  suffixedexp     <-  prefixexp expsuffix+
  expsuffix       <-  funcargs  /  ':' NAME funcargs  /  '[' exp ']'  /  '.'!'.' NAME
  prefixexp       <-  NAME  /  '(' exp ')'
  castexp         <-  simpleexp 'as' type  /  simpleexp
  simpleexp       <-  'nil' / 'false' / 'true' / NUMBER / STRINGLIT / initlist / suffixedexp / prefixexp
  var             <-  suffixedexp  /  NAME !expsuffix
  varlist         <-  var (',' var)*               
  funcargs        <-  '(' explist? ')'  /  initlist  /  STRINGLIT
  explist         <-  exp (',' exp)*
  initlist        <-  '{' fieldlist? '}' 
  ]]--predicate in 'fieldlist' is related to the use of labels
  --fieldlist       <-  <field> (<fieldsep> (<field> / !'}' %ExpFieldList)* <fieldsep>?
  ..[[fieldlist       <-  field (fieldsep field)* fieldsep?
  field           <-  (NAME '=')? exp
  fieldsep        <-  ';' / ','
  STRINGLIT       <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  RESERVED        <-  ('and'  / 'as' / 'boolean' / 'break' / 'do' / 'elseif' / 'else' / 'end' / 'float' / 'foreign' / 'for' / 'false'
                     / 'function' / 'goto' / 'if' / 'import' / 'integer' / 'in' / 'local' / 'nil' / 'not' / 'or'
                     / 'record' / 'repeat' / 'return' / 'string' / 'then' / 'true' / 'until' / 'value' / 'while') ![a-zA-Z_0-9]
  NAME            <-  !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  COMMENT         <- '--' (!%nl .)* ]]


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


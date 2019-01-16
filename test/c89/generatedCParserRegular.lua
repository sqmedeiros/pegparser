local m = require 'init'
local recovery = require 'recovery'
local pretty = require 'pretty'
local coder = require 'coder'
local lfs = require 'lfs'
local re = require 'relabel'
local first = require'first'

local function assertErr (p, s, lab)
  local r, l, pos = p:match(s)
  assert(not r, "Did not fail: r = " .. tostring(r))
  if lab then
    assert(l == lab, "Expected label '" .. tostring(lab) .. "' but got " .. tostring(l))
  end
end

local function assertOk(p, s)
  local r, l, pos = p:match(s)
  assert(r, 'Failed: label = ' .. tostring(l) .. ', pos = ' .. tostring(pos))
  assert(r == #s + 1, "Matched until " .. r)
end

-- Remove Err_001 ('function_def' in rule function_def)
-- Disable rule typedef_name, because its correct matching depends on semantic actions

local g =  m.match[[
translation_unit <-  SKIP external_decl+ !.
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl^Err_002
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /  'double'  /  'signed'  /  'unsigned'  /  typedef_name  /  'enum' ID? '{' enumerator (',' enumerator)* '}'  /  'enum' ID^Err_003  /  struct_or_union ID? '{' struct_decl+ '}'  /  struct_or_union ID^Err_004
type_qualifier  <-  'const'  /  'volatile'
struct_or_union <-  'struct'  /  'union'
init_declarator_list <-  init_declarator (',' init_declarator^Err_005)*
init_declarator <-  declarator '=' initializer  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /  spec_qualifier struct_decl^Err_006
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ':' const_exp  /  declarator
enumerator      <-  ID '=' const_exp  /  ID
declarator      <-  pointer? direct_declarator
direct_declarator <-  (ID  /  '(' declarator^Err_007 ')'^Err_008) ('[' const_exp? ']'^Err_009  /  '(' param_type_list ')'  /  '(' id_list? ')'^Err_010)*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...'^Err_011)?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID^Err_012)*
initializer     <-  '{' initializer^Err_013 (',' initializer)* ','? '}'^Err_014  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator^Err_015 ')'^Err_016 ('[' const_exp? ']'^Err_017  /  '(' param_type_list? ')'^Err_018)*
typedef_name    <-  ID [a-z]
stat            <-  ID ':' stat  /  'case' const_exp^Err_019 ':'^Err_020 stat^Err_021  /  'default' ':'^Err_022 stat^Err_023  /  exp? ';'  /  compound_stat  /  'if' '(' exp ')' stat 'else' stat  /  'if' '('^Err_024 exp^Err_025 ')'^Err_026 stat^Err_027  /  'switch' '('^Err_028 exp^Err_029 ')'^Err_030 stat^Err_031  /  'while' '('^Err_032 exp^Err_033 ')'^Err_034 stat^Err_035  /  'do' stat^Err_036 'while'^Err_037 '('^Err_038 exp^Err_039 ')'^Err_040 ';'^Err_041  /  'for' '('^Err_042 exp? ';'^Err_043 exp? ';'^Err_044 exp? ')'^Err_045 stat^Err_046  /  'goto' ID^Err_047 ';'^Err_048  /  'continue' ';'^Err_049  /  'break' ';'^Err_050  /  'return' exp? ';'^Err_051
compound_stat   <-  '{' decl* stat* '}'^Err_052
exp             <-  assignment_exp (',' assignment_exp^Err_053)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp  /  conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp ':' conditional_exp  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp^Err_054)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_055)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_056)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_057)*
and_exp         <-  equality_exp ('&' !'&' equality_exp^Err_058)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_059)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_060)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_061)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp^Err_062)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp^Err_063)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp^Err_064  /  '--' unary_exp^Err_065  /  unary_operator cast_exp^Err_066  /  'sizeof' (type_name  /  unary_exp)^Err_067  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp^Err_068 ']'^Err_069  /  '(' (assignment_exp (',' assignment_exp^Err_070)*)? ')'^Err_071  /  '.' ID^Err_072  /  '->' ID^Err_073  /  '++'  /  '--')*
primary_exp     <-  ID  /  STRING  /  constant  /  '(' exp^Err_074 ')'^Err_075
constant        <-  INT_CONST  /  CHAR_CONST  /  FLOAT_CONST  /  ENUMERATION_CONST
unary_operator  <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'
COMMENT         <-  '/*' (!'*/' .)* '*/'
INT_CONST       <-  ('0' [xX] XDIGIT+  /  !'0' DIGIT DIGIT*  /  '0' [0-8]*) ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
FLOAT_CONST     <-  '0x' (('.'  /  XDIGIT+  /  XDIGIT+  /  '.') ([eE] [-+]? XDIGIT+)? [lLfF]?  /  XDIGIT+ [eE] [-+]? XDIGIT+ [lLfF]?)  /  ('.'  /  DIGIT+  /  DIGIT+  /  '.') ([eE] [-+]? DIGIT+)? [lLfF]?  /  DIGIT+ [eE] [-+]? DIGIT+ [lLfF]?
XDIGIT          <-  [0-9a-fA-F]
DIGIT           <-  [0-9]
CHAR_CONST      <-  "'" (%nl  /  !"'" .) "'"
STRING          <-  '"' (%nl  /  !'"' .)* '"'
ESC_CHAR        <-  '\\' ('n'  /  't'  /  'v'  /  'b'  /  'r'  /  'f'  /  'a'  /  '\\'  /  '?'  /  "'"  /  '"'  /  [01234567] [01234567]? [01234567]?  /  'x' XDIGIT)
ENUMERATION_CONST <-  ID
ID              <-  !KEYWORDS [a-zA-Z_] [a-zA-Z_0-9]*
KEYWORDS        <-  'auto'  /  'double'  /  'int'  /  'struct'  /  'break'  /  'else'  /  'long'  /  'switch'  /  'case'  /  'enum'  /  'register'  /  'typedef'  /  'char'  /  'extern'  /  'return'  /  'union'  /  'const'  /  'float'  /  'short'  /  'unsigned'  /  'continue'  /  'for'  /  'signed'  /  'void'  /  'default'  /  'goto'  /  'sizeof'  /  'volatile'  /  'do'  /  'if'  /  'static'  /  'while'
]] 


local p = coder.makeg(g)

local dir = lfs.currentdir() .. '/test/c89/test/yes/'	
for file in lfs.dir(dir) do
	if file ~= '.' and file ~= '..' and string.sub(file, #file) == 'c' then
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

local dir = lfs.currentdir() .. '/test/c89/test/no/'	
for file in lfs.dir(dir) do
	if file ~= '.' and file ~= '..' and string.sub(file, #file) == 'c' then
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

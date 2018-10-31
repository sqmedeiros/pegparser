local m = require 'init'
local recovery = require 'recovery'
local pretty = require 'pretty'
local coder = require 'coder'
local lfs = require 'lfs'
local re = require 'relabel'

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


local tree, rules =  m.match[[
translation_unit <-  skip external_decl+ !.
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /  'double'  /  'signed'  /  'unsigned'  /  typedef_name  /  'enum' id? '{' enumerator (',' enumerator)* '}'  /  'enum' id^Err_001  /  struct_or_union id? '{' struct_decl+ '}'  /  struct_or_union id^Err_002
type_qualifier  <-  'const'  /  'volatile'
struct_or_union <-  'struct'  /  'union'
init_declarator_list <-  init_declarator (',' init_declarator)*
init_declarator <-  declarator '=' initializer  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /  spec_qualifier struct_decl^Err_003
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ';' const_exp  /  declarator
enumerator      <-  id '=' const_exp  /  id
declarator      <-  pointer? direct_declarator
direct_declarator <-  (id  /  '(' declarator ')') ('[' const_exp? ']'^Err_006  /  '(' param_type_list ')'  /  '(' id_list? ')'^Err_007)*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...'^Err_008)?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  id (',' id^Err_009)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator ')' ('[' const_exp? ']'  /  '(' param_type_list? ')')*
typedef_name    <-  id
stat            <-  id ':' stat  /  'case' const_exp^Err_010 ':'^Err_011 stat^Err_012  /  'default' ':'^Err_013 stat^Err_014  /  exp? ';'  /  compound_stat  /  'if' '(' exp ')' stat 'else' stat  /  'if' '('^Err_015 exp^Err_016 ')'^Err_017 stat^Err_018  /  'switch' '('^Err_019 exp^Err_020 ')'^Err_021 stat^Err_022  /  'while' '('^Err_023 exp^Err_024 ')'^Err_025 stat^Err_026  /  'do' stat^Err_027 'while'^Err_028 '('^Err_029 exp^Err_030 ')'^Err_031 ';'^Err_032  /  'for' '('^Err_033 exp? ';'^Err_034 exp? ';'^Err_035 exp? ')'^Err_036 stat^Err_037  /  'goto' id^Err_038 ';'^Err_039  /  'continue' ';'^Err_040  /  'break' ';'^Err_041  /  'return' exp? ';'^Err_042
compound_stat   <-  '{' decl* stat* '}'
exp             <-  assignment_exp (',' assignment_exp^Err_043)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp  /  conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp ':' conditional_exp  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp^Err_044)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_045)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_046)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_047)*
and_exp         <-  equality_exp ('&' !'&' equality_exp^Err_048)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_049)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_050)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_051)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp^Err_052)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp^Err_053)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp^Err_054  /  '--' unary_exp^Err_055  /  unary_operator cast_exp^Err_056  /  'sizeof' (type_name  /  unary_exp)^Err_057  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp^Err_058 ']'^Err_059  /  '(' (assignment_exp (',' assignment_exp^Err_060)*)? ')'^Err_061  /  '.' id^Err_062  /  '->' id^Err_063  /  '++'  /  '--')*
primary_exp     <-  id  /  string  /  constant  /  '(' exp^Err_064 ')'^Err_065
constant        <-  int_const  /  char_const  /  float_const  /  enumeration_const
unary_operator  <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'
comment         <-  '/*' (!'*/' .)* '*/'^Err_066
int_const       <-  ('0' [xX] xdigit+  /  !'0' digit digit*  /  '0' [0-8]*) ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
float_const     <-  '0x' (('.'  /  xdigit+  /  xdigit+  /  '.') ([eE] [-+]? xdigit+)? [lLfF]?  /  xdigit+ [eE] [-+]? xdigit+ [lLfF]?)^Err_067  /  ('.'  /  digit+  /  digit+  /  '.') ([eE] [-+]? digit+)? [lLfF]?  /  digit+ [eE] [-+]? digit+^Err_068 [lLfF]?
xdigit          <-  [0-9a-fA-F]
digit           <-  [0-9]
char_const      <-  "'" ('\n'  /  !"'" .)^Err_069 "'"^Err_070
string          <-  '"' ('\n'  /  !'"' .)* '"'^Err_071
esc_char        <-  '\\' ('n'  /  't'  /  'v'  /  'b'  /  'r'  /  'f'  /  'a'  /  '\\'  /  '?'  /  "'"  /  '"'  /  [01234567] [01234567]? [01234567]?  /  'x' xdigit^Err_072)^Err_073
enumeration_const <-  id
id              <-  !keywords [a-zA-Z_] [a-zA-Z_0-9]* skip
keywords        <-  'auto'  /  'double'  /  'int'  /  'struct'  /  'break'  /  'else'  /  'long'  /  'switch'  /  'case'  /  'enum'  /  'register'  /  'typedef'  /  'char'  /  'extern'  /  'return'  /  'union'  /  'const'  /  'float'  /  'short'  /  'unsigned'  /  'continue'  /  'for'  /  'signed'  /  'void'  /  'default'  /  'goto'  /  'sizeof'  /  'volatile'  /  'do'  /  'if'  /  'static'  /  'while'
Token           <-  keywords  /  id  /  string  /  constant  /  .
]] 


--print(tree, rules)                        
--print(pretty.printg(tree, rules), '\n')
local p = coder.makeg(tree, rules[1])


local dir = lfs.currentdir() .. '/test/c89/test/yes/'	
for file in lfs.dir(dir) do
	if file ~= '.' and file ~= '..' and string.sub(file, #file) == 'c' then
		print("file = ", file)
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
	if file ~= '.' and file ~= '..' and string.sub(file, #file - 2) == 'txt' then
		--print("file = ", file)
		local f = io.open(dir .. file)
		local s = f:read('a')
		f:close()
		local r, lab, pos = p:match(s)
		local line, col = '', ''
		if not r then
			line, col = re.calcline(s, pos)
		end
		assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end


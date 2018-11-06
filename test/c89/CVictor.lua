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


local tree, rules =  m.match[[
translation_unit      <-  skip external_decl+ !.

external_decl         <-  function_def  /  decl

function_def          <-  declarator decl* compound_stat  /  decl_spec function_def

decl_spec             <-  storage_class_spec  /  type_spec  /  type_qualifier

decl                  <-  decl_spec init_declarator_list? ';'  /  decl_spec decl

storage_class_spec    <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'

type_spec             <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /'float'  /
                          'double'  /  'signed'  /  'unsigned'  /  typedef_name  /
                          'enum' id? '{' enumerator (',' enumerator)* '}'      /
                          'enum' id                                            /
                          struct_or_union id? '{' struct_decl+ '}'             /
                          struct_or_union id

type_qualifier        <-  'const'  /  'volatile'

struct_or_union       <-  'struct'  /  'union'

init_declarator_list  <-  init_declarator (',' init_declarator)*

init_declarator       <-  declarator '=' initializer  /  declarator

struct_decl           <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /
                          spec_qualifier struct_decl

spec_qualifier_list   <-  (type_spec  /  type_qualifier)+

spec_qualifier        <-  type_spec  /  type_qualifier

struct_declarator     <-  declarator? ';' const_exp  /  declarator
 
enumerator            <-  id '=' const_exp  /  id

declarator            <-  pointer? direct_declarator

direct_declarator     <-  (id  /  '(' declarator ')') ('[' const_exp? ']'       /
                                                       '(' param_type_list ')'  /
                                                       '(' id_list? ')')*

pointer               <-  '*' type_qualifier* pointer  /  '*' type_qualifier*

param_type_list       <-  param_decl (',' param_decl)* (',' '...')?

param_decl            <-  decl_spec+ (declarator  /  abstract_declarator)?

id_list               <-  id (',' id)*

initializer           <-  '{' initializer (',' initializer)* ','? '}'  /
                          assignment_exp

type_name             <-  spec_qualifier_list abstract_declarator?

abstract_declarator   <-  pointer  /  pointer? direct_abstract_declarator

direct_abstract_declarator <- '(' abstract_declarator ')' ('[' const_exp? ']'  /
                                                           '(' param_type_list? ')')*

typedef_name          <-  id

stat                  <-  id ':' stat                                /
                          'case' const_exp ':' stat                  / 
                          'default' ':' stat                         /
                          exp? ';'                                   /
                          compound_stat                              /
                          'if' '(' exp ')' stat 'else' stat          /
                          'if' '(' exp ')' stat                      /
                          'switch' '(' exp ')' stat                  /                       
                          'while' '(' exp ')' stat                   /
                          'do' stat 'while' '(' exp ')' ';'          /
                          'for' '(' exp? ';' exp? ';' exp? ')' stat  / 
                          'goto' id ';'                              /
                          'continue' ';'                             /
                          'break' ';'                                /
                          'return' exp? ';' 

compound_stat         <-  '{' decl* stat* '}'

exp                   <-  assignment_exp (',' assignment_exp)*

assignment_exp        <-  unary_exp assignment_operator assignment_exp  /
                          conditional_exp

assignment_operator   <-  '='!'='  /  '*='  /  '/='  / '%=' /  '+='  /  '-='  /
                          '<<='  /  '>>='  /  '&='  /  '^='  /  '|=' 

conditional_exp       <-  logical_or_exp '?' exp ':' conditional_exp  /
                          logical_or_exp

const_exp             <-  conditional_exp

logical_or_exp        <-  logical_and_exp ('||' logical_and_exp)*

logical_and_exp       <-  inclusive_or_exp ('&&' inclusive_or_exp)*

inclusive_or_exp      <-  exclusive_or_exp ('|'!'|' exclusive_or_exp)*

exclusive_or_exp      <-  and_exp ('^' and_exp)*

and_exp               <-  equality_exp ('&'!'&' equality_exp)*
  
equality_exp          <-  relational_exp (('==' / '!=')  relational_exp)*

relational_exp        <-  shift_exp (('<=' / '>=' / '<' / '>') shift_exp)*

shift_exp             <-  additive_exp (('<<' / '>>') additive_exp)* 
  
additive_exp          <-  multiplicative_exp (('+' / '-') multiplicative_exp)*

multiplicative_exp    <-  cast_exp (('*' / '/' / '%') cast_exp)*

cast_exp              <-  '(' type_name ')' cast_exp  /  unary_exp

unary_exp             <-  '++' unary_exp  /  '--' unary_exp  /
                          unary_operator cast_exp            /
                          'sizeof' (type_name / unary_exp)   /
                          postfix_exp 

postfix_exp           <-  primary_exp ('[' exp ']'                                      /
                                       '(' (assignment_exp (',' assignment_exp)*)? ')'  /
                                       '.' id   /  '->' id  /  '++'  /  '--')*


primary_exp           <-  id  /  string  /  constant  /  '(' exp ')'   
  
constant              <-  int_const  /  char_const  /  float_const  /  enumeration_const  
  
unary_operator        <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'

comment               <-  '/*' (!'*/' .)* '*/'
 
int_const             <-  ('0' [xX] xdigit+  /  !'0' digit digit*  /  '0'[0-8]*)
                          ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
                           
float_const           <-  '0x' (
                                (('.' / xdigit+)  /  (xdigit+ / '.')) ([eE] [-+]? xdigit+)? [lLfF]?  /
                                 xdigit+ [eE] [-+]? xdigit+ [lLfF]?
                              )  /
                              (('.' / digit+)  /  (digit+ / '.')) ([eE] [-+]? digit+)? [lLfF]?  /
                                 digit+ [eE] [-+]? digit+ [lLfF]?
 
xdigit                <- [0-9a-fA-F]

digit                 <- [0-9]

char_const            <-  "'" ('\n'  /  !"'" .)  "'"

string                <-  '"' ('\n'  /  !'"' .)* '"'
 
esc_char              <-  '\\' ('n' / 't' / 'v' / 'b' / 'r' / 'f' / 'a' / '\\' / '?' / "'" / '"' /
                          [01234567] ([01234567]? [01234567]?)  /  'x' xdigit)

enumeration_const     <-  id
  
id                    <-  !keywords [a-zA-Z_] [a-zA-Z_0-9]* skip
  
keywords              <-  ('auto'  /  'double'  /  'int'  /  'struct'  /
                          'break'  /  'else'  /  'long'  /  'switch'  /
                          'case'  /  'enum'  /  'register'  /  'typedef'  /
                          'char'  /  'extern'  /  'return'  /  'union' /
                          'const'  /  'float'  /  'short'  /  'unsigned'  /
                          'continue'  /  'for'  /  'signed'  /  'void'  /
                          'default'  /  'goto'  /  'sizeof'  /  'volatile'  /
                          'do'  /  'if'  /  'static'  /  'while')
   
Token                 <-  keywords  /  id  /  string  /  constant  /  . 
]] 

                        
print(pretty.printg(tree, rules), '\n')
local p = coder.makeg(tree, rules)

--first.calcFst(tree)
--first.calcFlw(tree, rules[1])
--first.printfirst(tree, rules)


print("Regular Annotation (SBLP paper)")
local treelab, ruleslab = recovery.addlab(tree, rules, false, false)
print(pretty.printg(treelab, ruleslab, true), '\n')

print("Conservative Annotation (Hard)")
local treelab, ruleslab = recovery.addlab(tree, rules, false, true)
print(pretty.printg(treelab, ruleslab, true), '\n')

print("Conservative Annotation (Soft)")
local treelab, ruleslab = recovery.addlab(tree, rules, false, 'soft')
print(pretty.printg(treelab, ruleslab, true), '\n')

local p = coder.makeg(tree, rules)

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

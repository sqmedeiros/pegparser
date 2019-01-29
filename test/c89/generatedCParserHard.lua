local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Does not need to remove labels manually
-- Disable rule typedef_name, because its correct matching depends on semantic actions

local g = [[
translation_unit <-  SKIP external_decl+ !.
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /  'double'  /  'signed'  /  'unsigned'  /  typedef_name  /  'enum' ID? '{' enumerator (',' enumerator)* '}'  /  'enum' ID^Err_001  /  struct_or_union ID? '{' struct_decl+ '}'  /  struct_or_union ID^Err_002
type_qualifier  <-  'const'  /  'volatile'
struct_or_union <-  'struct'  /  'union'
init_declarator_list <-  init_declarator (',' init_declarator)*
init_declarator <-  declarator '=' initializer  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator)* ';'  /  spec_qualifier struct_decl
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ':' const_exp  /  declarator
enumerator      <-  ID '=' const_exp  /  ID
declarator      <-  pointer? direct_declarator
direct_declarator <-  (ID  /  '(' declarator^Err_003 ')'^Err_004) ('[' const_exp? ']'^Err_005  /  '(' param_type_list ')'  /  '(' id_list? ')'^Err_006)*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...')?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator ')' ('[' const_exp? ']'  /  '(' param_type_list? ')')*
typedef_name    <-  ID [a-z]
stat            <-  ID ':' stat  /  'case' const_exp ':' stat  /  'default' ':' stat  /  exp? ';'  /  compound_stat  /  'if' '(' exp ')' stat 'else' stat  /  'if' '(' exp ')' stat  /  'switch' '(' exp ')' stat  /  'while' '(' exp ')' stat  /  'do' stat 'while' '(' exp ')' ';'  /  'for' '(' exp? ';' exp? ';' exp? ')' stat  /  'goto' ID ';'  /  'continue' ';'  /  'break' ';'  /  'return' exp? ';'
compound_stat   <-  '{' decl* stat* '}'
exp             <-  assignment_exp (',' assignment_exp)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp  /  conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp ':' conditional_exp  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_007)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_008)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_009)*
and_exp         <-  equality_exp ('&' !'&' equality_exp^Err_010)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_011)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_012)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_013)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp^Err_014)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp^Err_015)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp  /  '--' unary_exp  /  unary_operator cast_exp  /  'sizeof' (type_name  /  unary_exp)  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp^Err_016 ']'^Err_017  /  '(' (assignment_exp (',' assignment_exp^Err_018)*)? ')'^Err_019  /  '.' ID^Err_020  /  '->' ID^Err_021  /  '++'  /  '--')*
primary_exp     <-  ID  /  STRING  /  constant  /  '(' exp^Err_022 ')'^Err_023
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
KEYWORDS        <-  ('auto'  /  'double'  /  'int'  /  'struct'  /  'break'  /  'else'  /  'long'  /  'switch'  /  'case'  /  'enum'  /  'register'  /  'typedef'  /  'char'  /  'extern'  /  'return'  /  'union'  /  'const'  /  'float'  /  'short'  /  'unsigned'  /  'continue'  /  'for'  /  'signed'  /  'void'  /  'default'  /  'goto'  /  'sizeof'  /  'volatile'  /  'do'  /  'if'  /  'static'  /  'while') ![a-zA-Z_0-9]
]] 


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/c89/test/yes/'
util.testYes(dir, 'c', p)

local dir = lfs.currentdir() .. '/test/c89/test/no/'
util.testNo(dir, 'c', p)

local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
translation_unit <-  SKIP (external_decl  /  !('volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '*'  /  '('  /  !.) %{Err_001} .)+ !.
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /  'double'  /  'signed'  /  'unsigned'  /  typedef_name  /  'enum' ID? '{' enumerator (',' enumerator)* '}'  /  'enum' ID^Err_002  /  struct_or_union ID? '{' struct_decl+ '}'  /  struct_or_union ID^Err_003
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
direct_declarator <-  (ID  /  '(' declarator ')') ('[' const_exp? ']'  /  '(' param_type_list ')'  /  '(' id_list? ')')*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...')?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'  /  assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator ')' ('[' const_exp? ']'  /  '(' param_type_list? ')')*
typedef_name    <-  ID
stat            <-  ID ':' stat  /  'case' const_exp^Err_004 ':'^Err_005 stat^Err_006  /  'default' ':'^Err_007 stat^Err_008  /  exp? ';'  /  compound_stat  /  'if' '(' exp ')' stat 'else' stat^Err_009  /  'if' '('^Err_010 exp^Err_011 ')'^Err_012 stat^Err_013  /  'switch' '('^Err_014 exp^Err_015 ')'^Err_016 stat^Err_017  /  'while' '(' exp ')' stat  /  'do' stat^Err_018 'while'^Err_019 '('^Err_020 exp^Err_021 ')'^Err_022 ';'^Err_023  /  'for' '('^Err_024 (exp  /  !';' %{Err_025} .)? ';'^Err_026 (exp  /  !';' %{Err_027} .)? ';'^Err_028 (exp  /  !')' %{Err_029} .)? ')'^Err_030 stat^Err_031  /  'goto' ID^Err_032 ';'^Err_033  /  'continue' ';'^Err_034  /  'break' ';'^Err_035  /  'return' (exp  /  !';' %{Err_036} .)? ';'^Err_037
compound_stat   <-  '{' decl* stat* '}'
exp             <-  assignment_exp (',' assignment_exp)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp^Err_038  /  conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp^Err_039 ':'^Err_040 conditional_exp^Err_041  /  logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp^Err_042)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_043)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_044)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_045)*
and_exp         <-  equality_exp ('&' !'&' equality_exp)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_046)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_047)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_048)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp)*
cast_exp        <-  '(' type_name ')' cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp  /  '--' unary_exp  /  unary_operator cast_exp  /  'sizeof' (type_name  /  unary_exp^Err_049)^Err_050  /  postfix_exp
postfix_exp     <-  primary_exp ('[' exp ']'  /  '(' (assignment_exp (',' assignment_exp)*)? ')'  /  '.' ID^Err_051  /  '->' ID^Err_052  /  '++'  /  '--')*
primary_exp     <-  ID  /  STRING  /  constant  /  '(' exp ')'
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
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'c', p)

util.testNo(dir .. '/test/no/', 'c', p)

local m = require 'init'
local coder = require 'coder'
local util = require'util'

-- Disable rule typedef_name, because its correct matching depends on semantic actions

local g = [[
translation_unit <-  SKIP (external_decl+)^Err_NEW_01 (!.)^Err_NEW_02
external_decl   <-  function_def  /  decl
function_def    <-  declarator decl* compound_stat  /  decl_spec function_def
decl_spec       <-  storage_class_spec  /  type_spec  /  type_qualifier
decl            <-  decl_spec init_declarator_list? ';'  /  decl_spec decl
storage_class_spec <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'
type_spec       <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /  'float'  /
                    'double'  /  'signed'  /  'unsigned'  /  typedef_name  /
                    'enum' ID? '{' enumerator^Err_006 (',' enumerator^Err_007)* '}'^Err_008  /
                    'enum' ID  /
                    struct_or_union ID? '{' (struct_decl+)^Err_011 '}'^Err_012  /
                    struct_or_union ID
type_qualifier  <-  'const'  /  'volatile'
struct_or_union <-  'struct'  /  'union'
init_declarator_list <-  init_declarator (',' init_declarator^Err_014)*
init_declarator <-  declarator '=' initializer  /  declarator
struct_decl     <-  spec_qualifier struct_declarator (',' struct_declarator^Err_018)* ';'^Err_019  /
                    spec_qualifier struct_decl
spec_qualifier_list <-  (type_spec  /  type_qualifier)+
spec_qualifier  <-  type_spec  /  type_qualifier
struct_declarator <-  declarator? ':' const_exp^Err_021  /  declarator
enumerator      <-  ID '=' const_exp^Err_023  /  ID
declarator      <-  pointer? direct_declarator
direct_declarator <-  (ID  /  '(' declarator ')'^Err_025) ('[' const_exp? ']'^Err_026  /
                                                           '(' param_type_list ')'^Err_028  /
                                                           '(' id_list? ')'^Err_029)*
pointer         <-  '*' type_qualifier* pointer  /  '*' type_qualifier*
param_type_list <-  param_decl (',' param_decl)* (',' '...')?
param_decl      <-  decl_spec+ (declarator  /  abstract_declarator)?
id_list         <-  ID (',' ID^Err_033)*
initializer     <-  '{' initializer (',' initializer)* ','? '}'^Err_036  /
                    assignment_exp
type_name       <-  spec_qualifier_list abstract_declarator?
abstract_declarator <-  pointer  /  pointer? direct_abstract_declarator
direct_abstract_declarator <-  '(' abstract_declarator ')'^Err_038 ('[' const_exp? ']'^Err_039  /
                                                                    '(' param_type_list? ')'^Err_040)*
typedef_name    <-  ID
stat            <-  ID ':' stat  /
                    'case' const_exp^Err_043 ':'^Err_044 stat^Err_045  /
                    'default' ':'^Err_046 stat^Err_047  /
                    exp? ';'  /
                    compound_stat  /
                    'if' '('^Err_048 exp^Err_049 ')'^Err_050 stat^Err_051 'else' stat^Err_053  /
                    'if' '('^Err_054 exp^Err_055 ')'^Err_056 stat^Err_057  /
                    'switch' '('^Err_058 exp^Err_059 ')'^Err_060 stat^Err_061  /
                    'while' '('^Err_062 exp^Err_063 ')'^Err_064 stat^Err_065  /
                    'do' stat^Err_066 'while'^Err_067 '('^Err_068 exp^Err_069 ')'^Err_070 ';'^Err_071  /
                    'for' '('^Err_072 exp? ';'^Err_073 exp? ';'^Err_074 exp? ')'^Err_075 stat  /
                    'goto' ID^Err_077 ';'^Err_078  /
                    'continue' ';'^Err_079  /
                    'break' ';'^Err_080  /
                    'return' exp? ';'^Err_081
compound_stat   <-  '{' decl* stat* '}'^Err_082
exp             <-  assignment_exp (',' assignment_exp^Err_083)*
assignment_exp  <-  unary_exp assignment_operator assignment_exp^Err_085  /
                    conditional_exp
assignment_operator <-  '=' !'='  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /
                        '<<='  /  '>>='  /  '&='  /  '^='  /  '|='
conditional_exp <-  logical_or_exp '?' exp^Err_087 ':'^Err_088 conditional_exp^Err_089  /
                    logical_or_exp
const_exp       <-  conditional_exp
logical_or_exp  <-  logical_and_exp ('||' logical_and_exp^Err_090)*
logical_and_exp <-  inclusive_or_exp ('&&' inclusive_or_exp^Err_091)*
inclusive_or_exp <-  exclusive_or_exp ('|' !'|' exclusive_or_exp^Err_092)*
exclusive_or_exp <-  and_exp ('^' and_exp^Err_093)*
and_exp         <-  equality_exp ('&' !'&' equality_exp^Err_094)*
equality_exp    <-  relational_exp (('=='  /  '!=') relational_exp^Err_095)*
relational_exp  <-  shift_exp (('<='  /  '>='  /  '<'  /  '>') shift_exp^Err_096)*
shift_exp       <-  additive_exp (('<<'  /  '>>') additive_exp^Err_097)*
additive_exp    <-  multiplicative_exp (('+'  /  '-') multiplicative_exp^Err_098)*
multiplicative_exp <-  cast_exp (('*'  /  '/'  /  '%') cast_exp^Err_099)*
cast_exp        <-  '(' type_name ')'^Err_101 cast_exp  /  unary_exp
unary_exp       <-  '++' unary_exp^Err_103  /
                    '--' unary_exp^Err_104  /
                    unary_operator cast_exp^Err_105  /
                    'sizeof' (type_name  / unary_exp)^Err_106  /
                    postfix_exp
postfix_exp     <-  primary_exp ('[' exp^Err_107 ']'^Err_108  /
                                 '(' (assignment_exp (',' assignment_exp^Err_109)*)? ')'^Err_110  /
                                 '.' ID^Err_111  /
                                 '->' ID^Err_112  /
                                 '++'  /
                                 '--')*
primary_exp     <-  ID  /  STRING  /  constant  /  '(' exp ')'^Err_114
constant        <-  INT_CONST  /  CHAR_CONST  /  FLOAT_CONST  /  ENUMERATION_CONST
unary_operator  <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'
COMMENT         <-  '/*' (!'*/' .)* '*/'^Err_NEW_03
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
Token           <-  '~'  /  '}'  /  '||'  /  '|='  /  '|'  /  '{'  /  XDIGIT  /  STRING  /  KEYWORDS  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ESC_CHAR  /  ENUMERATION_CONST  /  DIGIT  /  COMMENT  /  CHAR_CONST  /  '^='  /  '^'  /  ']'  /  '['  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '...'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!='  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_NEW_01      <-  (!(!.) EatToken)*
Err_NEW_02      <-  (!(!.) EatToken)*
Err_NEW_03      <-  (!(!.) EatToken)*
Err_006         <-  (!('}'  /  ',') EatToken)*
Err_007         <-  (!'}' EatToken)*
Err_008         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_011         <-  (!'}' EatToken)*
Err_012         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_014         <-  (!';' EatToken)*
Err_018         <-  (!';' EatToken)*
Err_019         <-  (!('}'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'struct'  /  'signed'  /  'short'  /  'long'  /  'int'  /  'float'  /  'enum'  /  'double'  /  'const'  /  'char'  /  ID) EatToken)*
Err_021         <-  (!(';'  /  ',') EatToken)*
Err_023         <-  (!('}'  /  ',') EatToken)*
Err_025         <-  (!('{'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '['  /  '='  /  ';'  /  ':'  /  ','  /  ')'  /  '(') EatToken)*
Err_026         <-  (!('{'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '='  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_028         <-  (!('{'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '='  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_029         <-  (!('{'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'struct'  /  'static'  /  'signed'  /  'short'  /  'register'  /  'long'  /  'int'  /  'float'  /  'extern'  /  'enum'  /  'double'  /  'const'  /  'char'  /  'auto'  /  ID  /  '='  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_033         <-  (!')' EatToken)*
Err_036         <-  (!('}'  /  ';'  /  ',') EatToken)*
Err_038         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_039         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_040         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_043         <-  (!':' EatToken)*
Err_044         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_045         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_046         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_047         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_048         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_049         <-  (!')' EatToken)*
Err_050         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_051         <-  (!'else' EatToken)*
Err_053         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_054         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_055         <-  (!')' EatToken)*
Err_056         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_057         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_058         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_059         <-  (!')' EatToken)*
Err_060         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_061         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_062         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_063         <-  (!')' EatToken)*
Err_064         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_065         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_066         <-  (!'while' EatToken)*
Err_067         <-  (!'(' EatToken)*
Err_068         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_069         <-  (!')' EatToken)*
Err_070         <-  (!';' EatToken)*
Err_071         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_072         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_073         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_074         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  ')'  /  '('  /  '&'  /  '!') EatToken)*
Err_075         <-  (!('~'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_077         <-  (!';' EatToken)*
Err_078         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_079         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_080         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_081         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'switch'  /  'sizeof'  /  'return'  /  'if'  /  'goto'  /  'for'  /  'else'  /  'do'  /  'default'  /  'continue'  /  'case'  /  'break'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_082         <-  (!('~'  /  '}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'unsigned'  /  'union'  /  'typedef'  /  'switch'  /  'struct'  /  'static'  /  'sizeof'  /  'signed'  /  'short'  /  'return'  /  'register'  /  'long'  /  'int'  /  'if'  /  'goto'  /  'for'  /  'float'  /  'extern'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'const'  /  'char'  /  'case'  /  'break'  /  'auto'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  ';'  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  !.  /  '!') EatToken)*
Err_083         <-  (!(']'  /  ';'  /  ':'  /  ')') EatToken)*
Err_085         <-  (!('}'  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_087         <-  (!':' EatToken)*
Err_088         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_089         <-  (!('}'  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_090         <-  (!('}'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_091         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_092         <-  (!('}'  /  '||'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_093         <-  (!('}'  /  '||'  /  '|'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_094         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&') EatToken)*
Err_095         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&') EatToken)*
Err_096         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '=='  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_097         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_098         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  ','  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_099         <-  (!('}'  /  '||'  /  '|'  /  '^'  /  ']'  /  '?'  /  '>>'  /  '>='  /  '>'  /  '=='  /  '<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '-'  /  ','  /  '+'  /  ')'  /  '&&'  /  '&'  /  '!=') EatToken)*
Err_101         <-  (!('~'  /  'sizeof'  /  STRING  /  INT_CONST  /  ID  /  FLOAT_CONST  /  ENUMERATION_CONST  /  CHAR_CONST  /  '--'  /  '-'  /  '++'  /  '+'  /  '*'  /  '('  /  '&'  /  '!') EatToken)*
Err_103         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_104         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_105         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_106         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_107         <-  (!']' EatToken)*
Err_108         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_109         <-  (!')' EatToken)*
Err_110         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_111         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_112         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '-='  /  '-'  /  ','  /  '+='  /  '+'  /  '*='  /  '*'  /  ')'  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*
Err_114         <-  (!('}'  /  '||'  /  '|='  /  '|'  /  '^='  /  '^'  /  ']'  /  '['  /  '?'  /  '>>='  /  '>>'  /  '>='  /  '>'  /  '=='  /  '='  /  '<='  /  '<<='  /  '<<'  /  '<'  /  ';'  /  ':'  /  '/='  /  '/'  /  '.'  /  '->'  /  '-='  /  '--'  /  '-'  /  ','  /  '+='  /  '++'  /  '+'  /  '*='  /  '*'  /  ')'  /  '('  /  '&='  /  '&&'  /  '&'  /  '%='  /  '%'  /  '!=') EatToken)*	
]] 

local g, err = m.match(g)
print(g, err)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/c89/test/yes/'
util.testYes(dir, 'c', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/c89/test/no/'
util.testNoRec(dir, 'c', p)
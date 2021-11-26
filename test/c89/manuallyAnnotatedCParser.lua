local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

-- Disable rule typedef_name, because its correct matching depends on semantic actions

local g = [[
translation_unit      <-  SKIP (external_decl+)^InvalidDecl (!.)^InvalidDecl

external_decl         <-  function_def  /  decl

function_def          <-  declarator decl* compound_stat  /  decl_spec function_def

decl_spec             <-  storage_class_spec  /  type_spec  /  type_qualifier

decl                  <-  decl_spec init_declarator_list? ';'  /  decl_spec decl

storage_class_spec    <-  'auto'  /  'register'  /  'static'  /  'extern'  /  'typedef'

type_spec             <-  'void'  /  'char'  /  'short'  /  'int'  /  'long'  /'float'  /
                          'double'  /  'signed'  /  'unsigned'  /  typedef_name  /
                          'enum' ID? '{'^Erro44 enumerator^Enumerator (',' enumerator^EnumeratorComma)* '}'^Braces      /
                          'enum' ID                                            /
                          struct_or_union ID? '{'^Erro45 (struct_decl+)^ZeroDecl '}'^Braces             /
                          struct_or_union ID

type_qualifier        <-  'const'  /  'volatile'

struct_or_union       <-  'struct'  /  'union'

init_declarator_list  <-  init_declarator (',' init_declarator^DeclAfterComma)*

init_declarator       <-  declarator '=' initializer^Erro46  /  declarator

struct_decl           <-  spec_qualifier struct_declarator^Erro99 (',' struct_declarator^DeclAfterComma)* ';'^Semicolon  /
                          spec_qualifier struct_decl

spec_qualifier_list   <-  (type_spec  /  type_qualifier)+

spec_qualifier        <-  type_spec  /  type_qualifier

struct_declarator     <-  declarator? ':' const_exp^InvalidExpr  /  declarator
 
enumerator            <-  ID '=' const_exp^InvalidExpr  /  ID

declarator            <-  pointer? direct_declarator

direct_declarator     <-  (ID  /  '(' declarator ')'^Brack) ('[' const_exp? ']'^SqBrack       /
                                                       '(' param_type_list ')'^Brack  /
                                                       '(' id_list? ')'^Brack)*

pointer               <-  '*' type_qualifier* pointer  /  '*' type_qualifier*

param_type_list       <-  param_decl (',' param_decl)* (',' '...')?

param_decl            <-  decl_spec+ (declarator  /  abstract_declarator)?

id_list               <-  ID (',' ID^Identifier)*

initializer           <-  '{' initializer^Erro48 (',' initializer)* ','? '}'^Braces  /
                          assignment_exp

type_name             <-  spec_qualifier_list abstract_declarator?

abstract_declarator   <-  pointer  /  pointer? direct_abstract_declarator

direct_abstract_declarator <- '(' abstract_declarator ')'^Brack ('[' const_exp? ']'^SqBrack  /
                                                           '(' param_type_list? ')'^Brack)*

typedef_name          <-  ID [a-z]

stat                  <-  ID ':' stat^Erro51                                /
                          'case' const_exp^InvalidExpr ':'^Colon stat^StatCase                  / 
                          'default' ':'^Colon stat^StatDefault                         /
                          exp? ';'                                  /
                          compound_stat                              /
                          'if' '('^BrackIf exp^InvalidExpr ')'^Brack stat^Stat 'else' stat^Stat          /
                          'if' '('^Brack exp^InvalidExpr ')'^Brack stat^Stat                      /
                          'switch' '('^BrackSwitch exp^InvalidExpr ')'^Brack stat^Stat                  /                       
                          'while' '('^BrackWhile exp^InvalidExpr ')'^Brack stat^Stat                   /
                          'do' stat^Stat 'while'^While '('^BrackWhile exp^InvalidExpr ')'^Brack ';'^Semicolon          /
                          'for' '('^BrackFor exp? ';'^Semicolon exp? ';'^Semicolon exp? ')'^Brack stat  / 
                          'goto' ID^Identifier ';'^Semicolon                              /
                          'continue' ';'^Semicolon                             /
                          'break' ';'^Semicolon                                /
                          'return' exp? ';'^Semicolon 

compound_stat         <-  '{' decl* stat* '}'^Braces

exp                   <-  assignment_exp (',' assignment_exp^ExprComma)*

assignment_exp        <-  unary_exp assignment_operator assignment_exp^InvalidExpr  /
                          conditional_exp

assignment_operator   <-  '='!'='  /  '*='  /  '/='  / '%=' /  '+='  /  '-='  /
                          '<<='  /  '>>='  /  '&='  /  '^='  /  '|=' 

conditional_exp       <-  logical_or_exp '?' exp^InvalidExprCond1 ':'^Colon conditional_exp^InvalidExprCond2  /
                          logical_or_exp

const_exp             <-  conditional_exp

logical_or_exp        <-  logical_and_exp ('||' logical_and_exp^ExprLogOr)*

logical_and_exp       <-  inclusive_or_exp ('&&' inclusive_or_exp^ExprLogAnd)*

inclusive_or_exp      <-  exclusive_or_exp ('|'!'|' exclusive_or_exp^ExprIncOr)*

exclusive_or_exp      <-  and_exp ('^' and_exp^ExprExcOr)*

and_exp               <-  equality_exp ('&'!'&' equality_exp^ExprAnd)*
  
equality_exp          <-  relational_exp (('==' / '!=')  relational_exp^ExprEq)*

relational_exp        <-  shift_exp (('<=' / '>=' / '<' / '>') shift_exp^ExprRel)*

shift_exp             <-  additive_exp (('<<' / '>>') additive_exp^ExprShift)* 
  
additive_exp          <-  multiplicative_exp (('+' / '-') multiplicative_exp^ExprAdd)*

multiplicative_exp    <-  cast_exp (('*' / '/' / '%') cast_exp^ExprMult)*

cast_exp              <-  '(' type_name ')'^Brack cast_exp  /  unary_exp

unary_exp             <-  '++' unary_exp^InvalidExprInc  /  '--' unary_exp^InvalidExprDec  /
                          unary_operator cast_exp^InvalidExprUnary            /
                          'sizeof' (type_name / unary_exp)^InvalidSizeof   /
                          postfix_exp 

postfix_exp           <-  primary_exp ('[' exp^InvalidExpr ']'^SqBrack                                      /
                                       '(' (assignment_exp (',' assignment_exp^InvalidExpr)*)? ')'^Brack  /
                                       '.' ID^Identifier   /  '->' ID^Identifier  /  '++'  /  '--')*


primary_exp           <-  ID  /  STRING  /  constant  /  '(' exp ')'^Brack   
  
constant              <-  INT_CONST  /  CHAR_CONST  /  FLOAT_CONST  /  ENUMERATION_CONST
  
unary_operator        <-  '&'  /  '*'  /  '+'  /  '-'  /  '~'  /  '!'

COMMENT               <-  '/*' (!'*/' .)* '*/'^EndComment
 
INT_CONST             <-  ('0' [xX] XDIGIT+  /  !'0' DIGIT DIGIT*  /  '0'[0-8]*)
                          ([uU] [lL]  /  [lL] [uU]  /  'l'  /  'L'  /  'u'  /  'U')?
                           
FLOAT_CONST           <-  '0x' (
                                (('.' / XDIGIT+)  /  (XDIGIT+ / '.')) ([eE] [-+]? XDIGIT+)? [lLfF]?  /
                                 XDIGIT+ [eE] [-+]? XDIGIT+ [lLfF]?
                              )  /
                              (('.' / DIGIT+)  /  (DIGIT+ / '.')) ([eE] [-+]? DIGIT+)? [lLfF]?  /
                                 DIGIT+ [eE] [-+]? DIGIT+ [lLfF]?
 
XDIGIT                <- [0-9a-fA-F]

DIGIT                 <- [0-9]

CHAR_CONST            <-  "'" (%nl  /  !"'" .)  "'"

STRING                <-  '"' (%nl  /  !'"' .)* '"'
 
ESC_CHAR              <-  '\\' ('n' / 't' / 'v' / 'b' / 'r' / 'f' / 'a' / '\\' / '?' / "'" / '"' /
                          [01234567] ([01234567]? [01234567]?)  /  'x' XDIGIT)

ENUMERATION_CONST     <-  ID
  
ID                    <-  !KEYWORDS [a-zA-Z_] [a-zA-Z_0-9]*
  
KEYWORDS              <-  ('auto'  /  'double'  /  'int'  /  'struct'  /
                          'break'  /  'else'  /  'long'  /  'switch'  /
                          'case'  /  'enum'  /  'register'  /  'typedef'  /
                          'char'  /  'extern'  /  'return'  /  'union' /
                          'const'  /  'float'  /  'short'  /  'unsigned'  /
                          'continue'  /  'for'  /  'signed'  /  'void'  /
                          'default'  /  'goto'  /  'sizeof'  /  'volatile'  /
                          'do'  /  'if'  /  'static'  /  'while') ![a-zA-Z_0-9]
]] 


local g = m.match(g)
print("Manually Annotated Grammar")
print(pretty.printg(g), '\n')

local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'c', p)

util.testNo(dir .. '/test/no/', 'c', p, 'strict', 'mult')


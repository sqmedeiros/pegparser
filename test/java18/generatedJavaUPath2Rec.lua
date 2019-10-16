local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util = require'util'

-- Added 68 labels
-- Did not have to remove rules manually

g = [[
compilation     <-  SKIP compilationUnit !.
basicType       <-  'byte'  /  'short'  /  'int'  /  'long'  /  'char'  /  'float'  /  'double'  /  'boolean'
primitiveType   <-  annotation* basicType
referenceType   <-  primitiveType dim+  /  classType dim*
classType       <-  annotation* Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
type            <-  primitiveType  /  classType
arrayType       <-  primitiveType dim+  /  classType dim+
typeVariable    <-  annotation* Identifier
dim             <-  annotation* '[' ']'
typeParameter   <-  typeParameterModifier* Identifier typeBound?
typeParameterModifier <-  annotation
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)
additionalBound <-  'and' classType^Err_001
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_002  /  'super' referenceType^Err_003
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_004 ('.' Identifier^Err_005)* ';'^Err_006
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_007 ('.' '*'^Err_008)? ';'^Err_009  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier typeParameters? superclass? superinterfaces? classBody
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  'extends' classType
superinterfaces <-  'implements' interfaceTypeList^Err_010
interfaceTypeList <-  classType (',' classType)*
classBody       <-  '{' classBodyDeclaration* '}'
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result methodDeclarator throws?
methodDeclarator <-  Identifier '(' formalParameterList? ')' dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_011 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_012
exceptionTypeList <-  exceptionType^Err_013 (',' exceptionType^Err_014)*
exceptionType   <-  (classType  /  typeVariable)^Err_015
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier^Err_016 superinterfaces? enumBody^Err_017
enumBody        <-  '{'^Err_018 enumConstantList? ','? enumBodyDeclarations? '}'^Err_019
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier typeParameters? extendsInterfaces? interfaceBody
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair)*
elementValuePair <-  Identifier '=' !'=' elementValue
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue ')'
arrayInitializer <-  '{' variableInitializerList? ','? '}'
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_020 statement^Err_021 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression statement  /  'do' statement^Err_022 'while'^Err_023 parExpression^Err_024 ';'^Err_025  /  tryStatement  /  'switch' parExpression^Err_026 switchBlock^Err_027  /  'synchronized' parExpression block  /  'return' expression? ';'^Err_028  /  'throw' expression^Err_029 ';'^Err_030  /  'break' Identifier? ';'^Err_031  /  'continue' Identifier? ';'^Err_032  /  'assert' expression^Err_033 (':' expression^Err_034)? ';'^Err_035  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_036 switchBlockStatementGroup* switchLabel* '}'^Err_037
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_038 ':'^Err_039  /  'default' ':'
enumConstantName <-  Identifier^Err_040
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_041  /  resourceSpecification block^Err_042 catchClause* finally?)^Err_043
catchClause     <-  'catch' '('^Err_044 catchFormalParameter^Err_045 ')'^Err_046 block^Err_047
catchFormalParameter <-  variableModifier* catchType^Err_048 variableDeclaratorId^Err_049
catchType       <-  unannClassType^Err_050 ('|' ![=|] classType^Err_051)*
finally         <-  'finally' block^Err_052
resourceSpecification <-  '('^Err_053 resourceList^Err_054 ';'? ')'^Err_055
resourceList    <-  resource^Err_056 (',' resource^Err_057)*
resource        <-  variableModifier* unannType^Err_058 variableDeclaratorId^Err_059 '='^Err_060 !'=' expression^Err_061
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>' !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+ arrayInitializer
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression^Err_062  /  '-' ![-=>] unaryExpression^Err_063  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_064  /  '!' ![=&] unaryExpression^Err_065  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_066
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_067
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block)^Err_068
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  ('abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected'  /  'public'  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while') ![a-zA-Z_$0-9]
Literal         <-  FloatLiteral  /  IntegerLiteral  /  BooleanLiteral  /  CharLiteral  /  StringLiteral  /  NullLiteral
IntegerLiteral  <-  (HexNumeral  /  BinaryNumeral  /  OctalNumeral  /  DecimalNumeral) [lL]?
DecimalNumeral  <-  '0'  /  [1-9] ([_]* [0-9])*
HexNumeral      <-  ('0x'  /  '0X') HexDigits
OctalNumeral    <-  '0' ([_]* [0-7])+
BinaryNumeral   <-  ('0b'  /  '0B') [01] ([_]* [01])*
FloatLiteral    <-  HexaDecimalFloatingPointLiteral  /  DecimalFloatingPointLiteral
DecimalFloatingPointLiteral <-  Digits '.' Digits? Exponent? [fFdD]?  /  '.' Digits Exponent? [fFdD]?  /  Digits Exponent [fFdD]?  /  Digits Exponent? [fFdD]
Exponent        <-  [eE] [-+]? Digits
HexaDecimalFloatingPointLiteral <-  HexSignificand BinaryExponent [fFdD]?
HexSignificand  <-  ('0x'  /  '0X') HexDigits? '.' HexDigits  /  HexNumeral '.'?
HexDigits       <-  HexDigit ([_]* HexDigit)*
HexDigit        <-  [a-f]  /  [A-F]  /  [0-9]
BinaryExponent  <-  [pP] [-+]? Digits
Digits          <-  [0-9] ([_]* [0-9])*
BooleanLiteral  <-  'true'  /  'false'
CharLiteral     <-  "'" (%nl  /  !"'" .) "'"
StringLiteral   <-  '"' (%nl  /  !'"' .)* '"'
NullLiteral     <-  'null'
COMMENT         <-  '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~'  /  '}'  /  '{'  /  'stictfp'  /  'query'  /  'and'  /  StringLiteral  /  OctalNumeral  /  NullLiteral  /  Literal  /  Keywords  /  IntegerLiteral  /  InfixOperator  /  Identifier  /  HexaDecimalFloatingPointLiteral  /  HexSignificand  /  HexNumeral  /  HexDigits  /  HexDigit  /  FloatLiteral  /  Exponent  /  Digits  /  DecimalNumeral  /  DecimalFloatingPointLiteral  /  CharLiteral  /  COMMENT  /  BooleanLiteral  /  BinaryNumeral  /  BinaryExponent  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '?'  /  ';'  /  '::'  /  ':'  /  '...'  /  '->'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_002         <-  (!('>'  /  ',') EatToken)*
Err_003         <-  (!('>'  /  ',') EatToken)*
Err_004         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  '.'  /  !.) EatToken)*
Err_005         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_006         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_007         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  '.'  /  !.) EatToken)*
Err_008         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_009         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_010         <-  (!'{' EatToken)*
Err_011         <-  (!(','  /  ')') EatToken)*
Err_012         <-  (!('{'  /  ';') EatToken)*
Err_013         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_014         <-  (!('{'  /  ';') EatToken)*
Err_015         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_016         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'implements'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_017         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_018         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  ','  /  '++'  /  '('  /  !.) EatToken)*
Err_019         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_020         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_021         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_022         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_023         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_024         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_025         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_026         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_027         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_028         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_029         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_030         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_031         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_032         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_033         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_034         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  ':'  /  '--'  /  '++'  /  '(') EatToken)*
Err_035         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_036         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_037         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_038         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_039         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  ':'  /  '--'  /  '++'  /  '(') EatToken)*
Err_040         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_041         <-  (!':' EatToken)*
Err_042         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_043         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_044         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_045         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_046         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  ')'  /  '(') EatToken)*
Err_047         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_048         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_049         <-  (!(Identifier  /  ')') EatToken)*
Err_050         <-  (!')' EatToken)*
Err_051         <-  (!('|'  /  Identifier) EatToken)*
Err_052         <-  (!Identifier EatToken)*
Err_053         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_054         <-  (!('{'  /  'short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_055         <-  (!('{'  /  ';'  /  ')') EatToken)*
Err_056         <-  (!'{' EatToken)*
Err_057         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_058         <-  (!(';'  /  ')') EatToken)*
Err_059         <-  (!(Identifier  /  ';'  /  ','  /  ')') EatToken)*
Err_060         <-  (!('='  /  ';'  /  ','  /  ')') EatToken)*
Err_061         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '-'  /  ','  /  '++'  /  '+'  /  ')'  /  '('  /  '!') EatToken)*
Err_062         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_063         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_064         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_065         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_066         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_067         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_068         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_069         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_070         <-  (!('~'  /  '}'  /  'void'  /  'this'  /  'super'  /  'short'  /  'query'  /  'new'  /  'long'  /  'int'  /  'instanceof'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  InfixOperator  /  Identifier  /  ']'  /  '@'  /  ';'  /  ':'  /  '--'  /  '-'  /  ','  /  '++'  /  '+'  /  ')'  /  '('  /  '!') EatToken)*
Err_071         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_072         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_073         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_074         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*	
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
util.testYes(dir, 'java', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/java18/test/no/' 
util.testNoRec(dir, 'java', p)

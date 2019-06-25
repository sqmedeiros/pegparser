local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util = require'util'

-- Added 82 labels
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
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)^Err_001
additionalBound <-  'and' classType^Err_002
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_003  /  'super' referenceType^Err_004
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_005 ('.' Identifier^Err_006)* ';'^Err_007
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_008 ('.' '*'^Err_009)? ';'^Err_010  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier typeParameters? superclass? superinterfaces? classBody
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  'extends' classType^Err_011
superinterfaces <-  'implements' interfaceTypeList^Err_012
interfaceTypeList <-  classType (',' classType^Err_013)*
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
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_014 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_015
exceptionTypeList <-  exceptionType^Err_016 (',' exceptionType^Err_017)*
exceptionType   <-  (classType  /  typeVariable)^Err_018
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier^Err_019 superinterfaces? enumBody^Err_020
enumBody        <-  '{'^Err_021 enumConstantList? ','? enumBodyDeclarations? '}'^Err_022
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier typeParameters? extendsInterfaces? interfaceBody
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_023
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
defaultValue    <-  'default' elementValue^Err_024
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
statement       <-  block  /  'if' parExpression^Err_025 statement^Err_026 ('else' statement^Err_027)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression statement  /  'do' statement^Err_028 'while'^Err_029 parExpression^Err_030 ';'^Err_031  /  tryStatement  /  'switch' parExpression^Err_032 switchBlock^Err_033  /  'synchronized' parExpression block  /  'return' expression? ';'^Err_034  /  'throw' expression^Err_035 ';'^Err_036  /  'break' Identifier? ';'^Err_037  /  'continue' Identifier? ';'^Err_038  /  'assert' expression^Err_039 (':' expression^Err_040)? ';'^Err_041  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_042 switchBlockStatementGroup* switchLabel* '}'^Err_043
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_044 ':'^Err_045  /  'default' ':'
enumConstantName <-  Identifier^Err_046
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_047)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_048  /  resourceSpecification block^Err_049 catchClause* finally?)^Err_050
catchClause     <-  'catch' '('^Err_051 catchFormalParameter^Err_052 ')'^Err_053 block^Err_054
catchFormalParameter <-  variableModifier* catchType^Err_055 variableDeclaratorId^Err_056
catchType       <-  unannClassType^Err_057 ('|' ![=|] classType^Err_058)*
finally         <-  'finally' block^Err_059
resourceSpecification <-  '('^Err_060 resourceList^Err_061 ';'? ')'^Err_062
resourceList    <-  resource^Err_063 (',' resource^Err_064)*
resource        <-  variableModifier* unannType^Err_065 variableDeclaratorId^Err_066 '='^Err_067 !'=' expression^Err_068
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_069 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+ arrayInitializer
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression^Err_070)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression^Err_071  /  '-' ![-=>] unaryExpression^Err_072  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_073  /  '!' ![=&] unaryExpression^Err_074  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression^Err_075  /  'instanceof' referenceType^Err_076)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression^Err_077 ':'^Err_078 expression^Err_079)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_080
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_081
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block)^Err_082
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
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/'
util.testYes(dir, 'java', p)

local dir = lfs.currentdir() .. '/test/java18/test/no/'
util.testNo(dir, 'java', p)

local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util = require'util'

--[[
  Inserted: 53 labels (50 correct, 3 incorrect) 
  Removed labels:
    - Err_001 (dim+ in second alternative of rule arrayType) (AltSeq, Alt)
    - Err_012 ('...' in rule formalParameter) (AltSeq, Alt)
    - Err_021 ('.' near qualIdent in rule explicitConstructorInvocation) (AltSeq, Alt)
]]

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
typeArgumentList <-  typeArgument (',' typeArgument^Err_003)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_004  /  'super' referenceType^Err_005
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier ('.' Identifier)* ';'
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_006 ('.' '*'^Err_007)? ';'^Err_008  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier typeParameters? superclass? superinterfaces? classBody
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter^Err_009)*
superclass      <-  'extends' classType^Err_010
superinterfaces <-  'implements' interfaceTypeList^Err_011
interfaceTypeList <-  classType (',' classType^Err_012)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_013
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
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_014
exceptionTypeList <-  exceptionType (',' exceptionType^Err_015)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_016
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_017
constructorDeclarator <-  typeParameters? Identifier '('^Err_018 formalParameterList? ')'^Err_019
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_020
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier superinterfaces? enumBody
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_021
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier typeParameters? extendsInterfaces? interfaceBody
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_022
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_023
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_024
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_025
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair)*
elementValuePair <-  Identifier '=' !'=' elementValue
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'^Err_026
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue ')'
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_027
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'^Err_028
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_029 statement^Err_030 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_031 statement^Err_032  /  'do' statement^Err_033 'while'^Err_034 parExpression^Err_035 ';'^Err_036  /  tryStatement  /  'switch' parExpression^Err_037 switchBlock^Err_038  /  'synchronized' parExpression^Err_039 block^Err_040  /  'return' expression? ';'^Err_041  /  'throw' expression^Err_042 ';'^Err_043  /  'break' Identifier? ';'^Err_044  /  'continue' Identifier? ';'^Err_045  /  'assert' expression^Err_046 (':' expression^Err_047)? ';'^Err_048  /  ';'  /  statementExpression ';'  /  Identifier ':'^Err_049 statement^Err_050
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)^Err_051  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'^Err_052
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName) ':'  /  'default' ':'
enumConstantName <-  Identifier
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_053)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_054  /  resourceSpecification block^Err_055 catchClause* finally?)^Err_056
catchClause     <-  'catch' '(' catchFormalParameter ')' block
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_057
catchType       <-  unannClassType ('|' ![=|] classType^Err_058)*
finally         <-  'finally' block^Err_059
resourceSpecification <-  '(' resourceList^Err_060 ';'? ')'^Err_061
resourceList    <-  resource (',' resource^Err_062)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_063 '='^Err_064 !'=' expression^Err_065
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression^Err_066 ']'^Err_067  /  '::' typeArguments? Identifier^Err_068
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_069 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+ arrayInitializer
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)^Err_070  /  '+' ![=+] unaryExpression^Err_071  /  '-' ![-=>] unaryExpression^Err_072  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_073  /  '!' ![=&] unaryExpression^Err_074  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier^Err_075)*
lambdaBody      <-  expression  /  block
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


local g, e = m.match(g)
print(g, e)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/'
util.testYes(dir, 'java', p)

local dir = lfs.currentdir() .. '/test/java18/test/no/'
util.testNo(dir, 'java', p)

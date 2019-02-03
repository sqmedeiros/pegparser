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
  Removed labels:
    - Err_056 (')' in rule lambdaParameters)
    - Err_014 (Identifier in rule unannClassType)
    - Err_031 ('=' int rule elementValuePair)
    - Err_015 (methodDeclarator in rule methodHeader)
    - Err_055 (inferredFormalParameterList in rule lambdaParameters)
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
additionalBound <-  'and' classType
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument^Err_002)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_003  /  'super' referenceType^Err_004
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier ('.' Identifier)* ';'
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent ('.' '*')? ';'  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier typeParameters? superclass? superinterfaces? classBody
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList^Err_005 '>'^Err_006
typeParameterList <-  typeParameter (',' typeParameter^Err_007)*
superclass      <-  'extends' classType^Err_008
superinterfaces <-  'implements' interfaceTypeList^Err_009
interfaceTypeList <-  classType (',' classType^Err_010)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_011
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_012)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer^Err_013)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result^Err_016 methodDeclarator^Err_017 throws?
methodDeclarator <-  Identifier '('^Err_018 formalParameterList? ')'^Err_019 dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_020
exceptionTypeList <-  exceptionType (',' exceptionType^Err_021)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '('^Err_022 formalParameterList? ')'^Err_023
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_024
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier superinterfaces? enumBody
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_025
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier typeParameters? extendsInterfaces? interfaceBody
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_026
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_027
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_028
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_029
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair^Err_030)*
elementValuePair <-  Identifier '=' !'=' elementValue^Err_032
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
statement       <-  block  /  'if' parExpression statement ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression statement  /  'do' statement 'while' parExpression ';'  /  tryStatement  /  'switch' parExpression switchBlock  /  'synchronized' parExpression block  /  'return' expression? ';'  /  'throw' expression ';'  /  'break' Identifier? ';'  /  'continue' Identifier? ';'  /  'assert' expression (':' expression)? ';'  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_033 ':'^Err_034  /  'default' ':'^Err_035
enumConstantName <-  Identifier
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)  /  resourceSpecification block catchClause* finally?)
catchClause     <-  'catch' '(' catchFormalParameter ')' block
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_036
catchType       <-  unannClassType ('|' ![=|] classType^Err_037)*
finally         <-  'finally' block
resourceSpecification <-  '(' resourceList^Err_038 ';'? ')'^Err_039
resourceList    <-  resource (',' resource^Err_040)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_041 '='^Err_042 !'=' expression^Err_043
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier^Err_044  /  '::' typeArguments? Identifier^Err_045)^Err_046  /  'new' (classCreator  /  arrayCreator)^Err_047  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'^Err_048 'class'^Err_049  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::'^Err_050 'new'^Err_051
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_052 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_053 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+ arrayInitializer
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression^Err_054)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression  /  '-' ![-=>] unaryExpression  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression  /  '!' ![=&] unaryExpression  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
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
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  expression  /  block
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  ('abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected'  /  'public'  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while') ![a-zA-Z0-9_]
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
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/'
util.testYes(dir, 'java', p)

local dir = lfs.currentdir() .. '/test/java18/test/no/'
util.testNo(dir, 'java', p)
local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local ast = require'ast'
local util = require'util'

--[[
	Replaced labels to minimize number of grammar rules:
		Err_004 to Err_001
		Err_005 to Err_001
		Err_009 to Err_003
		Err_014 to Err_007
		Err_029 to Err_007
		Err_039 to Err_007
		Err_046 to Err_007
		Err_051 to Err_007
		Err_012 to Err_011
		Err_026 to Err_011
		Err_041 to Err_011
		Err_043 to Err_011
		Err_072 to Err_011
		Err_083 to Err_011
		Err_022 to Err_016
		Err_019 to Err_018
		Err_021 to Err_020
		Err_024 to Err_020
		Err_028 to Err_027
		Err_078 to Err_031
		Err_079 to Err_031
		Err_084 to Err_031
		Err_035 to Err_033
		Err_053 to Err_033
		Err_063 to Err_033
		Err_036 to Err_034
		Err_040 to Err_034
		Err_042 to Err_034
		Err_044 to Err_034
		Err_045 to Err_034
		Err_047 to Err_034
		Err_048 to Err_034
		Err_049 to Err_034
		Err_052 to Err_034
		Err_054 to Err_034
		Err_056 to Err_034
		Err_064 to Err_034
		Err_065 to Err_034
		Err_067 to Err_034
		Err_070 to Err_034
		Err_076 to Err_055
		Err_071 to Err_057
		Err_073 to Err_057
		Err_069 to Err_059
		Err_075 to Err_061
		Err_068 to Err_062
		Err_086 to Err_062
		Err_092 to Err_062
		Err_085 to Err_080
		Err_088 to Err_087
		Err_089 to Err_087
		Err_090 to Err_087
		Err_091 to Err_087
]]

g = [[
compilation     <-  SKIP compilationUnit (!.)^Err_EOF
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
wildcardBounds  <-  'extends' referenceType^Err_001  /  'super' referenceType^Err_001
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
typeParameterList <-  typeParameter (',' typeParameter^Err_003)*
superclass      <-  'extends' classType^Err_010
superinterfaces <-  'implements' interfaceTypeList^Err_011
interfaceTypeList <-  classType (',' classType^Err_011)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_013
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_007)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer^Err_015)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result methodDeclarator throws?
methodDeclarator <-  Identifier '('^Err_016 formalParameterList? ')'^Err_017 dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_018
exceptionTypeList <-  exceptionType (',' exceptionType^Err_018)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_020
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_020
constructorDeclarator <-  typeParameters? Identifier '('^Err_016 formalParameterList? ')'^Err_023
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_020
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
extendsInterfaces <-  'extends' interfaceTypeList^Err_011
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_027
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_027
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_007
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair)*
elementValuePair <-  Identifier '=' !'=' elementValue
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'^Err_030
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue ')'
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_031
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'^Err_032
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_033 statement^Err_034 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_033 statement^Err_034  /  'do' statement^Err_037 'while'^Err_038 parExpression^Err_007 ';'^Err_034  /  tryStatement  /  'switch' parExpression^Err_011 switchBlock^Err_034  /  'synchronized' parExpression^Err_011 block^Err_034  /  'return' expression? ';'^Err_034  /  'throw' expression^Err_007 ';'^Err_034  /  'break' Identifier? ';'^Err_034  /  'continue' Identifier? ';'^Err_034  /  'assert' expression^Err_050 (':' expression^Err_007)? ';'^Err_034  /  ';'  /  statementExpression ';'  /  Identifier ':'^Err_033 statement^Err_034
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)^Err_055  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'^Err_034
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName) ':'  /  'default' ':'
enumConstantName <-  Identifier
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_057)*
enhancedForStatement <-  'for' '('^Err_058 variableModifier* unannType^Err_059 variableDeclaratorId^Err_060 ':'^Err_061 expression^Err_062 ')'^Err_033 statement^Err_034
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_034  /  resourceSpecification block^Err_066 catchClause* finally?)^Err_034
catchClause     <-  'catch' '(' catchFormalParameter ')' block
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_062
catchType       <-  unannClassType ('|' ![=|] classType^Err_059)*
finally         <-  'finally' block^Err_034
resourceSpecification <-  '(' resourceList^Err_057 ';'? ')'^Err_011
resourceList    <-  resource (',' resource^Err_057)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_074 '='^Err_061 !'=' expression^Err_055
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression^Err_077 ']'^Err_031  /  '::' typeArguments? Identifier^Err_031
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments^Err_080 classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_081 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_082 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+^Err_011 arrayInitializer^Err_031
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'^Err_080
argumentList    <-  expression (',' expression^Err_062)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)^Err_087  /  '+' ![=+] unaryExpression^Err_087  /  '-' ![-=>] unaryExpression^Err_087  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_087  /  '!' ![=&] unaryExpression^Err_087  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
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
inferredFormalParameterList <-  Identifier (',' Identifier^Err_062)*
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
Token           <-  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throws'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'package'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'import'  /  'implements'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'extends'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'and'  /  'abstract'  /  StringLiteral  /  OctalNumeral  /  NullLiteral  /  Literal  /  Keywords  /  IntegerLiteral  /  InfixOperator  /  Identifier  /  HexaDecimalFloatingPointLiteral  /  HexSignificand  /  HexNumeral  /  HexDigits  /  HexDigit  /  FloatLiteral  /  Exponent  /  Digits  /  DecimalNumeral  /  DecimalFloatingPointLiteral  /  CharLiteral  /  COMMENT  /  BooleanLiteral  /  BinaryNumeral  /  BinaryExponent  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '?'  /  '>'  /  '='  /  '<'  /  ';'  /  '::'  /  ':'  /  '...'  /  '.'  /  '->'  /  '--'  /  '-'  /  ','  /  '++'  /  '+'  /  ')'  /  '('  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_EOF         <-  (!(!.) EatToken)*
Err_001         <-  (!('>'  /  ',') EatToken)*
Err_002         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_003         <-  (!'>' EatToken)*
Err_006         <-  (!(';'  /  '.') EatToken)*
Err_007         <-  (!';' EatToken)*
Err_008         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_010         <-  (!('{'  /  'implements') EatToken)*
Err_011         <-  (!'{' EatToken)*
Err_013         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '<'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  !.) EatToken)*
Err_015         <-  (!(';'  /  ',') EatToken)*
Err_016         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@'  /  ')') EatToken)*
Err_017         <-  (!('{'  /  'throws'  /  '['  /  '@'  /  ';') EatToken)*
Err_018         <-  (!('{'  /  ';') EatToken)*
Err_020         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_023         <-  (!('{'  /  'throws') EatToken)*
Err_025         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_027         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_030         <-  (!('}'  /  Identifier  /  ';'  /  ','  /  ')') EatToken)*
Err_031         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_032         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  InfixOperator  /  Identifier  /  ']'  /  '@'  /  '<'  /  ';'  /  ':'  /  '--'  /  ','  /  '++'  /  ')'  /  '(') EatToken)*
Err_033         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_034         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_037         <-  (!'while' EatToken)*
Err_038         <-  (!'(' EatToken)*
Err_050         <-  (!(';'  /  ':') EatToken)*
Err_055         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_057         <-  (!(';'  /  ')') EatToken)*
Err_058         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_059         <-  (!Identifier EatToken)*
Err_060         <-  (!':' EatToken)*
Err_061         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_062         <-  (!')' EatToken)*
Err_066         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_074         <-  (!'=' EatToken)*
Err_077         <-  (!']' EatToken)*
Err_080         <-  (!('}'  /  '{'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_081         <-  (!('<'  /  '(') EatToken)*
Err_082         <-  (!('.'  /  '(') EatToken)*
Err_087         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
util.testYes(dir, 'java', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/java18/test/no/' 
util.testNoRec(dir, 'java', p)
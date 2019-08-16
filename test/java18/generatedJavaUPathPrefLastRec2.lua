local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util = require'util'

-- Added 96 labels
-- Did not have to remove rules manually

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
normalClassDeclaration <-  classModifier* 'class' Identifier^Err_010 typeParameters? superclass? superinterfaces? classBody^Err_011
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  'extends' classType^Err_012
superinterfaces <-  'implements' interfaceTypeList^Err_013
interfaceTypeList <-  classType^Err_014 (',' classType^Err_015)*
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
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_016 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_017
exceptionTypeList <-  exceptionType^Err_018 (',' exceptionType^Err_019)*
exceptionType   <-  (classType  /  typeVariable)^Err_020
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier^Err_021 superinterfaces? enumBody^Err_022
enumBody        <-  '{'^Err_023 enumConstantList? ','? enumBodyDeclarations? '}'^Err_024
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier^Err_025 typeParameters? extendsInterfaces? interfaceBody^Err_026
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_027
interfaceBody   <-  '{'^Err_028 interfaceMemberDeclaration* '}'^Err_029
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier^Err_030 annotationTypeBody^Err_031
annotationTypeBody <-  '{'^Err_032 annotationTypeMemberDeclaration* '}'^Err_033
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
statement       <-  block  /  'if' parExpression^Err_034 statement^Err_035 ('else' statement^Err_036)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_037 statement^Err_038  /  'do' statement^Err_039 'while'^Err_040 parExpression^Err_041 ';'^Err_042  /  tryStatement  /  'switch' parExpression^Err_043 switchBlock^Err_044  /  'synchronized' parExpression block  /  'return' expression? ';'^Err_045  /  'throw' expression^Err_046 ';'^Err_047  /  'break' Identifier? ';'^Err_048  /  'continue' Identifier? ';'^Err_049  /  'assert' expression^Err_050 (':' expression^Err_051)? ';'^Err_052  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_053 switchBlockStatementGroup* switchLabel* '}'^Err_054
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_055 ':'^Err_056  /  'default' ':'
enumConstantName <-  Identifier^Err_057
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_058  /  resourceSpecification block^Err_059 catchClause* finally?)^Err_060
catchClause     <-  'catch' '('^Err_061 catchFormalParameter^Err_062 ')'^Err_063 block^Err_064
catchFormalParameter <-  variableModifier* catchType^Err_065 variableDeclaratorId^Err_066
catchType       <-  unannClassType^Err_067 ('|' ![=|] classType^Err_068)*
finally         <-  'finally' block^Err_069
resourceSpecification <-  '('^Err_070 resourceList^Err_071 ';'? ')'^Err_072
resourceList    <-  resource^Err_073 (',' resource^Err_074)*
resource        <-  variableModifier* unannType^Err_075 variableDeclaratorId^Err_076 '='^Err_077 !'=' expression^Err_078
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)^Err_079  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'^Err_080  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>' !'.'
arrayCreator    <-  (type dimExpr+ dim*  /  type dim+^Err_081 arrayInitializer^Err_082)^Err_083
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression^Err_084  /  '-' ![-=>] unaryExpression^Err_085  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_086  /  '!' ![=&] unaryExpression^Err_087  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression^Err_088  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression^Err_089  /  'instanceof' referenceType^Err_090)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression^Err_091 ':'^Err_092 expression^Err_093)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_094
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_095
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block)^Err_096
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
Err_EOF         <-  (!(!.) EatToken)*
Err_001         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_002         <-  (!('>'  /  ',') EatToken)*
Err_003         <-  (!('>'  /  ',') EatToken)*
Err_004         <-  (!(';'  /  '.') EatToken)*
Err_005         <-  (!';' EatToken)*
Err_006         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_007         <-  (!(';'  /  '.') EatToken)*
Err_008         <-  (!';' EatToken)*
Err_009         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_010         <-  (!('{'  /  'implements'  /  'extends'  /  '<') EatToken)*
Err_011         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_012         <-  (!('{'  /  'implements') EatToken)*
Err_013         <-  (!'{' EatToken)*
Err_014         <-  (!('{'  /  ',') EatToken)*
Err_015         <-  (!'{' EatToken)*
Err_016         <-  (!(','  /  ')') EatToken)*
Err_017         <-  (!('{'  /  ';') EatToken)*
Err_018         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_019         <-  (!('{'  /  ';') EatToken)*
Err_020         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_021         <-  (!('{'  /  'implements') EatToken)*
Err_022         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_023         <-  (!('}'  /  Identifier  /  '@'  /  ';'  /  ',') EatToken)*
Err_024         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_025         <-  (!('{'  /  'extends'  /  '<') EatToken)*
Err_026         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_027         <-  (!'{' EatToken)*
Err_028         <-  (!('}'  /  'void'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_029         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_030         <-  (!'{' EatToken)*
Err_031         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_032         <-  (!('}'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  ';') EatToken)*
Err_033         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_034         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_035         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_036         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_037         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_038         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_039         <-  (!'while' EatToken)*
Err_040         <-  (!'(' EatToken)*
Err_041         <-  (!';' EatToken)*
Err_042         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_043         <-  (!'{' EatToken)*
Err_044         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_045         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_046         <-  (!';' EatToken)*
Err_047         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_048         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_049         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_050         <-  (!(';'  /  ':') EatToken)*
Err_051         <-  (!';' EatToken)*
Err_052         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_053         <-  (!('}'  /  'default'  /  'case') EatToken)*
Err_054         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_055         <-  (!':' EatToken)*
Err_056         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_057         <-  (!':' EatToken)*
Err_058         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_059         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_060         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_061         <-  (!('final'  /  Identifier  /  '@') EatToken)*
Err_062         <-  (!')' EatToken)*
Err_063         <-  (!'{' EatToken)*
Err_064         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_065         <-  (!Identifier EatToken)*
Err_066         <-  (!')' EatToken)*
Err_067         <-  (!('|'  /  Identifier) EatToken)*
Err_068         <-  (!Identifier EatToken)*
Err_069         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_070         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_071         <-  (!(';'  /  ')') EatToken)*
Err_072         <-  (!'{' EatToken)*
Err_073         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_074         <-  (!(';'  /  ')') EatToken)*
Err_075         <-  (!Identifier EatToken)*
Err_076         <-  (!'=' EatToken)*
Err_077         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_078         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_079         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_080         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_081         <-  (!'{' EatToken)*
Err_082         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_083         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_084         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_085         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_086         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_087         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_088         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_089         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_090         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_091         <-  (!':' EatToken)*
Err_092         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_093         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_094         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_095         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_096         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
util.testYes(dir, 'java', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/java18/test/no/' 
util.testNoRec(dir, 'java', p)

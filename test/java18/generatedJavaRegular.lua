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
    - Err_027 (';' in rule fieldDeclaration)
    - Err_175 (AssignmentOperator in rule assignment)
    - Err_177 ('->' in rule lambdaExpression)
    - Err_002 (dim+ in rule arrayType)
    - Err_040 ('.' in rule receiverParameter)
    - Err_041 ('this' in rule receiverParameter)
    - Err_085 (variableDeclaratorList in rule localVariableDeclaration)
    - Err_007 ('>' in rule typeArguments)
    - Err_073 ('(' in rule normalAnnotation)
    - Err_079 ('(' in rule singleElementAnnotation)
    - Err_038 ('...' in rule formalParameter)
    - Err_180 (')' in rule lambdaParameters)
    - Err_173 (')' in rule castExpression)
    - Err_003 (']' in rule dim)
    - Err_006 (typeArgumentList in rule typeArguments)
    - Err_110 (blockStatements in rule switchBlockStatementGroup)
    - Err_172 (referenceType in rule castExpression)
    - Err_030 (Identifier in rule unannClassType)
    - Err_115 (';' in rule basicForStatement)
    - Err_076 ('=' in rule elementValuePair)
    - Err_074 (')' in rule normalAnnotation)
    - Err_026 (variableDeclaratorList in rule fieldDeclaration)
    - Err_032 (methodDeclarator in rule methodHeader)
    - Err_174 (unaryExpressionNotPlusMinus in rule castExpression)
    - Err_049 ('.' in rule explicitConstructorInvocation)
    - Err_001 (Identifier in rule classType)
    - Err_152 (sorted choose in rule primaryRest)
    - Err_179 (inferredFormalParameterList in rule lambdaParameters)
    - Err_156 (expression in rule parExpression)
    - Err_072 (sorted choose in rule annotation)
    - Err_061 (';' in rule constantDeclaration)
    - Err_163 (expression in rule dimExpr)
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
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)^Err_004
additionalBound <-  'and' classType^Err_005
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument^Err_008)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_009  /  'super' referenceType^Err_010
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_011 ('.' Identifier^Err_012)* ';'^Err_013
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_014 ('.' '*'^Err_015)? ';'^Err_016  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier^Err_017 typeParameters? superclass? superinterfaces? classBody^Err_018
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList^Err_019 '>'^Err_020
typeParameterList <-  typeParameter (',' typeParameter^Err_021)*
superclass      <-  'extends' classType^Err_022
superinterfaces <-  'implements' interfaceTypeList^Err_023
interfaceTypeList <-  classType (',' classType^Err_024)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_025
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_028)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer^Err_029)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody^Err_031
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result^Err_033 methodDeclarator^Err_034 throws?
methodDeclarator <-  Identifier '('^Err_035 formalParameterList? ')'^Err_036 dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter^Err_037)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_039 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_042
exceptionTypeList <-  exceptionType (',' exceptionType^Err_043)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_044
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_045
constructorDeclarator <-  typeParameters? Identifier '('^Err_046 formalParameterList? ')'^Err_047
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_048
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super'^Err_050 arguments^Err_051 ';'^Err_052
enumDeclaration <-  classModifier* 'enum' Identifier^Err_053 superinterfaces? enumBody^Err_054
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_055
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier^Err_056 typeParameters? extendsInterfaces? interfaceBody^Err_057
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_058
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_059
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList^Err_060 ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody^Err_062
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface'^Err_063 Identifier^Err_064 annotationTypeBody^Err_065
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_066
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier^Err_067 '('^Err_068 ')'^Err_069 dim* defaultValue? ';'^Err_070
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_071
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair^Err_075)*
elementValuePair <-  Identifier '=' !'=' elementValue^Err_077
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'^Err_078
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue^Err_080 ')'^Err_081
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_082
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'^Err_083
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'^Err_084
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_086 statement^Err_087 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_088 statement^Err_089  /  'do' statement^Err_090 'while'^Err_091 parExpression^Err_092 ';'^Err_093  /  tryStatement  /  'switch' parExpression^Err_094 switchBlock^Err_095  /  'synchronized' parExpression^Err_096 block^Err_097  /  'return' expression? ';'^Err_098  /  'throw' expression^Err_099 ';'^Err_100  /  'break' Identifier? ';'^Err_101  /  'continue' Identifier? ';'^Err_102  /  'assert' expression^Err_103 (':' expression^Err_104)? ';'^Err_105  /  ';'  /  statementExpression ';'  /  Identifier ':'^Err_106 statement^Err_107
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)^Err_108  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'^Err_109
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_111 ':'^Err_112  /  'default' ':'^Err_113
enumConstantName <-  Identifier
basicForStatement <-  'for' '('^Err_114 forInit? ';' expression? ';'^Err_116 forUpdate? ')'^Err_117 statement^Err_118
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_119)*
enhancedForStatement <-  'for' '('^Err_120 variableModifier* unannType^Err_121 variableDeclaratorId^Err_122 ':'^Err_123 expression^Err_124 ')'^Err_125 statement^Err_126
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_127  /  resourceSpecification block^Err_128 catchClause* finally?)^Err_129
catchClause     <-  'catch' '('^Err_130 catchFormalParameter^Err_131 ')'^Err_132 block^Err_133
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_134
catchType       <-  unannClassType ('|' ![=|] classType^Err_135)*
finally         <-  'finally' block^Err_136
resourceSpecification <-  '(' resourceList^Err_137 ';'? ')'^Err_138
resourceList    <-  resource (',' resource^Err_139)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_140 '='^Err_141 !'=' expression^Err_142
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier^Err_143  /  '::' typeArguments? Identifier^Err_144)^Err_145  /  'new' (classCreator  /  arrayCreator)^Err_146  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'^Err_147 'class'^Err_148  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::'^Err_149 'new'^Err_150
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator^Err_151)  /  '[' expression^Err_153 ']'^Err_154  /  '::' typeArguments? Identifier^Err_155
parExpression   <-  '(' expression ')'^Err_157
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments^Err_158 classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_159 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_160 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+^Err_161 arrayInitializer^Err_162
dimExpr         <-  annotation* '[' expression ']'^Err_164
arguments       <-  '(' argumentList? ')'^Err_165
argumentList    <-  expression (',' expression^Err_166)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)^Err_167  /  '+' ![=+] unaryExpression^Err_168  /  '-' ![-=>] unaryExpression^Err_169  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_170  /  '!' ![=&] unaryExpression^Err_171  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_176
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_178
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier^Err_181)*
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
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
util.testYes(dir, 'java', p)

local dir = lfs.currentdir() .. '/test/java18/test/no/' 
util.testNo(dir, 'java', p)
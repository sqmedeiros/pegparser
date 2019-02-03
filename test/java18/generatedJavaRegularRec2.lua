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
  
  Changed:
    Err_009 to Err_004
    Err_010 to Err_004
    Err_016 to Err_013
    Err_014 to Err_011
    Err_019 to Err_008
    Err_021 to Err_008
    Err_015 to Err_012
    Err_028 to Err_012
    Err_051 to Err_012
    Err_060 to Err_012
    Err_071 to Err_012
    Err_092 to Err_012
    Err_099 to Err_012
    Err_104 to Err_012
    Err_054 to Err_018
    Err_055 to Err_018
    Err_053 to Err_022
    Err_024 to Err_023
    Err_058 to Err_023
    Err_064 to Err_023
    Err_094 to Err_023
    Err_096 to Err_023
    Err_132 to Err_023
    Err_138 to Err_023
    Err_161 to Err_023
    Err_044 to Err_031
    Err_045 to Err_031
    Err_048 to Err_031
    Err_063 to Err_033
    Err_121 to Err_033
    Err_135 to Err_033
    Err_046 to Err_035
    Err_068 to Err_037
    Err_080 to Err_037
    Err_124 to Err_037
    Err_131 to Err_037
    Err_134 to Err_037
    Err_166 to Err_037
    Err_181 to Err_037
    Err_043 to Err_042
    Err_067 to Err_050
    Err_091 to Err_050
    Err_059 to Err_057
    Err_065 to Err_057
    Err_066 to Err_057
    Err_143 to Err_082
    Err_144 to Err_082
    Err_145 to Err_082
    Err_146 to Err_082
    Err_148 to Err_082
    Err_150 to Err_082
    Err_151 to Err_082
    Err_154 to Err_082
    Err_155 to Err_082
    Err_162 to Err_082
    Err_112 to Err_084
    Err_113 to Err_084
    Err_088 to Err_086
    Err_106 to Err_086
    Err_117 to Err_086
    Err_125 to Err_086
    Err_089 to Err_087
    Err_093 to Err_087
    Err_095 to Err_087
    Err_097 to Err_087
    Err_098 to Err_087
    Err_100 to Err_087
    Err_101 to Err_087
    Err_102 to Err_087
    Err_105 to Err_087
    Err_107 to Err_087
    Err_109 to Err_087
    Err_118 to Err_087
    Err_126 to Err_087
    Err_127 to Err_087
    Err_129 to Err_087
    Err_136 to Err_087
    Err_142 to Err_108
    Err_122 to Err_111
    Err_137 to Err_119
    Err_139 to Err_119
    Err_141 to Err_123
    Err_133 to Err_128
    Err_165 to Err_158
    Err_168 to Err_167
    Err_169 to Err_167
    Err_170 to Err_167
    Err_171 to Err_167
    Err_176 to Err_167
    Err_178 to Err_167
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
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)^Err_004
additionalBound <-  'and' classType^Err_005
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument^Err_008)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_004  /  'super' referenceType^Err_004
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_011 ('.' Identifier^Err_012)* ';'^Err_013
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_011 ('.' '*'^Err_012)? ';'^Err_013  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier^Err_017 typeParameters? superclass? superinterfaces? classBody^Err_018
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList^Err_008 '>'^Err_020
typeParameterList <-  typeParameter (',' typeParameter^Err_008)*
superclass      <-  'extends' classType^Err_022
superinterfaces <-  'implements' interfaceTypeList^Err_023
interfaceTypeList <-  classType (',' classType^Err_023)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_025
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_012)*
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
exceptionTypeList <-  exceptionType (',' exceptionType^Err_042)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_031
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_031
constructorDeclarator <-  typeParameters? Identifier '('^Err_035 formalParameterList? ')'^Err_047
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_031
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super'^Err_050 arguments^Err_012 ';'^Err_052
enumDeclaration <-  classModifier* 'enum' Identifier^Err_022 superinterfaces? enumBody^Err_018
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_018
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier^Err_056 typeParameters? extendsInterfaces? interfaceBody^Err_057
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_023
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_057
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList^Err_012 ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody^Err_062
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface'^Err_033 Identifier^Err_023 annotationTypeBody^Err_057
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_057
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier^Err_050 '('^Err_037 ')'^Err_069 dim* defaultValue? ';'^Err_070
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_012
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair^Err_075)*
elementValuePair <-  Identifier '=' !'=' elementValue^Err_077
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'^Err_078
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue^Err_037 ')'^Err_081
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_082
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'^Err_083
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'^Err_084
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_086 statement^Err_087 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_086 statement^Err_087  /  'do' statement^Err_090 'while'^Err_050 parExpression^Err_012 ';'^Err_087  /  tryStatement  /  'switch' parExpression^Err_023 switchBlock^Err_087  /  'synchronized' parExpression^Err_023 block^Err_087  /  'return' expression? ';'^Err_087  /  'throw' expression^Err_012 ';'^Err_087  /  'break' Identifier? ';'^Err_087  /  'continue' Identifier? ';'^Err_087  /  'assert' expression^Err_103 (':' expression^Err_012)? ';'^Err_087  /  ';'  /  statementExpression ';'  /  Identifier ':'^Err_086 statement^Err_087
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)^Err_108  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'^Err_087
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_111 ':'^Err_084  /  'default' ':'^Err_084
enumConstantName <-  Identifier
basicForStatement <-  'for' '('^Err_114 forInit? ';' expression? ';'^Err_116 forUpdate? ')'^Err_086 statement^Err_087
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_119)*
enhancedForStatement <-  'for' '('^Err_120 variableModifier* unannType^Err_033 variableDeclaratorId^Err_111 ':'^Err_123 expression^Err_037 ')'^Err_086 statement^Err_087
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_087  /  resourceSpecification block^Err_128 catchClause* finally?)^Err_087
catchClause     <-  'catch' '('^Err_130 catchFormalParameter^Err_037 ')'^Err_023 block^Err_128
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_037
catchType       <-  unannClassType ('|' ![=|] classType^Err_033)*
finally         <-  'finally' block^Err_087
resourceSpecification <-  '(' resourceList^Err_119 ';'? ')'^Err_023
resourceList    <-  resource (',' resource^Err_119)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_140 '='^Err_123 !'=' expression^Err_108
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier^Err_082  /  '::' typeArguments? Identifier^Err_082)^Err_082  /  'new' (classCreator  /  arrayCreator)^Err_082  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'^Err_147 'class'^Err_082  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::'^Err_149 'new'^Err_082
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator^Err_082)  /  '[' expression^Err_153 ']'^Err_082  /  '::' typeArguments? Identifier^Err_082
parExpression   <-  '(' expression ')'^Err_157
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments^Err_158 classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_159 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_160 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+^Err_023 arrayInitializer^Err_082
dimExpr         <-  annotation* '[' expression ']'^Err_164
arguments       <-  '(' argumentList? ')'^Err_158
argumentList    <-  expression (',' expression^Err_037)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)^Err_167  /  '+' ![=+] unaryExpression^Err_167  /  '-' ![-=>] unaryExpression^Err_167  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_167  /  '!' ![=&] unaryExpression^Err_167  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_167
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_167
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier^Err_037)*
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
Token           <-  '~'  /  '}'  /  '|'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throws'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'package'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'import'  /  'implements'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'extends'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'and'  /  'abstract'  /  StringLiteral  /  OctalNumeral  /  NullLiteral  /  Literal  /  Keywords  /  IntegerLiteral  /  InfixOperator  /  Identifier  /  HexaDecimalFloatingPointLiteral  /  HexSignificand  /  HexNumeral  /  HexDigits  /  HexDigit  /  FloatLiteral  /  Exponent  /  Digits  /  DecimalNumeral  /  DecimalFloatingPointLiteral  /  CharLiteral  /  COMMENT  /  BooleanLiteral  /  BinaryNumeral  /  BinaryExponent  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '?'  /  '>'  /  '='  /  '<'  /  ';'  /  '::'  /  ':'  /  '...'  /  '.'  /  '->'  /  '--'  /  '-'  /  ','  /  '++'  /  '+'  /  ')'  /  '('  /  '!'
EatToken        <-  (Token  /  (!SKIP .)+) SKIP
Err_EOF         <-  (!(!.) EatToken)*
Err_004         <-  (!('>'  /  ',') EatToken)*
Err_005         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_008         <-  (!'>' EatToken)*
Err_011         <-  (!(';'  /  '.') EatToken)*
Err_012         <-  (!';' EatToken)*
Err_013         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_017         <-  (!('{'  /  'implements'  /  'extends'  /  '<') EatToken)*
Err_018         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_020         <-  (!('{'  /  'void'  /  'short'  /  'long'  /  'int'  /  'implements'  /  'float'  /  'extends'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_022         <-  (!('{'  /  'implements') EatToken)*
Err_023         <-  (!'{' EatToken)*
Err_025         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '<'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  !.) EatToken)*
Err_029         <-  (!(';'  /  ',') EatToken)*
Err_031         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_033         <-  (!Identifier EatToken)*
Err_034         <-  (!('{'  /  'throws'  /  ';') EatToken)*
Err_035         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@'  /  ')') EatToken)*
Err_036         <-  (!('{'  /  'throws'  /  '['  /  '@'  /  ';') EatToken)*
Err_037         <-  (!')' EatToken)*
Err_039         <-  (!(','  /  ')') EatToken)*
Err_042         <-  (!('{'  /  ';') EatToken)*
Err_047         <-  (!('{'  /  'throws') EatToken)*
Err_050         <-  (!'(' EatToken)*
Err_052         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'continue'  /  'class'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_056         <-  (!('{'  /  'extends'  /  '<') EatToken)*
Err_057         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_062         <-  (!('}'  /  'void'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_069         <-  (!('default'  /  '['  /  '@'  /  ';') EatToken)*
Err_070         <-  (!('}'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  ';') EatToken)*
Err_075         <-  (!(Identifier  /  ')') EatToken)*
Err_077         <-  (!(Identifier  /  ','  /  ')') EatToken)*
Err_078         <-  (!('}'  /  Identifier  /  ';'  /  ','  /  ')') EatToken)*
Err_081         <-  (!('}'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'package'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '['  /  '@'  /  '?'  /  '<'  /  ';'  /  '...'  /  ','  /  ')') EatToken)*
Err_082         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_083         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  InfixOperator  /  Identifier  /  ']'  /  '@'  /  '<'  /  ';'  /  ':'  /  '--'  /  ','  /  '++'  /  ')'  /  '(') EatToken)*
Err_084         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_086         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_087         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_090         <-  (!'while' EatToken)*
Err_103         <-  (!(';'  /  ':') EatToken)*
Err_108         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_111         <-  (!':' EatToken)*
Err_114         <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_116         <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '++'  /  ')'  /  '(') EatToken)*
Err_119         <-  (!(';'  /  ')') EatToken)*
Err_120         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_123         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_128         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_130         <-  (!('final'  /  Identifier  /  '@') EatToken)*
Err_140         <-  (!'=' EatToken)*
Err_147         <-  (!'class' EatToken)*
Err_149         <-  (!'new' EatToken)*
Err_153         <-  (!']' EatToken)*
Err_157         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'query'  /  'new'  /  'long'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')'  /  '(') EatToken)*
Err_158         <-  (!('}'  /  '{'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_159         <-  (!('<'  /  '(') EatToken)*
Err_160         <-  (!('.'  /  '(') EatToken)*
Err_164         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_167         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
util.testYes(dir, 'java', p)

util.setVerbose(true)
local dir = lfs.currentdir() .. '/test/java18/test/no/' 
util.testNoRec(dir, 'java', p)
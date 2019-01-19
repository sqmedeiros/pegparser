local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

--[[
  Removed labels:
    - Err_001 (dim+ in rule arrayType)
    - Err_025 ('.' in rule receiverParameter)
    - Err_026 ('this' in rule receiverParameter)
    - Err_023 ('...' in rule formalParameter)
    - Err_079 (')' in rule lambdaParameters)
    - Err_076 (')' in rule castExpression)
    - Err_075 (referenceType in rule castExpression)
    - Err_044 ('=' in rule elementValuePair)
    - Err_017 (methodDeclarator in rule methodHeader)
    - Err_016 (Identifier in rule unannClassType)
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
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)^Err_002
additionalBound <-  'and' classType^Err_003
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument^Err_004)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_005  /  'super' referenceType^Err_006
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier ('.' Identifier)* ';'
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent ('.' '*')? ';'  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier typeParameters? superclass? superinterfaces? classBody
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList^Err_007 '>'^Err_008
typeParameterList <-  typeParameter (',' typeParameter^Err_009)*
superclass      <-  'extends' classType^Err_010
superinterfaces <-  'implements' interfaceTypeList^Err_011
interfaceTypeList <-  classType (',' classType^Err_012)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_013
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_014)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer^Err_015)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result^Err_018 methodDeclarator^Err_019 throws?
methodDeclarator <-  Identifier '('^Err_020 formalParameterList? ')'^Err_021 dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter^Err_022)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_024 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_027
exceptionTypeList <-  exceptionType (',' exceptionType^Err_028)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_029
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_030
constructorDeclarator <-  typeParameters? Identifier '('^Err_031 formalParameterList? ')'^Err_032
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_033
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier superinterfaces? enumBody
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_034
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier typeParameters? extendsInterfaces? interfaceBody
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_035
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_036
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_037
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier^Err_038 '('^Err_039 ')'^Err_040 dim* defaultValue? ';'^Err_041
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_042
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
elementValuePairList <-  elementValuePair (',' elementValuePair^Err_043)*
elementValuePair <-  Identifier '=' !'=' elementValue^Err_045
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue ')'
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_046
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'^Err_047
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression statement ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression statement  /  'do' statement 'while' parExpression ';'  /  tryStatement  /  'switch' parExpression switchBlock  /  'synchronized' parExpression block  /  'return' expression? ';'  /  'throw' expression ';'  /  'break' Identifier? ';'  /  'continue' Identifier? ';'  /  'assert' expression (':' expression)? ';'  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_048 ':'^Err_049  /  'default' ':'^Err_050
enumConstantName <-  Identifier
basicForStatement <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_051)*
enhancedForStatement <-  'for' '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)  /  resourceSpecification block catchClause* finally?)
catchClause     <-  'catch' '(' catchFormalParameter ')' block
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_052
catchType       <-  unannClassType ('|' ![=|] classType^Err_053)*
finally         <-  'finally' block
resourceSpecification <-  '(' resourceList^Err_054 ';'? ')'^Err_055
resourceList    <-  resource (',' resource^Err_056)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_057 '='^Err_058 !'=' expression^Err_059
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier^Err_060  /  '::' typeArguments? Identifier^Err_061)^Err_062  /  'new' (classCreator  /  arrayCreator)^Err_063  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'^Err_064 'class'^Err_065  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::'^Err_066 'new'^Err_067
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_068 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_069 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+^Err_070 arrayInitializer^Err_071
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression^Err_072)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression  /  '-' ![-=>] unaryExpression  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_073  /  '!' ![=&] unaryExpression^Err_074  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus^Err_077
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList^Err_078 ')'
inferredFormalParameterList <-  Identifier (',' Identifier^Err_080)*
lambdaBody      <-  expression  /  block
constantExpression <-  expression
Identifier      <-  !keywords [a-zA-Z_] [a-zA-Z_$0-9]*
keywords        <-  'abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected'  /  'public'  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while'
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
Token           <-  keywords  /  Identifier  /  Literal  /  .
COMMENT         <-  '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
]]

local g = m.match(g)

local p = coder.makeg(g)

local dir = lfs.currentdir() .. '/test/java18/test/yes/' 
for file in lfs.dir(dir) do
  if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'java' + 1) == 'java' then
    print("Yes: ", file)
    local f = io.open(dir .. file)
    local s = f:read('a')
    f:close()
    local r, lab, pos = p:match(s)
    local line, col = '', ''
    if not r then
      line, col = re.calcline(s, pos)
    end
    assert(r ~= nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
  end
end

local dir = lfs.currentdir() .. '/test/java18/test/no/'  
for file in lfs.dir(dir) do
  if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'java' + 1) == 'java' then
    print("No: ", file)
    local f = io.open(dir .. file)
    local s = f:read('a')
    f:close()
    local r, lab, pos = p:match(s)
    io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
    local line, col = '', ''
    if not r then
      line, col = re.calcline(s, pos)
      io.write(' line: ' .. line .. ' col: ' .. col)
    end
    io.write('\n')
    assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
  end
end
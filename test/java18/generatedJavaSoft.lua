local m = require 'init'
local recovery = require 'recovery'
local pretty = require 'pretty'
local coder = require 'coder'
local lfs = require 'lfs'
local re = require 'relabel'
local first = require'first'

local function assertErr (p, s, lab)
  local r, l, pos = p:match(s)
  assert(not r, "Did not fail: r = " .. tostring(r))
  if lab then
    assert(l == lab, "Expected label '" .. tostring(lab) .. "' but got " .. tostring(l))
  end
end

local function assertOk(p, s)
  local r, l, pos = p:match(s)
  assert(r, 'Failed: label = ' .. tostring(l) .. ', pos = ' .. tostring(pos))
  assert(r == #s + 1, "Matched until " .. r)
end


local tree, rules =  m.match[[
compilation     <-  skip compilationUnit !.
basicType       <-  'byte'  /  'short'  /  'int'  /  'long' 'char'^Err_001  /  'float'  /  'double'  /  'boolean'
primitiveType   <-  annotation* basicType
referenceType   <-  primitiveType dim+  /  classType dim*
classType       <-  annotation* Identifier typeArguments? ('.' annotation* Identifier^Err_002 typeArguments?)*
type            <-  primitiveType  /  classType
arrayType       <-  primitiveType dim+  /  classType dim+^Err_003
typeVariable    <-  annotation* Identifier
dim             <-  annotation* '[' ']'^Err_004
typeParameter   <-  typeParameterModifier* Identifier typeBound?
typeParameterModifier <-  annotation
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)^Err_005
additionalBound <-  'and' classType^Err_006
typeArguments   <-  '<' typeArgumentList^Err_007 '>'^Err_008
typeArgumentList <-  typeArgument (',' typeArgument^Err_009)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* 'query' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_010  /  'super' referenceType^Err_011
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_012 ('.' Identifier^Err_013)* ';'^Err_014
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_015 ('.' '*'^Err_016)? ';'^Err_017  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier^Err_018 typeParameters? superclass? superinterfaces? classBody^Err_019
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList^Err_020 '>'^Err_021
typeParameterList <-  typeParameter (',' typeParameter^Err_022)*
superclass      <-  'extends' classType^Err_023
superinterfaces <-  'implements' interfaceTypeList^Err_024
interfaceTypeList <-  classType (',' classType^Err_025)*
classBody       <-  '{' classBodyDeclaration* '}'^Err_026
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList^Err_027 ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator^Err_029)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer^Err_030)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier^Err_031 typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody^Err_032
methodHeader    <-  result methodDeclarator^Err_033 throws?  /  typeParameters annotation* result^Err_034 methodDeclarator^Err_035 throws?
methodDeclarator <-  Identifier '('^Err_036 formalParameterList? ')'^Err_037 dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter^Err_038)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...'^Err_039 variableDeclaratorId^Err_040 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_043
exceptionTypeList <-  exceptionType (',' exceptionType^Err_044)*
exceptionType   <-  classType  /  typeVariable
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block^Err_045
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody^Err_046
constructorDeclarator <-  typeParameters? Identifier '('^Err_047 formalParameterList? ')'^Err_048
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'^Err_049
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.'^Err_050 typeArguments? 'super'^Err_051 arguments^Err_052 ';'^Err_053
enumDeclaration <-  classModifier* 'enum' Identifier^Err_054 superinterfaces? enumBody^Err_055
enumBody        <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^Err_056
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier^Err_057 typeParameters? extendsInterfaces? interfaceBody^Err_058
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_059
interfaceBody   <-  '{' interfaceMemberDeclaration* '}'^Err_060
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList^Err_061 ';'^Err_062
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody^Err_063
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface'^Err_064 Identifier^Err_065 annotationTypeBody^Err_066
annotationTypeBody <-  '{' annotationTypeMemberDeclaration* '}'^Err_067
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier^Err_068 '('^Err_069 ')'^Err_070 dim* defaultValue? ';'^Err_071
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue^Err_072
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)^Err_073
normalAnnotation <-  qualIdent '('^Err_074 elementValuePairList* ')'^Err_075
elementValuePairList <-  elementValuePair (',' elementValuePair^Err_076)*
elementValuePair <-  Identifier '='^Err_077 !'=' elementValue^Err_078
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'^Err_079
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '('^Err_080 elementValue^Err_081 ')'^Err_082
arrayInitializer <-  '{' variableInitializerList? ','? '}'^Err_083
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'^Err_084
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'^Err_085
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  'if' parExpression^Err_087 statement^Err_088 ('else' statement)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_089 statement^Err_090  /  'do' statement^Err_091 'while'^Err_092 parExpression^Err_093 ';'^Err_094  /  tryStatement  /  'switch' parExpression^Err_095 switchBlock^Err_096  /  'synchronized' parExpression^Err_097 block^Err_098  /  'return' expression? ';'^Err_099  /  'throw' expression^Err_100 ';'^Err_101  /  'break' Identifier? ';'^Err_102  /  'continue' Identifier? ';'^Err_103  /  'assert' expression^Err_104 (':' expression^Err_105)? ';'^Err_106  /  ';'  /  statementExpression ';'  /  Identifier ':'^Err_107 statement^Err_108
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)^Err_109  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{' switchBlockStatementGroup* switchLabel* '}'^Err_110
switchBlockStatementGroup <-  switchLabels blockStatements^Err_111
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_112 ':'^Err_113  /  'default' ':'^Err_114
enumConstantName <-  Identifier
basicForStatement <-  'for' '('^Err_115 forInit? ';'^Err_116 expression? ';'^Err_117 forUpdate? ')'^Err_118 statement^Err_119
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression^Err_120)*
enhancedForStatement <-  'for' '('^Err_121 variableModifier* unannType^Err_122 variableDeclaratorId^Err_123 ':'^Err_124 expression^Err_125 ')'^Err_126 statement^Err_127
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_128  /  resourceSpecification block^Err_129 catchClause* finally?)^Err_130
catchClause     <-  'catch' '('^Err_131 catchFormalParameter^Err_132 ')'^Err_133 block^Err_134
catchFormalParameter <-  variableModifier* catchType variableDeclaratorId^Err_135
catchType       <-  unannClassType ('or' classType^Err_136)*
finally         <-  'finally' block^Err_137
resourceSpecification <-  '(' resourceList^Err_138 ';'? ')'^Err_139
resourceList    <-  resource (',' resource^Err_140)*
resource        <-  variableModifier* unannType variableDeclaratorId^Err_141 '='^Err_142 !'=' expression^Err_143
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier^Err_144  /  '::' typeArguments? Identifier^Err_145)^Err_146  /  'new' (classCreator  /  arrayCreator)^Err_147  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator  /  'new' classCreator  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier arguments)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'^Err_148 'class'^Err_149  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::'^Err_150 'new'^Err_151
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator^Err_152)^Err_153  /  '[' expression^Err_154 ']'^Err_155  /  '::' typeArguments? Identifier^Err_156
parExpression   <-  '(' expression^Err_157 ')'^Err_158
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments^Err_159 classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier^Err_160 typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'^Err_161 !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+^Err_162 arrayInitializer^Err_163
dimExpr         <-  annotation* '[' expression^Err_164 ']'^Err_165
arguments       <-  '(' argumentList? ')'^Err_166
argumentList    <-  expression (',' expression^Err_167)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)^Err_168  /  '+' ![=+] unaryExpression^Err_169  /  '-' ![-=>] unaryExpression^Err_170  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_171  /  '!' ![=&] unaryExpression^Err_172  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType^Err_173 additionalBound* ')'^Err_174 unaryExpressionNotPlusMinus^Err_175
infixExpression <-  unaryExpression (InfixOperator unaryExpression  /  'instanceof' referenceType)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_177
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->'^Err_178 lambdaBody^Err_179
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList^Err_180 ')'^Err_181
inferredFormalParameterList <-  Identifier (',' Identifier^Err_182)*
lambdaBody      <-  expression  /  block
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  'abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected' 'public'^Err_183  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while'
Literal         <-  FloatLiteral  /  IntegerLiteral  /  BooleanLiteral  /  CharLiteral  /  StringLiteral  /  NullLiteral
IntegerLiteral  <-  (HexNumeral  /  BinaryNumeral  /  OctalNumeral  /  DecimalNumeral) [lL]?
DecimalNumeral  <-  '0'  /  [1-9] ([_]* [0-9])*
HexNumeral      <-  ('0x'  /  '0X') HexDigits^Err_184
OctalNumeral    <-  '0' ([_]* [0-7])+
BinaryNumeral   <-  ('0b'  /  '0B') [01] ([_]* [01])*
FloatLiteral    <-  HexaDecimalFloatingPointLiteral  /  DecimalFloatingPointLiteral
DecimalFloatingPointLiteral <-  Digits '.' Digits? Exponent? [fFdD]?  /  '.' Digits^Err_185 Exponent? [fFdD]?  /  Digits Exponent [fFdD]?  /  Digits Exponent? [fFdD]
Exponent        <-  [eE] [-+]? Digits^Err_186
HexaDecimalFloatingPointLiteral <-  HexSignificand BinaryExponent^Err_187 [fFdD]?
HexSignificand  <-  ('0x'  /  '0X') HexDigits? '.' HexDigits  /  HexNumeral '.'?
HexDigits       <-  HexDigit ([_]* HexDigit)*
HexDigit        <-  [a-f]  /  [A-F]  /  [0-9]
BinaryExponent  <-  [pP] [-+]? Digits^Err_188
Digits          <-  [0-9] ([_]* [0-9])*
BooleanLiteral  <-  'true'  /  'false'
CharLiteral     <-  "'" ('\n'  /  !"'" .)^Err_189 "'"^Err_190
StringLiteral   <-  '"' ('\n'  /  !'"' .)* '"'^Err_191
NullLiteral     <-  'NULL'
Token           <-  Keywords  /  Identifier  /  Literal  /  .
]] 


print('tree', tree, rules)                        
print(pretty.printg(tree, rules), '\n')
local p = coder.makeg(tree, rules)

--first.calcFst(tree)
--first.calcFlw(tree, rules[1])
--first.printfirst(tree, rules)

local treelab, ruleslab = recovery.addlab(tree, rules, false, 'soft')
print(pretty.printg(treelab, ruleslab, true), '\n')

local p = coder.makeg(tree, rules)

local dir = lfs.currentdir() .. '/test/java18/test/yes/'	
for file in lfs.dir(dir) do
	if file ~= '.' and file ~= '..' and string.sub(file, #file - 3) == 'java' then
		print("file = ", file)
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

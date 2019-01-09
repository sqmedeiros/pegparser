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
compilation           <-  SKIP compilationUnit (!.)^EndErr

-- JLS 4 Types, Values and Variables
basicType            <-  'byte'  /  'short'  /  'int'  /  'long' /
                         'char'  /  'float'  /  'double'  /  'boolean'

primitiveType        <-  annotation* basicType

referenceType        <-  primitiveType dim+  /  classType dim*

classType            <-  annotation* Identifier typeArguments?
                           ('.' annotation* Identifier typeArguments?)*

type                 <-  primitiveType  /  classType

arrayType            <-  primitiveType dim+  /  classType dim+

typeVariable         <-  annotation* Identifier

dim                  <-  annotation* '[' ']'

typeParameter        <-  typeParameterModifier* Identifier typeBound?

typeParameterModifier  <-  annotation

typeBound            <-  'extends' (classType additionalBound*  /  typeVariable)^Err_004

additionalBound      <-  'and' classType^ClassTypeErr1

typeArguments        <-  '<' typeArgumentList '>'

typeArgumentList     <-  typeArgument (',' typeArgument^TypeArgumentErr)*

typeArgument         <-  referenceType  /  wildcard

wildcard             <-  annotation* '?' wildcardBounds?

wildcardBounds       <-  'extends' referenceType^ReferenceTypeErr1  / 'super' referenceType^ReferenceTypeErr2


-- JLS 6 Names
qualIdent            <-  Identifier ('.' Identifier)*


-- JLS 7 Packages
compilationUnit      <-  packageDeclaration? importDeclaration* typeDeclaration*

packageDeclaration   <-  packageModifier* 'package' Identifier^IdErr1 ('.' Identifier^IdErr2)* ';'^SemiErr1

packageModifier      <-  annotation

importDeclaration    <-  'import' 'static'? qualIdent^QualIdentErr1 ('.' '*'^AsteriskErr)? ';'^SemiErr2  /  ';'

typeDeclaration      <-  classDeclaration  /  interfaceDeclaration  /  ';'


-- JLS 8 Classes
classDeclaration     <-  normalClassDeclaration  /  enumDeclaration

normalClassDeclaration  <-  classModifier* 'class' Identifier^IdErr3 typeParameters?
                              superclass? superinterfaces? classBody^ClassBodyErr

classModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'abstract'  /  'static'  /  'final'  /  'strictfp'

typeParameters       <-  '<' typeParameterList^TypeParameterListErr '>'^GeqErr

typeParameterList    <-  typeParameter (',' typeParameter^TypeParameterErr)*

superclass           <-  'extends' classType^ClassTypeErr2

superinterfaces      <-  'implements' interfaceTypeList^InterfaceTypeListErr1

interfaceTypeList    <-  classType (',' classType^ClassTypeErr3)*

classBody            <-  '{' classBodyDeclaration* '}'^CurRBrackErr1

classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /
                         staticInitializer  /  constructorDeclaration

classMemberDeclaration  <-  fieldDeclaration  /  methodDeclaration  /
                            classDeclaration  /  interfaceDeclaration  /  ';'

fieldDeclaration     <-  fieldModifier* unannType variableDeclaratorList ';'

variableDeclaratorList  <-  variableDeclarator (',' variableDeclarator^VariableDeclaratorErr)*

variableDeclarator   <-  variableDeclaratorId ('='(!'=')^EqAvaliableErr1 variableInitializer^VariableInitializerErr1)?

variableDeclaratorId <-  Identifier dim*

variableInitializer  <-  expression  /  arrayInitializer

unannClassType       <-  Identifier typeArguments?
                           ('.' annotation* Identifier typeArguments?)*

unannType            <-  basicType dim*  /  unannClassType dim*

fieldModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'static'  /  'final'  /  'transient'  /  'volatile'

methodDeclaration    <-  methodModifier* methodHeader methodBody^MethodBodyErr1

methodHeader         <-  result methodDeclarator throws?  /
                         typeParameters annotation* result^ResultErr methodDeclarator^MethodDeclaratorErr throws?

methodDeclarator     <-  Identifier '('^LParErr1 formalParameterList? ')'^RParErr1 dim*

formalParameterList  <-  (receiverParameter  /  formalParameter) (',' formalParameter^FormalParameterErr)*

formalParameter      <-  variableModifier* unannType variableDeclaratorId  /
                         variableModifier* unannType annotation* '...' variableDeclaratorId^VariableDeclaratorIdErr1 (!',')^CommaAvaliableErr

variableModifier     <-  annotation  /  'final'

receiverParameter    <-  variableModifier* unannType (Identifier '.')? 'this'

result               <-  unannType  /  'void'

methodModifier       <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'abstract'  /  'static'  /  'final'  /  'synchronized'  /
                         'native'  /  'stictfp'

throws               <-  'throws' exceptionTypeList^ExceptionTypeListErr

exceptionTypeList    <-  exceptionType (',' exceptionType^ExceptionTypeErr)*

exceptionType        <-  classType  /  typeVariable

methodBody           <-  block  /  ';'

instanceInitializer  <-  block

staticInitializer    <-  'static' block^BlockErr1

constructorDeclaration  <-  constructorModifier* constructorDeclarator throws? constructorBody^ConstructorBodyErr

constructorDeclarator  <-  typeParameters? Identifier '('^LParErr2 formalParameterList? ')'^RParErr2

constructorModifier  <-  annotation  /  'public'  /  'protected'  /  'private'

constructorBody      <-  '{' explicitConstructorInvocation? blockStatements? '}'^CurRBrackErr2

explicitConstructorInvocation  <-  typeArguments? 'this'  arguments ';'^SemiErr3  /
                                   typeArguments? 'super' arguments ';'^SemiErr4  /
                                   primary '.' typeArguments? 'super'^SUPERErr1 arguments^ArgumentsErr1 ';'^SemiErr5  /
                                   qualIdent '.' typeArguments? 'super'^SUPERErr2 arguments^ArgumentsErr2 ';'^SemiErr6

enumDeclaration       <-  classModifier* 'enum' Identifier^IdErr4 superinterfaces? enumBody^EnumBodyErr

enumBody              <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^CurRBrackErr3

enumConstantList      <-  enumConstant (',' enumConstant)*

enumConstant          <-  enumConstantModifier* Identifier arguments? classBody?

enumConstantModifier  <-  annotation

enumBodyDeclarations  <-  ';' classBodyDeclaration*


-- JLS 9 Interfaces
interfaceDeclaration  <-  normalInterfaceDeclaration  /  annotationTypeDeclaration

normalInterfaceDeclaration  <-  interfaceModifier* 'interface' Identifier^IdErr5 typeParameters?
                                  extendsInterfaces? interfaceBody^InterfaceBodyErr

interfaceModifier     <-  annotation  /  'public'  /  'protected'  /  'private'  /
                          'abstract'  /  'static'  /  'strictfp'

extendsInterfaces     <-  'extends' interfaceTypeList^InterfaceTypeListErr2

interfaceBody         <-  '{' interfaceMemberDeclaration* '}'^CurRBrackErr4

interfaceMemberDeclaration  <-  constantDeclaration  /  interfaceMethodDeclaration  /
                                classDeclaration  /  interfaceDeclaration  /  ';'

constantDeclaration   <-  constantModifier* unannType variableDeclaratorList^VariableDeclaratorListErr ';'

constantModifier      <-  annotation  /  'public'  /  'static'  /  'final'

interfaceMethodDeclaration  <-  interfaceMethodModifier* methodHeader methodBody^MethodBodyErr2

interfaceMethodModifier  <-  annotation  /  'public'  /  'abstract'  /
                             'default'  /  'static'  /  'strictfp'

annotationTypeDeclaration  <-  interfaceModifier* '@' 'interface'^InterfaceWordErr Identifier^IdErr6 annotationTypeBody^AnnotationTypeBodyErr

annotationTypeBody    <-  '{' annotationTypeMemberDeclaration* '}'^CurRBrackErr5

annotationTypeMemberDeclaration  <-  annotationTypeElementDeclaration  /
                                     constantDeclaration               /
                                     classDeclaration                  /
                                     interfaceDeclaration              /
                                     ';'

annotationTypeElementDeclaration  <-  annotationTypeElementModifier* unannType
                                      Identifier^IdErr7 '('^LParErr3 ')'^RParErr3 dim* defaultValue? ';'^SemiErr7

annotationTypeElementModifier  <-  annotation  /  'public'  /  'abstract'

defaultValue          <-  'default' elementValue^ElementValueErr1

annotation            <-  '@' (normalAnnotation         /
                               singleElementAnnotation  /
                               markerAnnotation)

normalAnnotation      <-  qualIdent '(' elementValuePairList* ')'

elementValuePairList  <-  elementValuePair (',' elementValuePair^ElementValuePairErr)*

elementValuePair      <-  Identifier '=' (!'=')^EqAvaliableErr2 elementValue^ElementValueErr2

elementValue          <-  conditionalExpression         /
                          elementValueArrayInitializer  /
                          annotation

elementValueArrayInitializer  <-  '{' elementValueList? ','? '}'^CurRBrackErr6

elementValueList      <-  elementValue (',' elementValue^ElementValueErr3)*

markerAnnotation      <-  qualIdent

singleElementAnnotation  <-  qualIdent '(' elementValue^ElementValueErr4 ')'^RParErr4
   

-- JLS 10 Arrays
arrayInitializer     <-  '{' variableInitializerList? ','? '}'^CurRBrackErr7

variableInitializerList  <- variableInitializer (',' variableInitializer)*


-- JLS 14 Blocks and Statements
block                 <-  '{' blockStatements? '}'^CurRBrackErr8

blockStatements       <-  blockStatement blockStatement*

blockStatement        <-  localVariableDeclarationStatement  /
                          classDeclaration                    /
                          statement

localVariableDeclarationStatement  <-  localVariableDeclaration ';'^SemiErr8

localVariableDeclaration  <-  variableModifier* unannType variableDeclaratorList

statement            <-  block                                             /
                         'if' parExpression^ParExpressionErr1 statement^StatementErr1 ('else' statement^StatementErr2)? /
                         basicForStatement                                 /
                         enhancedForStatement                              /
                         'while' parExpression^ParExpressionErr2 statement^StatementErr3 /
                         'do' statement^StatementErr4 'while'^WHILEErr parExpression^ParExpressionErr3 ';'^SemiErr9 /
                         tryStatement                                      /
                         'switch' parExpression^ParExpressionErr4 switchBlock^SwitchBlockErr /
                         'synchronized' parExpression^ParExpressionErr5 block^BlockErr2 /
                         'return' expression? ';'^SemiErr10                  /
                         'throw' expression^ExpressionErr1 ';'^SemiErr11      /
                         'break' Identifier? ';'^SemiErr12                   /
                         'continue' Identifier? ';'^SemiErr13                /
                         'assert' expression^ExpressionErr2 (':' expression^ExpressionErr3)? ';'^SemiErr14 /
                         ';'                                                 /
                         statementExpression ';'^SemiErr15                   /
                         Identifier ':'^ColonErr1 statement^StatementErr5

statementExpression   <-  assignment                           /
                          ('++' / '--') (primary / qualIdent)^AfterIteratorSymbolErr  /
                          (primary / qualIdent) ('++' / '--')  /
                          primary

switchBlock           <-  '{' switchBlockStatementGroup* switchLabel* '}'^CurRBrackErr9

switchBlockStatementGroup  <-  switchLabels blockStatements^BlockStatementsErr

switchLabels          <-  switchLabel switchLabel*

switchLabel           <-  'case' (constantExpression / enumConstantName)^CaseExpressionErr ':'^ColonErr2  /
                          'default' ':'^ColonErr3

enumConstantName      <-  Identifier

basicForStatement     <-  'for' '('^LParErr4 forInit? ';' expression? ';'^SemiErr16 forUpdate? ')'^RParErr5 statement^StatementErr6

forInit               <-  localVariableDeclaration  /  statementExpressionList

forUpdate             <-  statementExpressionList

statementExpressionList  <-  statementExpression (',' statementExpression^StatementExpressionErr)*

enhancedForStatement  <-  'for' '('^Err_120 variableModifier* unannType^Err_121 variableDeclaratorId^Err_122 ':'^ColonErr4
                            expression^ExpressionErr4 ')'^RParErr6 statement^StatementErr7

tryStatement          <-  'try' ( block (catchClause* finally  /  catchClause+)^AfterBlockErr
                                / resourceSpecification block^BlockErr3 catchClause* finally? )^AfterTryErr

catchClause           <-  'catch' '('^LParErr5 catchFormalParameter^CatchFormalParameterErr ')'^RParErr7 block^BlockErr4

catchFormalParameter  <-  variableModifier* catchType variableDeclaratorId^VariableDeclaratorIdErr2

catchType             <-  unannClassType ('|' (![=|])^EqVerticalBarAvaliableErr classType^ClassTypeErr4)*

finally               <-  'finally' block^BlockErr5

resourceSpecification <-  '(' resourceList^ResourceListErr ';'? ')'^RParErr8

resourceList          <-  resource (',' resource^ResourceErr)*

resource              <-  variableModifier* unannType variableDeclaratorId^VariableDeclaratorIdErr3 '='^Err_141 (!'=')^EqAvaliableErr3 expression^ExpressionErr5


-- JLS 15 Expressions
expression            <-  lambdaExpression  /  assignmentExpression

primary               <-  primaryBase primaryRest*

primaryBase           <-  'this'
                       /  Literal
                       /  parExpression
                       /  'super' ( '.' typeArguments? Identifier arguments
                                  / '.' Identifier^IdErr8
                                  / '::' typeArguments? Identifier^IdErr9 )^AfterSuperErr
                       /  'new' (classCreator / arrayCreator)^AfterNewErr
                       /  qualIdent ( '[' expression ']'^RBrackErr1
                                    / arguments
                                    / '.' ( 'this'
                                          / 'new' classCreator^ClassCreatorErr1
                                          / typeArguments Identifier^IdErr10 arguments^ArgumentsErr3
                                          / 'super' '.' typeArguments? Identifier^IdErr11 arguments^ArgumentsErr4
                                          / 'super' '.' Identifier
                                          / 'super' '::' typeArguments? Identifier^IdErr12 arguments^ArgumentsErr5
                                          )
                                    / ('[' ']'^RBrackErr2)* '.' 'class'
                                    /  '::' typeArguments? Identifier^IdErr13 )
                       /  'void' '.'^DotErr1 'class'^CLASSErr1
                       /  basicType ('[' ']'^RBrackErr3)* '.' 'class'^CLASSErr2
                       /  referenceType '::' typeArguments? 'new'^NEWErr1
                       /  arrayType '::'^Err_149 'new'^Err_150

primaryRest           <-  '.' ( typeArguments? Identifier arguments
                              / Identifier
                              / 'new' classCreator^ClassCreatorErr2 )
                       /  '[' expression^ExpressionErr6 ']'^RBrackErr4
                       /  '::' typeArguments? Identifier^IdErr14

parExpression         <-  '(' expression ')'^RParErr9

-- Commented out: ClassInstanceCreationExpression

classCreator          <-  typeArguments? annotation* classTypeWithDiamond
                            arguments^Err_158 classBody?

classTypeWithDiamond  <-  annotation* Identifier typeArgumentsOrDiamond?
                            ('.' annotation* Identifier^IdErr15 typeArgumentsOrDiamond?)*

typeArgumentsOrDiamond  <-  typeArguments  /  '<' '>'^GreaterErr1 (!'.')^DotAvaliableErr

arrayCreator          <-  type dimExpr+ dim*  /  type (dim+)^Err_161 arrayInitializer^ArrayInitializerErr

dimExpr               <-  annotation* '[' expression ']'^RBrackErr5

--Commented out: ArrayAcess, FieldAcess, MethodInvocation

arguments             <-  '(' argumentList? ')'^RParErr10

argumentList          <-  expression (',' expression^ExpressionErr7)*

unaryExpression       <-  ('++' / '--') (primary / qualIdent)^PrimaryQualIdentErr /
                          '+' (![=+])^EqualPlusErr unaryExpression^UnaryExpressionErr1 /
                          '-' (![-=>])^MinusEqualGreaterErr unaryExpression^UnaryExpressionErr2 /
                          unaryExpressionNotPlusMinus

unaryExpressionNotPlusMinus  <-  '~' unaryExpression^UnaryExpressionErr3        /
                                 '!' (![=&])^EqualAmpersandErr unaryExpression^UnaryExpressionErr4  /
                                 castExpression                                /
                                 (primary / qualIdent) ('++' / '--')?

castExpression        <-  '(' primitiveType ')'^RParErr11 unaryExpression^UnaryExpressionErr5 /
                          '(' referenceType additionalBound* ')' lambdaExpression /
                          '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus^UnaryExpressionNotPlusMinusErr

infixExpression       <-  unaryExpression ((InfixOperator unaryExpression^UnaryExpressionErr6) /
                                           ('instanceof' referenceType^ReferenceTypeErr3))*

InfixOperator         <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]          /
                          '=='  /  '!='  /  '<' ![=<]  /  '>'![=>]  /  '<='               /
                          '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /
                          '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]

conditionalExpression <-  infixExpression ('query' expression^ExpressionErr8 ':'^ColonErr5 expression^ExpressionErr9)*

assignmentExpression  <-  assignment  /  conditionalExpression

assignment            <-  leftHandSide AssignmentOperator expression^ExpressionErr10

leftHandSide          <-  primary  /  qualIdent

AssignmentOperator    <-  '='![=]  /  '*='  /  '/='  /  '%='  /
                          '+='  /  '-='  /  '<<='  / '>>='    /
                          '>>>='  /  '&='  /  '^='  /  '|='

lambdaExpression      <-  lambdaParameters '->' lambdaBody^LambdaBodyErr

lambdaParameters      <-  Identifier                          /
                          '(' formalParameterList? ')'       /
                          '(' inferredFormalParameterList^Err_179 ')'

inferredFormalParameterList  <-  Identifier (',' Identifier^IdErr16)*

lambdaBody            <-  expression  /  block

constantExpression    <-  expression


-- JLS 3.8 Identifiers
Identifier            <-  !keywords [a-zA-Z_] [a-zA-Z_$0-9]*

-- JLS 3.9 Keywords
keywords              <- 'abstract'  /  'assert'  /  'boolean'  /  'break'  /
                         'byte'  /  'case'  /  'catch'  /  'char'  /
                         'class'  /  'const'  /  'continue'  /  'default'  /
                         'double'  /  'do'  /  'else'  /  'enum'  /
                         'extends'  /  'false'  /  'finally'  /  'final'  /
                         'float'  /  'for'  /  'goto'  /  'if'  /
                         'implements'  /  'import'  /  'interface'  /  'int'  /
                         'instanceof'  /  'long'  /  'native'  /  'new'  /
                         'null'  /  'package'  /  'private'  /  'protected' /
                         'public'  /  'return'  /  'short'  /  'static'  /
                         'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /
                         'this'  /  'throws'  /  'throw'  /  'transient'  /
                         'true'  /  'try'  /  'void'  /  'volatile'  /  'while'
   
 
-- JLS 3.10 Literals
Literal               <-  FloatLiteral  /  IntegerLiteral  /  BooleanLiteral  /
                          CharLiteral  /  StringLiteral  /  NullLiteral

-- JLS 3.10.1 Integer Literals
IntegerLiteral        <-  (HexNumeral  /  BinaryNumeral  /  OctalNumeral  /  DecimalNumeral) [lL]?

DecimalNumeral        <-  '0'  /  [1-9] ([_]*[0-9])*

HexNumeral            <-  ('0x' / '0X') HexDigits

OctalNumeral          <-  '0' ([_]*[0-7])+

BinaryNumeral         <-  ('0b' / '0B') [01]([_]*[01])* 

-- JLS 3.10.2 Floating-point Literals
FloatLiteral          <-  HexaDecimalFloatingPointLiteral  /  DecimalFloatingPointLiteral

DecimalFloatingPointLiteral  <- Digits '.' Digits? Exponent? [fFdD]?  /
                                '.' Digits Exponent? [fFdD]?          /
                                Digits Exponent [fFdD]?               /
                                Digits Exponent? [fFdD]

Exponent             <-  [eE] [-+]? Digits

HexaDecimalFloatingPointLiteral  <-  HexSignificand BinaryExponent [fFdD]?

HexSignificand       <-  ('0x' / '0X') HexDigits? '.' HexDigits  /
                         HexNumeral '.'?

HexDigits            <-  HexDigit ([_]* HexDigit)*

HexDigit             <-  [a-f]  /  [A-F]  /  [0-9]

BinaryExponent       <-  [pP] [-+]? Digits

Digits               <-  [0-9]([_]*[0-9])*


-- JLS 3.10.3 Boolean Literals
BooleanLiteral       <-  'true'  /  'false'  


-- JLS 3.10.4 Character Literals
-- JLS 3.10.5 String Literals
-- JLS 3.10.6 Null Literal

CharLiteral          <-  "'" (%nl  /  !"'" .)  "'"

StringLiteral        <-  '"' (%nl  /  !'"' .)* '"'

NullLiteral          <-  'null'

Token                <-  keywords  /  Identifier  /  Literal  /  .

COMMENT              <- '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
]]

local p = coder.makeg(tree, rules)

print ">>> Testing correct programs..."
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

print ">>> Testing labels with incorrect programs..."
dir = lfs.currentdir() .. '/test/java18/test/no/'
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
    assert(r == nil and tostring(lab) .. '.java' == file, file .. ': Label: ' .. tostring(lab or 'The program is correct!') .. '  Line: ' .. line .. ' Col: ' .. col)
  end
end
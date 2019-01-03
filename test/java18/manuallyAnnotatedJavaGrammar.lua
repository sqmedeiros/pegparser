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
basicType            <-  'byte'  /  'short'  /  'int'  /  'long'
                         'char'  /  'float'  /  'double'  /  'boolean'

primitiveType        <-  annotation* basicType

referenceType        <-  primitiveType dim+  /  classType dim*

classType            <-  annotation* Identifier typeArguments?
                           ('.' annotation* Identifier^IdErr typeArguments?)*

type                 <-  primitiveType  /  classType

arrayType            <-  primitiveType dim+  /  classType dim+

typeVariable         <-  annotation* Identifier

dim                  <-  annotation* '[' ']'

typeParameter        <-  typeParameterModifier* Identifier typeBound?

typeParameterModifier  <-  annotation

typeBound            <-  'extends' (classType additionalBound*  /  typeVariable)

additionalBound      <-  'and' classType^ClassTypeErr

typeArguments        <-  '<' typeArgumentList '>'

typeArgumentList     <-  typeArgument (',' typeArgument^TypeArgumentErr)*

typeArgument         <-  referenceType  /  wildcard

wildcard             <-  annotation* '?' wildcardBounds?

wildcardBounds       <-  'extends' referenceType^ReferenceTypeErr  / 'super' referenceType^ReferenceTypeErr


-- JLS 6 Names
qualIdent            <-  Identifier ('.' Identifier)*


-- JLS 7 Packages
compilationUnit      <-  packageDeclaration? importDeclaration* typeDeclaration*

packageDeclaration   <-  packageModifier* 'package' Identifier^IdErr4 ('.' Identifier^IdErr5)* ';'^SemiErr

packageModifier      <-  annotation

importDeclaration    <-  'import' 'static'? qualIdent^QualIdentErr ('.' '*'^AsteriskErr)? ';'^SemiErr  /  ';'

typeDeclaration      <-  classDeclaration  /  interfaceDeclaration  /  ';'


-- JLS 8 Classes
classDeclaration     <-  normalClassDeclaration  /  enumDeclaration

normalClassDeclaration  <-  classModifier* 'class' Identifier^IdErr6 typeParameters?
                              superclass? superinterfaces? classBody^ClassBodyErr

classModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'abstract'  /  'static'  /  'final'  /  'strictfp'

typeParameters       <-  '<' typeParameterList^TypeParameterListErr '>'^GeqErr

typeParameterList    <-  typeParameter (',' typeParameter^TypeParameterErr)*

superclass           <-  'extends' classType^ClassTypeErr

superinterfaces      <-  'implements' interfaceTypeList^InterfaceTypeListErr

interfaceTypeList    <-  classType (',' classType^ClassTypeErr)*

classBody            <-  '{' classBodyDeclaration* '}'

classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /
                         staticInitializer  /  constructorDeclaration

classMemberDeclaration  <-  fieldDeclaration  /  methodDeclaration  /
                            classDeclaration  /  interfaceDeclaration  /  ';'

fieldDeclaration     <-  fieldModifier* unannType variableDeclaratorList ';'

variableDeclaratorList  <-  variableDeclarator (',' variableDeclarator^VariableDeclaratorErr)*

variableDeclarator   <-  variableDeclaratorId ('='(!'=')^EqErr variableInitializer^VariableInitializerErr)?

variableDeclaratorId <-  Identifier dim*

variableInitializer  <-  expression  /  arrayInitializer

unannClassType       <-  Identifier typeArguments?
                           ('.' annotation* Identifier^IdErr7 typeArguments?)*

unannType            <-  basicType dim*  /  unannClassType dim*

fieldModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'static'  /  'final'  /  'transient'  /  'volatile'

methodDeclaration    <-  methodModifier* methodHeader methodBody^MethodBodyErr

methodHeader         <-  result methodDeclarator throws?  /
                         typeParameters annotation* result^ResultErr methodDeclarator^MethodDeclaratorErr throws?

methodDeclarator     <-  Identifier '('^LParErr formalParameterList? ')'^RParErr dim*

formalParameterList  <-  (receiverParameter  /  formalParameter) (',' formalParameter^FormalParameterErr)*

formalParameter      <-  variableModifier* unannType variableDeclaratorId  /
                         variableModifier* unannType annotation* '...' variableDeclaratorId^VariableDeclaratorIdErr (!',')^CommaAvaliableErr

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

staticInitializer    <-  'static' block^BlockErr

constructorDeclaration  <-  constructorModifier* constructorDeclarator throws? constructorBody^ConstructorBodyErr

constructorDeclarator  <-  typeParameters? Identifier '('^LParErr formalParameterList? ')'^RParErr

constructorModifier  <-  annotation  /  'public'  /  'protected'  /  'private'

constructorBody      <-  '{' explicitConstructorInvocation? blockStatements? '}'^CurRBrackErr

explicitConstructorInvocation  <-  typeArguments? 'this'  arguments ';'^SemiErr  /
                                   typeArguments? 'super' arguments ';'^SemiErr  /
                                   primary '.' typeArguments? 'super'^SUPERErr arguments^ArgumentsErr ';'^SemiErr  /
                                   qualIdent '.' typeArguments? 'super'^SUPERErr arguments^ArgumentsErr ';'^SemiErr

enumDeclaration       <-  classModifier* 'enum' Identifier^IdErr8 superinterfaces? enumBody^EnumBodyErr

enumBody              <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^CurRBrackErr

enumConstantList      <-  enumConstant (',' enumConstant^EnumConstantErr)*

enumConstant          <-  enumConstantModifier* Identifier arguments? classBody?

enumConstantModifier  <-  annotation

enumBodyDeclarations  <-  ';' classBodyDeclaration*


-- JLS 9 Interfaces
interfaceDeclaration  <-  normalInterfaceDeclaration  /  annotationTypeDeclaration

normalInterfaceDeclaration  <-  interfaceModifier* 'interface' Identifier^IdErr9 typeParameters?
                                  extendsInterfaces? interfaceBody^InterfaceBodyErr

interfaceModifier     <-  annotation  /  'public'  /  'protected'  /  'private'  /
                          'abstract'  /  'static'  /  'strictfp'

extendsInterfaces     <-  'extends' interfaceTypeList^InterfaceTypeListErr

interfaceBody         <-  '{' interfaceMemberDeclaration* '}'^CurRBrackErr

interfaceMemberDeclaration  <-  constantDeclaration  /  interfaceMethodDeclaration  /
                                classDeclaration  /  interfaceDeclaration  /  ';'

constantDeclaration   <-  constantModifier* unannType variableDeclaratorList^VariableDeclaratorListErr ';'

constantModifier      <-  annotation  /  'public'  /  'static'  /  'final'

interfaceMethodDeclaration  <-  interfaceMethodModifier* methodHeader methodBody^MethodBodyErr

interfaceMethodModifier  <-  annotation  /  'public'  /  'abstract'  /
                             'default'  /  'static'  /  'strictfp'

annotationTypeDeclaration  <-  interfaceModifier* '@' 'interface'^InterfaceWordErr Identifier^IdErr10 annotationTypeBody^AnnotationTypeBodyErr

annotationTypeBody    <-  '{' annotationTypeMemberDeclaration* '}'^CurRBrackErr

annotationTypeMemberDeclaration  <-  annotationTypeElementDeclaration  /
                                     constantDeclaration               /
                                     classDeclaration                  /
                                     interfaceDeclaration              /
                                     ';'

annotationTypeElementDeclaration  <-  annotationTypeElementModifier* unannType
                                      Identifier^IdErr11 '('^LParErr ')'^RParErr dim* defaultValue? ';'^SemiErr

annotationTypeElementModifier  <-  annotation  /  'public'  /  'abstract'

defaultValue          <-  'default' elementValue^ElementValueErr

annotation            <-  '@' (normalAnnotation         /
                               singleElementAnnotation  /
                               markerAnnotation)

normalAnnotation      <-  qualIdent '(' elementValuePairList* ')'

elementValuePairList  <-  elementValuePair (',' elementValuePair^ElementValuePairErr)*

elementValuePair      <-  Identifier '=' (!'=')^EqAvaliableErr elementValue^ElementValueErr

elementValue          <-  conditionalExpression         /
                          elementValueArrayInitializer  /
                          annotation

elementValueArrayInitializer  <-  '{' elementValueList? ','? '}'^CurRBrackErr

elementValueList      <-  elementValue (',' elementValue^ElementValueErr)*

markerAnnotation      <-  qualIdent

singleElementAnnotation  <-  qualIdent '(' elementValue^ElementValueErr ')'^RParErr
   

-- JLS 10 Arrays
arrayInitializer     <-  '{' variableInitializerList? ','? '}'^CurRBrackErr

variableInitializerList  <- variableInitializer (',' variableInitializer^VariableInitializerErr)*


-- JLS 14 Blocks and Statements
block                 <-  '{' blockStatements? '}'^CurRBrackErr

blockStatements       <-  blockStatement blockStatement*

blockStatement        <-  localVariableDeclarationStatement  /
                          classDeclaration                    /
                          statement

localVariableDeclarationStatement  <-  localVariableDeclaration ';'^SemiErr

localVariableDeclaration  <-  variableModifier* unannType variableDeclaratorList

statement            <-  block                                             /
                         'if' parExpression^ParExpressionErr statement^StatementErr ('else' statement^StatementErr)? /
                         basicForStatement                                 /
                         enhancedForStatement                              /
                         'while' parExpression^ParExpressionErr statement^StatementErr /
                         'do' statement^StatementErr 'while'^WHILEErr parExpression^ParExpressionErr ';'^SemiErr /
                         tryStatement                                      /
                         'switch' parExpression^ParExpressionErr switchBlock^SwitchBlockErr /
                         'synchronized' parExpression^ParExpressionErr block^BlockErr /
                         'return' expression? ';'^SemiErr                  /
                         'throw' expression^ExpressionErr ';'^SemiErr      /
                         'break' Identifier? ';'^SemiErr                   /
                         'continue' Identifier? ';'^SemiErr                /
                         'assert' expression^ExpressionErr (':' expression^ExpressionErr)? ';'^SemiErr /
                         ';'                                               /
                         statementExpression ';'^SemiErr                   /
                         Identifier ':'^ColonErr statement^StatementErr

statementExpression   <-  assignment                           /
                          ('++' / '--') (primary / qualIdent)^AfterIteratorSymbolErr  /
                          (primary / qualIdent) ('++' / '--')  /
                          primary

switchBlock           <-  '{' switchBlockStatementGroup* switchLabel* '}'^CurRBrackErr

switchBlockStatementGroup  <-  switchLabels blockStatements^BlockStatementsErr

switchLabels          <-  switchLabel switchLabel*

switchLabel           <-  'case' (constantExpression / enumConstantName)^CaseExpressionErr ':'^ColonErr  /
                          'default' ':'^ColonErr

enumConstantName      <-  Identifier

basicForStatement     <-  'for' '('^LParErr forInit? ';' expression? ';'^SemiErr forUpdate? ')'^RParErr statement^StatementErr

forInit               <-  localVariableDeclaration  /  statementExpressionList

forUpdate             <-  statementExpressionList

statementExpressionList  <-  statementExpression (',' statementExpression^StatementExpressionErr)*

enhancedForStatement  <-  'for' '('^LParErr variableModifier* unannType variableDeclaratorId ':'^ColonErr
                            expression^ExpressionErr ')'^RParErr statement^StatementErr

tryStatement          <-  'try' ( block (catchClause* finally  /  catchClause+)^AfterBlockErr
                                / resourceSpecification block^BlockErr catchClause* finally? )^AfterTryErr

catchClause           <-  'catch' '('^LParErr catchFormalParameter^CatchFormalParameterErr ')'^RParErr block^BlockErr

catchFormalParameter  <-  variableModifier* catchType variableDeclaratorId^VariableDeclaratorIdErr

catchType             <-  unannClassType ('|' (![=|])^VerticalBarAvaliableErr classType^ClassTypeErr)*

finally               <-  'finally' block^BlockErr

resourceSpecification <-  '(' resourceList^ResourceListErr ';'? ')'^RParErr

resourceList          <-  resource (',' resource^ResourceErr)*

resource              <-  variableModifier* unannType variableDeclaratorId^VariableDeclaratorIdErr '=' (!'=')^EqAvaliableErr expression^ExpressionErr


-- JLS 15 Expressions
expression            <-  lambdaExpression  /  assignmentExpression

primary               <-  primaryBase primaryRest*

primaryBase           <-  'this'
                       /  Literal
                       /  parExpression
                       /  'super' ( '.' typeArguments? Identifier^IdErr12 arguments^ArgumentsErr
                                  / '.' Identifier^IdErr13
                                  / '::' typeArguments? Identifier^IdErr14 )^AfterSuperErr
                       /  'new' (classCreator  /  arrayCreator)^AfterNewErr
                       /  qualIdent ( '[' expression^ExpressionErr1 ']'^LBrackErr
                                    / arguments
                                    / '.' ( 'this'
                                          / 'new' classCreator^ClassCreatorErr
                                          / typeArguments Identifier^IdErr15 arguments^ArgumentsErr
                                          / 'super' '.'^DotErr typeArguments? Identifier^IdErr16 arguments^ArgumentsErr
                                          / 'super' '.'^DotErr Identifier^IdErr17
                                          / 'super' '::'^DoubleColonErr typeArguments? Identifier^IdErr18 arguments
                                          )
                                    / ('[' ']'^LBrackErr)* '.' 'class'^f
                                    /  '::' typeArguments? Identifier^IdErr19 )
                       /  'void' '.'^DotErr 'class'^CLASSErr
                       /  basicType ('[' ']'^LBrackErr)* '.'^DotErr 'class'^CLASSErr
                       /  referenceType '::' typeArguments? 'new'^NEWErr
                       /  arrayType '::' 'new'^NEWErr

primaryRest           <-  '.' ( typeArguments? Identifier arguments
                              / Identifier
                              / 'new' classCreator^ClassCreatorErr )^AfterDotErr
                       /  '[' expression^ExpressionErr ']'^LBrackErr
                       /  '::' typeArguments? Identifier^IdErr20

parExpression         <-  '(' expression^ExpressionErr ')'^RParErr

-- Commented out: ClassInstanceCreationExpression

classCreator          <-  typeArguments? annotation* classTypeWithDiamond
                            arguments^ArgumentsErr classBody?

classTypeWithDiamond  <-  annotation* Identifier typeArgumentsOrDiamond?
                            ('.' annotation* Identifier^IdErr21 typeArgumentsOrDiamond?)*

typeArgumentsOrDiamond  <-  typeArguments  /  '<' '>'^GreaterErr (!'.')^DotAvaliableErr

arrayCreator          <-  type dimExpr+ dim*  /  type dim+ arrayInitializer^ArrayInitializerErr

dimExpr               <-  annotation* '[' expression ']'^CurRBrackErr

--Commented out: ArrayAcess, FieldAcess, MethodInvocation

arguments             <-  '(' argumentList? ')'^RParErr

argumentList          <-  expression (',' expression^ExpressionErr)*

unaryExpression       <-  ('++' / '--') (primary / qualIdent)^PrimaryQualIdentErr /
                          '+' (![=+])^EqualPlusErr unaryExpression^UnaryExpressionErr /
                          '-' (![-=>])^MinusEqualGreaterErr unaryExpression^UnaryExpressionErr /
                          unaryExpressionNotPlusMinus

unaryExpressionNotPlusMinus  <-  '~' unaryExpression^UnaryExpressionErr        /
                                 '!' ![=&] unaryExpression^UnaryExpressionErr  /
                                 castExpression                                /
                                 (primary / qualIdent) ('++' / '--')?

castExpression        <-  '(' primitiveType ')'^RParErr unaryExpression^UnaryExpressionErr /
                          '(' referenceType additionalBound* ')' lambdaExpression /
                          '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus^UnaryExpressionNotPlusMinusErr

infixExpression       <-  unaryExpression ((InfixOperator unaryExpression^UnaryExpressionErr) /
                                           ('instanceof' referenceType^ReferenceTypeErr))*

InfixOperator         <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]          /
                          '=='  /  '!='  /  '<' ![=<]  /  '>'![=>]  /  '<='               /
                          '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /
                          '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]

conditionalExpression <-  infixExpression ('query' expression^ExpressionErr ':'^ColonErr expression^ExpressionErr)*

assignmentExpression  <-  assignment  /  conditionalExpression

assignment            <-  leftHandSide AssignmentOperator expression^ExpressionErr

leftHandSide          <-  primary  /  qualIdent

AssignmentOperator    <-  '='![=]  /  '*='  /  '/='  /  '%='  /
                          '+='  /  '-='  /  '<<='  / '>>='    /
                          '>>>='  /  '&='  /  '^='  /  '|='

lambdaExpression      <-  lambdaParameters '->' lambdaBody^LambdaBodyErr

lambdaParameters      <-  Identifier                          /
                          '(' formalParameterList? ')'       /
                          '(' inferredFormalParameterList ')'

inferredFormalParameterList  <-  Identifier (',' Identifier^IdErr22)*

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
                         'null'  /  'package'  /  'private'  /  'protected'
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

local m = require 'init'
local recovery = require 'recovery'
local pretty = require 'pretty'
local coder = require 'coder'
local lfs = require 'lfs'
local re = require 'relabel'
local first = require'first'
local test = require 'eita'

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

EatToken             <-  (Token  /  (!SKIP .)+) SKIP
Err_004              <-  (!('>'  /  ',') EatToken)*
ClassTypeErr1        <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
TypeArgumentErr      <-  (!'>' EatToken)*
ReferenceTypeErr1    <-  (!('>'  /  ',') EatToken)*
ReferenceTypeErr2    <-  (!('>'  /  ',') EatToken)*
IdErr1               <-  (!(';'  /  '.') EatToken)*
IdErr2               <-  (!';' EatToken)*
SemiErr1             <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
QualIdentErr1        <-  (!(';'  /  '.') EatToken)*
AsteriskErr          <-  (!';' EatToken)*
SemiErr2             <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
IdErr3               <-  (!('{'  /  'implements'  /  'extends'  /  '<') EatToken)*
ClassBodyErr         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
TypeParameterListErr <-  (!'>' EatToken)*
GeqErr               <-  (!('{'  /  'void'  /  'short'  /  'long'  /  'int'  /  'implements'  /  'float'  /  'extends'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Identifier'  /  '@') EatToken)*
TypeParameterErr     <-  (!'>' EatToken)*
ClassTypeErr2        <-  (!('{'  /  'implements') EatToken)*
InterfaceTypeListErr1 <-  (!'{' EatToken)*
ClassTypeErr3        <-  (!'{' EatToken)*
CurRBrackErr1        <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  ']'  /  '['  /  'Literal'  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  '@'  /  '<'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  !.) EatToken)*
VariableDeclaratorErr <-  (!';' EatToken)*
VariableInitializerErr1 <-  (!(';'  /  ',') EatToken)*
MethodBodyErr1       <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';') EatToken)*
ResultErr            <-  (!'Identifier' EatToken)*
MethodDeclaratorErr  <-  (!('{'  /  'throws'  /  ';') EatToken)*
LParErr1             <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Identifier'  /  '@'  /  ')') EatToken)*
RParErr1             <-  (!('{'  /  'throws'  /  '['  /  '@'  /  ';') EatToken)*
FormalParameterErr   <-  (!')' EatToken)*
VariableDeclaratorIdErr1 <-  (!(','  /  ')') EatToken)*
ExceptionTypeListErr <-  (!('{'  /  ';') EatToken)*
ExceptionTypeErr     <-  (!('{'  /  ';') EatToken)*
BlockErr1            <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';') EatToken)*
ConstructorBodyErr   <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';') EatToken)*
LParErr2             <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Identifier'  /  '@'  /  ')') EatToken)*
RParErr2             <-  (!('{'  /  'throws') EatToken)*
CurRBrackErr2        <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';') EatToken)*
SUPERErr2            <-  (!'(' EatToken)*
ArgumentsErr2        <-  (!';' EatToken)*
SemiErr6             <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'continue'  /  'class'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
IdErr4               <-  (!('{'  /  'implements') EatToken)*
EnumBodyErr          <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
CurRBrackErr3        <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
IdErr5               <-  (!('{'  /  'extends'  /  '<') EatToken)*
InterfaceBodyErr     <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
InterfaceTypeListErr2 <-  (!'{' EatToken)*
CurRBrackErr4        <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
VariableDeclaratorListErr <-  (!';' EatToken)*
MethodBodyErr2       <-  (!('}'  /  'void'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';') EatToken)*
InterfaceWordErr     <-  (!'Identifier' EatToken)*
IdErr6               <-  (!'{' EatToken)*
AnnotationTypeBodyErr <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
CurRBrackErr5        <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
IdErr7               <-  (!'(' EatToken)*
LParErr3             <-  (!')' EatToken)*
RParErr3             <-  (!('default'  /  '['  /  '@'  /  ';') EatToken)*
SemiErr7             <-  (!('}'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  'Identifier'  /  '@'  /  ';') EatToken)*
ElementValueErr1     <-  (!';' EatToken)*
ElementValuePairErr  <-  (!('Identifier'  /  ')') EatToken)*
ElementValueErr2     <-  (!('Identifier'  /  ','  /  ')') EatToken)*
CurRBrackErr         <-  (!('}'  /  'Identifier'  /  ';'  /  ','  /  ')') EatToken)*
ElementValueErr4     <-  (!')' EatToken)*
RParErr4             <-  (!('}'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'package'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  '['  /  'Identifier'  /  '@'  /  '?'  /  '<'  /  ';'  /  '...'  /  ','  /  ')') EatToken)*
CurRBrackErr7        <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
CurRBrackErr8        <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'query'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  ']'  /  'Literal'  /  'InfixOperator'  /  'Identifier'  /  '@'  /  '<'  /  ';'  /  ':'  /  '--'  /  ','  /  '++'  /  ')'  /  '(') EatToken)*
SemiErr8             <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ParExpressionErr1    <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr1        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ParExpressionErr2    <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr3        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr4        <-  (!'while' EatToken)*
WHILEErr             <-  (!'(' EatToken)*
ParExpressionErr3    <-  (!';' EatToken)*
SemiErr9             <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ParExpressionErr4    <-  (!'{' EatToken)*
SwitchBlockErr       <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ParExpressionErr5    <-  (!'{' EatToken)*
BlockErr2            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
SemiErr10            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ExpressionErr1       <-  (!';' EatToken)*
SemiErr11            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
SemiErr12            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
SemiErr13            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ExpressionErr2       <-  (!(';'  /  ':') EatToken)*
ExpressionErr3       <-  (!';' EatToken)*
SemiErr14            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ColonErr1            <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr5        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
AfterIteratorSymbolErr <-  (!(';'  /  ','  /  ')') EatToken)*
CurRBrackErr9        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
BlockStatementsErr   <-  (!('}'  /  'default'  /  'case') EatToken)*
CaseExpressionErr    <-  (!':' EatToken)*
ColonErr2            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ColonErr3            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
LParErr4             <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
SemiErr16            <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Literal'  /  'Identifier'  /  '@'  /  '--'  /  '++'  /  ')'  /  '(') EatToken)*
RParErr5             <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr6        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementExpressionErr <-  (!(';'  /  ')') EatToken)*
Err_120              <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Identifier'  /  '@') EatToken)*
Err_121              <-  (!'Identifier' EatToken)*
Err_122              <-  (!':' EatToken)*
ColonErr4            <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Literal'  /  'Identifier'  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
ExpressionErr4       <-  (!')' EatToken)*
RParErr6             <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
StatementErr7        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
AfterBlockErr        <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
BlockErr3            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
AfterTryErr          <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
LParErr5             <-  (!('final'  /  'Identifier'  /  '@') EatToken)*
CatchFormalParameterErr <-  (!')' EatToken)*
RParErr7             <-  (!'{' EatToken)*
BlockErr4            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
VariableDeclaratorIdErr2 <-  (!')' EatToken)*
ClassTypeErr4        <-  (!'Identifier' EatToken)*
BlockErr5            <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  'Literal'  /  'Identifier'  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
ResourceListErr      <-  (!(';'  /  ')') EatToken)*
RParErr8             <-  (!'{' EatToken)*
ResourceErr          <-  (!(';'  /  ')') EatToken)*
VariableDeclaratorIdErr3 <-  (!'=' EatToken)*
Err_141              <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  'Literal'  /  'Identifier'  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
ExpressionErr5       <-  (!(';'  /  ','  /  ')') EatToken)*
IdErr8               <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
IdErr9               <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
AfterSuperErr        <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
AfterNewErr          <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
DotErr1              <-  (!'class' EatToken)*
CLASSErr1            <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_149              <-  (!'new' EatToken)*
Err_150              <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
ClassCreatorErr2     <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
ExpressionErr6       <-  (!']' EatToken)*
RBrackErr4           <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
IdErr14              <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
RParErr9             <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'query'  /  'new'  /  'long'  /  'int'  /  'instanceof'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  ']'  /  '['  /  'Literal'  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  '@'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')'  /  '(') EatToken)*
Err_158              <-  (!('}'  /  '{'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
IdErr15              <-  (!('<'  /  '(') EatToken)*
GreaterErr1          <-  (!('.'  /  '(') EatToken)*
Err_161              <-  (!'{' EatToken)*
ArrayInitializerErr  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
RBrackErr5           <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  '@'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
RParErr10          <-  (!('}'  /  '{'  /  'query'  /  'instanceof'  /  ']'  /  '['  /  'InfixOperator'  /  'Identifier'  /  'AssignmentOperator'  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
ExpressionErr7       <-  (!')' EatToken)*
PrimaryQualIdentErr  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
UnaryExpressionErr1  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
UnaryExpressionErr2  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
UnaryExpressionErr3  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
UnaryExpressionErr4  <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
UnaryExpressionNotPlusMinusErr <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
ExpressionErr10      <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
LambdaBodyErr        <-  (!('}'  /  'query'  /  'instanceof'  /  ']'  /  'InfixOperator'  /  'Identifier'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_179            <-  (!')' EatToken)*
IdErr16              <-  (!')' EatToken)*
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
local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'

g = [[
compilation           <-  SKIP compilationUnit !.

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

typeBound            <-  'extends' (classType additionalBound*  /  typeVariable)

additionalBound      <-  'and' classType

typeArguments        <-  '<' typeArgumentList '>'

typeArgumentList     <-  typeArgument (',' typeArgument)*

typeArgument         <-  referenceType  /  wildcard

wildcard             <-  annotation* '?' wildcardBounds?

wildcardBounds       <-  'extends' referenceType  / 'super' referenceType


-- JLS 6 Names
qualIdent            <-  Identifier ('.' Identifier)*


-- JLS 7 Packages
compilationUnit      <-  packageDeclaration? importDeclaration* typeDeclaration*

packageDeclaration   <-  packageModifier* 'package' Identifier ('.' Identifier)* ';'

packageModifier      <-  annotation

importDeclaration    <-  'import' 'static'? qualIdent ('.' '*')? ';'  /  ';'

typeDeclaration      <-  classDeclaration  /  interfaceDeclaration  /  ';'


-- JLS 8 Classes
classDeclaration     <-  normalClassDeclaration  /  enumDeclaration

normalClassDeclaration  <-  classModifier* 'class' Identifier typeParameters?
                              superclass? superinterfaces? classBody

classModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'abstract'  /  'static'  /  'final'  /  'strictfp'

typeParameters       <-  '<' typeParameterList '>'

typeParameterList    <-  typeParameter (',' typeParameter)*

superclass           <-  'extends' classType

superinterfaces      <-  'implements' interfaceTypeList

interfaceTypeList    <-  classType (',' classType)*

classBody            <-  '{' classBodyDeclaration * '}'

classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /
                         staticInitializer  /  constructorDeclaration

classMemberDeclaration  <-  fieldDeclaration  /  methodDeclaration  /
                            classDeclaration  /  interfaceDeclaration  /  ';'

fieldDeclaration     <-  fieldModifier* unannType variableDeclaratorList ';'

variableDeclaratorList  <-  variableDeclarator (',' variableDeclarator)*

variableDeclarator   <-  variableDeclaratorId ('='!'=' variableInitializer)?

variableDeclaratorId <-  Identifier dim*

variableInitializer  <-  expression  /  arrayInitializer

unannClassType       <-  Identifier typeArguments?
                           ('.' annotation* Identifier typeArguments?)*

unannType            <-  basicType dim*  /  unannClassType dim*

fieldModifier        <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'static'  /  'final'  /  'transient'  /  'volatile'

methodDeclaration    <-  methodModifier* methodHeader methodBody

methodHeader         <-  result methodDeclarator throws?  /
                         typeParameters annotation* result methodDeclarator throws?

methodDeclarator     <-  Identifier '(' formalParameterList? ')' dim*

formalParameterList  <-  (receiverParameter  /  formalParameter) (',' formalParameter)*

formalParameter      <-  variableModifier* unannType variableDeclaratorId  /
                         variableModifier* unannType annotation* '...' variableDeclaratorId !','

variableModifier     <-  annotation  /  'final'

receiverParameter    <-  variableModifier* unannType (Identifier '.')? 'this'

result               <-  unannType  /  'void'

methodModifier       <-  annotation  /  'public'  /  'protected'  /  'private'  /
                         'abstract'  /  'static'  /  'final'  /  'synchronized'  /
                         'native'  /  'stictfp'

throws               <-  'throws' exceptionTypeList

exceptionTypeList    <-  exceptionType (',' exceptionType)*

exceptionType        <-  classType  /  typeVariable

methodBody           <-  block  /  ';'

instanceInitializer  <-  block

staticInitializer    <-  'static' block

constructorDeclaration  <-  constructorModifier* constructorDeclarator throws? constructorBody

constructorDeclarator  <-  typeParameters? Identifier '(' formalParameterList? ')'

constructorModifier  <-  annotation  /  'public'  /  'protected'  /  'private'

constructorBody      <-  '{' explicitConstructorInvocation? blockStatements? '}'

explicitConstructorInvocation  <-  typeArguments? 'this'  arguments ';'  /
                                   typeArguments? 'super' arguments ';'  /
                                   primary '.' typeArguments? 'super' arguments ';'  /
                                   qualIdent '.' typeArguments? 'super' arguments ';'

enumDeclaration       <-  classModifier* 'enum' Identifier superinterfaces? enumBody

enumBody              <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'

enumConstantList      <-  enumConstant (',' enumConstant)*

enumConstant          <-  enumConstantModifier* Identifier arguments? classBody?

enumConstantModifier  <-  annotation

enumBodyDeclarations  <-  ';' classBodyDeclaration*


-- JLS 9 Interfaces
interfaceDeclaration  <-  normalInterfaceDeclaration  /  annotationTypeDeclaration

normalInterfaceDeclaration  <-  interfaceModifier* 'interface' Identifier typeParameters?
                                  extendsInterfaces? interfaceBody

interfaceModifier     <-  annotation  /  'public'  /  'protected'  /  'private'  /
                          'abstract'  /  'static'  /  'strictfp'

extendsInterfaces     <-  'extends' interfaceTypeList

interfaceBody         <-  '{' interfaceMemberDeclaration* '}'

interfaceMemberDeclaration  <-  constantDeclaration  /  interfaceMethodDeclaration  /
                                classDeclaration  /  interfaceDeclaration  /  ';'

constantDeclaration   <-  constantModifier* unannType variableDeclaratorList ';'

constantModifier      <-  annotation  /  'public'  /  'static'  /  'final'

interfaceMethodDeclaration  <-  interfaceMethodModifier* methodHeader methodBody

interfaceMethodModifier  <-  annotation  /  'public'  /  'abstract'  /
                             'default'  /  'static'  /  'strictfp'

annotationTypeDeclaration  <-  interfaceModifier* '@' 'interface' Identifier annotationTypeBody

annotationTypeBody    <-  '{' annotationTypeMemberDeclaration* '}'

annotationTypeMemberDeclaration  <-  annotationTypeElementDeclaration  /
                                     constantDeclaration               /
                                     classDeclaration                  /
                                     interfaceDeclaration              /
                                     ';'

annotationTypeElementDeclaration  <-  annotationTypeElementModifier* unannType
                                        Identifier '(' ')' dim* defaultValue? ';'

annotationTypeElementModifier  <-  annotation  /  'public'  /  'abstract'

defaultValue          <-  'default' elementValue

annotation            <-  '@' (normalAnnotation         /
                               singleElementAnnotation  /
                               markerAnnotation)

normalAnnotation      <-  qualIdent '(' elementValuePairList* ')'

elementValuePairList  <-  elementValuePair (',' elementValuePair)*

elementValuePair      <-  Identifier '='!'=' elementValue

elementValue          <-  conditionalExpression         /
                          elementValueArrayInitializer  /
                          annotation

elementValueArrayInitializer  <-  '{' elementValueList? ','? '}'

elementValueList      <-  elementValue (',' elementValue)*

markerAnnotation      <-  qualIdent

singleElementAnnotation  <-  qualIdent '(' elementValue ')'
   

-- JLS 10 Arrays
arrayInitializer     <-  '{' variableInitializerList? ','? '}'

variableInitializerList  <- variableInitializer (',' variableInitializer)*


-- JLS 14 Blocks and Statements
block                 <-  '{' blockStatements? '}'

blockStatements       <-  blockStatement blockStatement*

blockStatement        <-  localVariableDeclarationStatement  /
                          classDeclaration                    /
                          statement

localVariableDeclarationStatement  <-  localVariableDeclaration ';'

localVariableDeclaration  <-  variableModifier* unannType variableDeclaratorList

statement            <-  block                                             /
                         'if' parExpression statement ('else' statement)?  /
                         basicForStatement                                 /
                         enhancedForStatement                              /
                         'while' parExpression statement                   /
                         'do' statement 'while' parExpression ';'          /
                         tryStatement                                      /
                         'switch' parExpression switchBlock                /
                         'synchronized' parExpression block                /
                         'return' expression? ';'                          /
                         'throw' expression ';'                            /
                         'break' Identifier? ';'                           /
                         'continue' Identifier? ';'                        /
                         'assert' expression (':' expression)? ';'         /
                         ';'                                               /
                         statementExpression ';'                           /
                         Identifier ':' statement

statementExpression   <-  assignment                           /
                          ('++' / '--') (primary / qualIdent)  /
                          (primary / qualIdent) ('++' / '--')  /
                          primary

switchBlock           <-  '{' switchBlockStatementGroup* switchLabel* '}'

switchBlockStatementGroup  <-  switchLabels blockStatements

switchLabels          <-  switchLabel switchLabel*

switchLabel           <-  'case' (constantExpression / enumConstantName) ':'  /
                          'default' ':'

enumConstantName      <-  Identifier

basicForStatement     <-  'for' '(' forInit? ';' expression? ';' forUpdate? ')' statement

forInit               <-  localVariableDeclaration  /  statementExpressionList

forUpdate             <-  statementExpressionList

statementExpressionList  <-  statementExpression (',' statementExpression)*

enhancedForStatement  <-  'for' '(' variableModifier* unannType variableDeclaratorId ':'
                            expression ')' statement

tryStatement          <-  'try' (block (catchClause* finally  /  catchClause+)  /
                                 resourceSpecification block catchClause* finally?)

catchClause           <-  'catch' '(' catchFormalParameter ')' block

catchFormalParameter  <-  variableModifier* catchType variableDeclaratorId

catchType             <-  unannClassType ('|'![=|] classType)*

finally               <-  'finally' block

resourceSpecification <-  '(' resourceList ';'? ')'

resourceList          <-  resource (',' resource)*

resource              <-  variableModifier* unannType variableDeclaratorId '='!'=' expression


-- JLS 15 Expressions
expression            <-  lambdaExpression  /  assignmentExpression

primary               <-  primaryBase primaryRest*

primaryBase           <-  'this'
                       /  Literal
                       /  parExpression
                       /  'super' ('.' typeArguments? Identifier arguments  /
                                   '.' Identifier                            /
                                   '::' typeArguments? Identifier
                                  ) 
                       /  'new' (classCreator  /  arrayCreator)
                       /  qualIdent ('[' expression ']' /
                                     arguments          /
                                     '.' ('this'                                           /
                                          'new' classCreator                               /
                                          typeArguments Identifier arguments               /
                                          'super' '.' typeArguments? Identifier arguments  /
                                          'super' '.' Identifier                           /
                                          'super' '::' typeArguments? Identifier arguments
                                         )
                                                        /  ('[' ']')* '.' 'class'
                                                        /  '::' typeArguments? Identifier
                                     )
                       /  'void' '.' 'class'
                       /  basicType ('[' ']')* '.' 'class'
                       /  referenceType '::' typeArguments? 'new'
                       /  arrayType '::' 'new'

primaryRest           <-  '.' (typeArguments? Identifier arguments  /
                               Identifier                           /
                               'new' classCreator
                              )
                       /  '[' expression ']'
                       /  '::' typeArguments? Identifier

parExpression         <-  '(' expression ')'

-- Commented out: ClassInstanceCreationExpression

classCreator          <-  typeArguments? annotation* classTypeWithDiamond
                            arguments classBody?

classTypeWithDiamond  <-  annotation* Identifier typeArgumentsOrDiamond?
                            ('.' annotation* Identifier typeArgumentsOrDiamond?)*

typeArgumentsOrDiamond  <-  typeArguments  /  '<' '>' !'.'

arrayCreator          <-  type dimExpr+ dim*  /  type dim+ arrayInitializer

dimExpr               <-  annotation* '[' expression ']'

--Commented out: ArrayAcess, FieldAcess, MethodInvocation

arguments             <-  '(' argumentList? ')'

argumentList          <-  expression (',' expression)*

unaryExpression       <-  ('++' / '--') (primary / qualIdent)  /
                          '+' ![=+] unaryExpression            /
                          '-' ![-=>] unaryExpression           /
                          unaryExpressionNotPlusMinus

unaryExpressionNotPlusMinus  <-  '~' unaryExpression        /
                                 '!' ![=&] unaryExpression  /
                                 castExpression             /
                                 (primary / qualIdent) ('++' / '--')?

castExpression        <-  '(' primitiveType ')' unaryExpression                    /
                          '(' referenceType additionalBound* ')' lambdaExpression  /
                          '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus

infixExpression       <-  unaryExpression ((InfixOperator unaryExpression) /
                                           ('instanceof' referenceType))*

InfixOperator         <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]          /
                          '=='  /  '!='  /  '<' ![=<]  /  '>'![=>]  /  '<='               /
                          '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /
                          '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]

conditionalExpression <-  infixExpression ('query' expression ':' expression)*

assignmentExpression  <-  assignment  /  conditionalExpression

assignment            <-  leftHandSide AssignmentOperator expression

leftHandSide          <-  primary  /  qualIdent

AssignmentOperator    <-  '='![=]  /  '*='  /  '/='  /  '%='  /
                          '+='  /  '-='  /  '<<='  / '>>='    /
                          '>>>='  /  '&='  /  '^='  /  '|='

lambdaExpression      <-  lambdaParameters '->' lambdaBody

lambdaParameters      <-  Identifier                          /
                          '(' formalParameterList? ')'        /
                          '(' inferredFormalParameterList ')'

inferredFormalParameterList  <-  Identifier (',' Identifier)*

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

COMMENT              <- '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
]]

local g = m.match(g)

print("Regular Annotation")
local glab = recovery.addlab(g, true, false)
print(pretty.printg(glab))
print("\n\n\n")


print("Conservative Annotation (Hard)")
local glab = recovery.addlab(g, true, true)
print(pretty.printg(glab))
print("\n\n\n")


print("Conservative Annotation (Soft)")
local glab = recovery.addlab(g, true, 'soft')
print(pretty.printg(glab))
print()
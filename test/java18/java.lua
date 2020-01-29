local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
compilation           <-  SKIP compilationUnit !.

-- JLS 4 Types, Values and Variables
basicType            <-  BYTE  /  SHORT  /  INT  /  LONG /
                         CHAR  /  FLOAT  /  DOUBLE  /  BOOLEAN

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

typeBound            <-  EXTENDS (classType additionalBound*  /  typeVariable)

additionalBound      <-  AND classType

typeArguments        <-  '<' typeArgumentList '>'

typeArgumentList     <-  typeArgument (',' typeArgument)*

typeArgument         <-  referenceType  /  wildcard

wildcard             <-  annotation* '?' wildcardBounds?

wildcardBounds       <-  EXTENDS referenceType  / SUPER referenceType


-- JLS 6 Names
qualIdent            <-  Identifier ('.' Identifier)*


-- JLS 7 Packages
compilationUnit      <-  packageDeclaration? importDeclaration* typeDeclaration*

packageDeclaration   <-  packageModifier* PACKAGE Identifier ('.' Identifier)* ';'

packageModifier      <-  annotation

importDeclaration    <-  IMPORT STATIC? qualIdent ('.' '*')? ';'  /  ';'

typeDeclaration      <-  classDeclaration  /  interfaceDeclaration  /  ';'


-- JLS 8 Classes
classDeclaration     <-  normalClassDeclaration  /  enumDeclaration

normalClassDeclaration  <-  classModifier* CLASS Identifier typeParameters?
                              superclass? superinterfaces? classBody

classModifier        <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         ABSTRACT  /  STATIC  /  FINAL  /  STRICTFP

typeParameters       <-  '<' typeParameterList '>'

typeParameterList    <-  typeParameter (',' typeParameter)*

superclass           <-  EXTENDS classType

superinterfaces      <-  IMPLEMENTS interfaceTypeList

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

fieldModifier        <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         STATIC  /  FINAL  /  TRANSIENT  /  VOLATILE

methodDeclaration    <-  methodModifier* methodHeader methodBody

methodHeader         <-  result methodDeclarator throws?  /
                         typeParameters annotation* result methodDeclarator throws?

methodDeclarator     <-  Identifier '(' formalParameterList? ')' dim*

formalParameterList  <-  (receiverParameter  /  formalParameter) (',' formalParameter)*

formalParameter      <-  variableModifier* unannType variableDeclaratorId  /
                         variableModifier* unannType annotation* '...' variableDeclaratorId !','

variableModifier     <-  annotation  /  FINAL

receiverParameter    <-  variableModifier* unannType (Identifier '.')? THIS

result               <-  unannType  /  VOID

methodModifier       <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         ABSTRACT  /  STATIC  /  FINAL  /  SYNCHRONIZED  /
                         NATIVE  /  STRICTFP

throws               <-  THROWS exceptionTypeList

exceptionTypeList    <-  exceptionType (',' exceptionType)*

exceptionType        <-  classType  /  typeVariable

methodBody           <-  block  /  ';'

instanceInitializer  <-  block

staticInitializer    <-  STATIC block

constructorDeclaration  <-  constructorModifier* constructorDeclarator throws? constructorBody

constructorDeclarator  <-  typeParameters? Identifier '(' formalParameterList? ')'

constructorModifier  <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE

constructorBody      <-  '{' explicitConstructorInvocation? blockStatements? '}'

explicitConstructorInvocation  <-  typeArguments? THIS  arguments ';'  /
                                   typeArguments? SUPER arguments ';'  /
                                   primary '.' typeArguments? SUPER arguments ';'  /
                                   qualIdent '.' typeArguments? SUPER arguments ';'

enumDeclaration       <-  classModifier* ENUM Identifier superinterfaces? enumBody

enumBody              <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'

enumConstantList      <-  enumConstant (',' enumConstant)*

enumConstant          <-  enumConstantModifier* Identifier arguments? classBody?

enumConstantModifier  <-  annotation

enumBodyDeclarations  <-  ';' classBodyDeclaration*


-- JLS 9 Interfaces
interfaceDeclaration  <-  normalInterfaceDeclaration  /  annotationTypeDeclaration

normalInterfaceDeclaration  <-  interfaceModifier* INTERFACE Identifier typeParameters?
                                  extendsInterfaces? interfaceBody

interfaceModifier     <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                          ABSTRACT  /  STATIC  /  STRICTFP

extendsInterfaces     <-  EXTENDS interfaceTypeList

interfaceBody         <-  '{' interfaceMemberDeclaration* '}'

interfaceMemberDeclaration  <-  constantDeclaration  /  interfaceMethodDeclaration  /
                                classDeclaration  /  interfaceDeclaration  /  ';'

constantDeclaration   <-  constantModifier* unannType variableDeclaratorList ';'

constantModifier      <-  annotation  /  PUBLIC  /  STATIC  /  FINAL

interfaceMethodDeclaration  <-  interfaceMethodModifier* methodHeader methodBody

interfaceMethodModifier  <-  annotation  /  PUBLIC  /  ABSTRACT  /
                             DEFAULT  /  STATIC  /  STRICTFP

annotationTypeDeclaration  <-  interfaceModifier* '@' INTERFACE Identifier annotationTypeBody

annotationTypeBody    <-  '{' annotationTypeMemberDeclaration* '}'

annotationTypeMemberDeclaration  <-  annotationTypeElementDeclaration  /
                                     constantDeclaration               /
                                     classDeclaration                  /
                                     interfaceDeclaration              /
                                     ';'

annotationTypeElementDeclaration  <-  annotationTypeElementModifier* unannType
                                        Identifier '(' ')' dim* defaultValue? ';'

annotationTypeElementModifier  <-  annotation  /  PUBLIC  /  ABSTRACT

defaultValue          <-  DEFAULT elementValue

annotation            <-  '@' (normalAnnotation         /
                               singleElementAnnotation  /
                               markerAnnotation)

normalAnnotation      <-  qualIdent '(' elementValuePairList? ')'

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
                         IF parExpression statement (ELSE statement)?  /
                         basicForStatement                                 /
                         enhancedForStatement                              /
                         WHILE parExpression statement                   /
                         DO statement WHILE parExpression ';'          /
                         tryStatement                                      /
                         SWITCH parExpression switchBlock                /
                         SYNCHRONIZED parExpression block                /
                         RETURN expression? ';'                          /
                         THROW expression ';'                            /
                         BREAK Identifier? ';'                           /
                         CONTINUE Identifier? ';'                        /
                         ASSERT expression (':' expression)? ';'         /
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

switchLabel           <-  CASE (constantExpression / enumConstantName) ':'  /
                          DEFAULT ':'

enumConstantName      <-  Identifier

basicForStatement     <-  FOR '(' forInit? ';' expression? ';' forUpdate? ')' statement

forInit               <-  localVariableDeclaration  /  statementExpressionList

forUpdate             <-  statementExpressionList

statementExpressionList  <-  statementExpression (',' statementExpression)*

enhancedForStatement  <-  FOR '(' variableModifier* unannType variableDeclaratorId ':'
                            expression ')' statement

tryStatement          <-  TRY (block (catchClause* finally  /  catchClause+)  /
                                 resourceSpecification block catchClause* finally?)

catchClause           <-  CATCH '(' catchFormalParameter ')' block

catchFormalParameter  <-  variableModifier* catchType variableDeclaratorId

catchType             <-  unannClassType ('|'![=|] classType)*

finally               <-  FINALLY block

resourceSpecification <-  '(' resourceList ';'? ')'

resourceList          <-  resource (';' resource)*

resource              <-  variableModifier* unannType variableDeclaratorId '='!'=' expression


-- JLS 15 Expressions
expression            <-  lambdaExpression  /  assignmentExpression

primary               <-  primaryBase primaryRest*

primaryBase           <-  THIS
                       /  Literal
                       /  parExpression
                       /  SUPER ('.' typeArguments? Identifier arguments  /
                                   '.' Identifier                            /
                                   '::' typeArguments? Identifier
                                  ) 
                       /  NEW (classCreator  /  arrayCreator)
                       /  qualIdent ('[' expression ']' /
                                     arguments          /
                                     '.' (THIS                                           /
                                          NEW classCreator                               /
                                          typeArguments Identifier arguments               /
                                          SUPER '.' typeArguments? Identifier arguments  /
                                          SUPER '.' Identifier                           /
                                          SUPER '::' typeArguments? Identifier arguments
                                         )
                                                        /  ('[' ']')* '.' CLASS
                                                        /  '::' typeArguments? Identifier
                                     )
                       /  VOID '.' CLASS
                       /  basicType ('[' ']')* '.' CLASS
                       /  referenceType '::' typeArguments? NEW
                       /  arrayType '::' NEW

primaryRest           <-  '.' (typeArguments? Identifier arguments  /
                               Identifier                           /
                               NEW classCreator
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
                                           (INSTANCEOF referenceType))*

InfixOperator         <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]          /
                          '=='  /  '!='  /  '<' ![=<]  /  '>'![=>]  /  '<='               /
                          '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /
                          '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]

conditionalExpression <-  infixExpression ('?' expression ':' expression)*

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
Identifier            <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*

-- JLS 3.9 Keywords
Keywords              <- ABSTRACT  /  AND  /  ASSERT  /  BYTE  /  BOOLEAN  /  BREAK  /  CASE  /  CATCH  /  CHAR  /  CLASS  /  CONTINUE  /  DEFAULT  /  DO  /  DOUBLE  /  ELSE  /  ENUM  /  EXTENDS  /  FALSE  /  FINAL  /  FINALLY  /  FLOAT  /  FOR  /  IF  /  IMPLEMENTS  /  IMPORT  /  INSTANCEOF  /  INT  /  INTERFACE  /  LONG  /  NATIVE  /  NEW  /  NULL  /  PACKAGE  /  PRIVATE  /  PROTECTED  /  PUBLIC  /  RETURN  /  SYNCHRONIZED  /  STRICTFP  /  SHORT  /  STATIC  /  SUPER  /  SWITCH  /  THIS  /  THROWS  /  THROW  /  TRANSIENT  /  TRUE  /  TRY  /  VOID  /  VOLATILE  /  WHILE
   
 
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
BooleanLiteral       <-  TRUE  /  FALSE


-- JLS 3.10.4 Character Literals
-- JLS 3.10.5 String Literals
-- JLS 3.10.6 Null Literal

CharLiteral          <-  "'" (%nl / '\n' / '\0' / '\t' / '\\' / "\'" / '\"' / '\u' [a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9] / !"'" .)  "'"

StringLiteral        <-  '"' (%nl / '\n' / '\0' / '\t' / '\\' / "\'" / '\"' / '\u' [a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9] / !'"' .)* '"'

NullLiteral          <-  NULL

COMMENT              <- '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'

ABSTRACT             <- 'abstract' ![a-zA-Z_$0-9]
AND                  <- 'and' ![a-zA-Z_$0-9]
ASSERT               <- 'assert' ![a-zA-Z_$0-9]
BYTE                 <- 'byte' ![a-zA-Z_$0-9]
BOOLEAN              <- 'boolean' ![a-zA-Z_$0-9]
BREAK                <- 'break' ![a-zA-Z_$0-9]
CASE                 <- 'case' ![a-zA-Z_$0-9]
CATCH                <- 'catch' ![a-zA-Z_$0-9]
CHAR                 <- 'char' ![a-zA-Z_$0-9]
CLASS                <- 'class' ![a-zA-Z_$0-9]
CONTINUE             <- 'continue' ![a-zA-Z_$0-9]
DEFAULT              <- 'default' ![a-zA-Z_$0-9]
DO                   <- 'do' ![a-zA-Z_$0-9]
DOUBLE               <- 'double' ![a-zA-Z_$0-9]
ELSE                 <- 'else' ![a-zA-Z_$0-9]
ENUM                 <- 'enum' ![a-zA-Z_$0-9]
EXTENDS              <- 'extends' ![a-zA-Z_$0-9]
FALSE                <- 'false' ![a-zA-Z_$0-9]
FINAL                <- 'final' ![a-zA-Z_$0-9]
FINALLY              <- 'finally' ![a-zA-Z_$0-9]
FLOAT                <- 'float' ![a-zA-Z_$0-9]
FOR                  <- 'for' ![a-zA-Z_$0-9]
IF                   <- 'if' ![a-zA-Z_$0-9]
IMPLEMENTS           <- 'implements' ![a-zA-Z_$0-9]
IMPORT               <- 'import' ![a-zA-Z_$0-9]
INSTANCEOF           <- 'instanceof' ![a-zA-Z_$0-9]
INT                  <- 'int' ![a-zA-Z_$0-9]
INTERFACE            <- 'interface' ![a-zA-Z_$0-9]
LONG                 <- 'long' ![a-zA-Z_$0-9]
NATIVE               <- 'native' ![a-zA-Z_$0-9]
NEW                  <- 'new' ![a-zA-Z_$0-9]
NULL                 <- 'null' ![a-zA-Z_$0-9]
PACKAGE              <- 'package' ![a-zA-Z_$0-9]
PRIVATE              <- 'private' ![a-zA-Z_$0-9]
PROTECTED            <- 'protected' ![a-zA-Z_$0-9]
PUBLIC               <- 'public' ![a-zA-Z_$0-9]
RETURN               <- 'return' ![a-zA-Z_$0-9]
SYNCHRONIZED         <- 'synchronized' ![a-zA-Z_$0-9]
STRICTFP             <- 'strictfp' ![a-zA-Z_$0-9]
SHORT                <- 'short' ![a-zA-Z_$0-9]
STATIC               <- 'static' ![a-zA-Z_$0-9] 
SUPER                <- 'super' ![a-zA-Z_$0-9]
SWITCH               <- 'switch' ![a-zA-Z_$0-9]
THIS                 <- 'this' ![a-zA-Z_$0-9]
THROWS               <- 'throws' ![a-zA-Z_$0-9]
THROW                <- 'throw' ![a-zA-Z_$0-9]
TRANSIENT            <- 'transient' ![a-zA-Z_$0-9]
TRUE                 <- 'true' ![a-zA-Z_$0-9]
TRY                  <- 'try' ![a-zA-Z_$0-9]
VOID                 <- 'void' ![a-zA-Z_$0-9]
VOLATILE             <- 'volatile' ![a-zA-Z_$0-9]
WHILE                <- 'while' ![a-zA-Z_$0-9]
]]

--[==[
print("Regular Annotation (SBLP paper)")
g = m.match(s)
local greg = recovery.putlabels(g, 'regular', true)
print(pretty.printg(greg, true), '\n')
print("End Regular\n")


print("Annotating All expressions")
g = m.match(s)
local gall = recovery.putlabels(g, 'all', true)
print(pretty.printg(gall, true), '\n')
print("End All\n")

print("Deep Ban")
g = m.match(s)
local gdeep = recovery.putlabels(g, 'deep', true)
print(pretty.printg(gdeep, true), '\n')
--print(pretty.printg(gdeep, true, 'ban'), '\n')
print("End Deep\n")


print("Unique Labels")
g = m.match(s)
--m.uniqueTk(g)
local gunique = recovery.putlabels(g, 'unique', true)
print(pretty.printg(gunique, true), '\n')
print("End Unique\n")
]==]

print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath')
print(pretty.printg(gupath, true), '\n')
print(pretty.printg(gupath, true, 'unique'), '\n')
pretty.printToFile(g)
print("End UPath\n")

--[==[
print("Deep UPath")
g = m.match(s)
local gupath = recovery.putlabels(g, 'deepupath', true)
print(pretty.printg(gupath, true), '\n')
print("End DeepUPath\n")


print("UPath Deep")
--m.uniqueTk(g)
g = m.match(s)
local gupath = recovery.putlabels(g, 'upathdeep', true)
print(pretty.printg(gupath, true), '\n')
print("End UPathDeep\n")
]==]

local g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0]) .. '/test'
if arg[1] then
  dir = util.getPath(arg[1])
end

util.testYes(dir .. '/yes/', 'java', p)
util.testNo(dir .. '/no/', 'java', p)

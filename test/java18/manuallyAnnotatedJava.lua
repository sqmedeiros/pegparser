local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
compilation           <-  SKIP compilationUnit (!.)^EndErr

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

additionalBound      <-  AND classType^ClassTypeErr1

typeArguments        <-  '<' typeArgumentList '>'

typeArgumentList     <-  typeArgument (',' typeArgument^TypeArgumentErr)*

typeArgument         <-  referenceType  /  wildcard

wildcard             <-  annotation* '?' wildcardBounds?

wildcardBounds       <-  EXTENDS referenceType^ReferenceTypeErr1  / SUPER referenceType^ReferenceTypeErr2


-- JLS 6 Names
qualIdent            <-  Identifier ('.' Identifier)*


-- JLS 7 Packages
compilationUnit      <-  packageDeclaration? importDeclaration* typeDeclaration*

packageDeclaration   <-  packageModifier* PACKAGE Identifier^IdErr1 ('.' Identifier^IdErr2)* ';'^SemiErr1

packageModifier      <-  annotation

importDeclaration    <-  IMPORT STATIC? qualIdent^QualIdentErr1 ('.' '*'^AsteriskErr)? ';'^SemiErr2  /  ';'

typeDeclaration      <-  classDeclaration  /  interfaceDeclaration  /  ';'


-- JLS 8 Classes
classDeclaration     <-  normalClassDeclaration  /  enumDeclaration

normalClassDeclaration  <-  classModifier* CLASS Identifier^IdErr3 typeParameters?
                              superclass? superinterfaces? classBody^ClassBodyErr

classModifier        <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         ABSTRACT  /  STATIC  /  FINAL  /  STRICTFP

typeParameters       <-  '<' typeParameterList^TypeParameterListErr '>'^GeqErr

typeParameterList    <-  typeParameter (',' typeParameter^TypeParameterErr)*

superclass           <-  EXTENDS classType^ClassTypeErr2

superinterfaces      <-  IMPLEMENTS interfaceTypeList^InterfaceTypeListErr1

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

fieldModifier        <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         STATIC  /  FINAL  /  TRANSIENT  /  VOLATILE

methodDeclaration    <-  methodModifier* methodHeader methodBody^MethodBodyErr1

methodHeader         <-  result methodDeclarator throws?  /
                         typeParameters annotation* result^ResultErr methodDeclarator^MethodDeclaratorErr throws?

methodDeclarator     <-  Identifier '('^LParErr1 formalParameterList? ')'^RParErr1 dim*

formalParameterList  <-  (receiverParameter  /  formalParameter) (',' formalParameter^FormalParameterErr)*

formalParameter      <-  variableModifier* unannType variableDeclaratorId  /
                         variableModifier* unannType annotation* '...' variableDeclaratorId^VariableDeclaratorIdErr1 (!',')^CommaAvaliableErr

variableModifier     <-  annotation  /  FINAL

receiverParameter    <-  variableModifier* unannType (Identifier '.')? THIS

result               <-  unannType  /  VOID

methodModifier       <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                         ABSTRACT  /  STATIC  /  FINAL  /  SYNCHRONIZED  /
                         NATIVE  /  STRICTFP

throws               <-  THROWS exceptionTypeList^ExceptionTypeListErr

exceptionTypeList    <-  exceptionType (',' exceptionType^ExceptionTypeErr)*

exceptionType        <-  classType  /  typeVariable

methodBody           <-  block  /  ';'

instanceInitializer  <-  block

staticInitializer    <-  STATIC block^BlockErr1

constructorDeclaration  <-  constructorModifier* constructorDeclarator throws? constructorBody^ConstructorBodyErr

constructorDeclarator  <-  typeParameters? Identifier '('^LParErr2 formalParameterList? ')'^RParErr2

constructorModifier  <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE

constructorBody      <-  '{' explicitConstructorInvocation? blockStatements? '}'^CurRBrackErr2

explicitConstructorInvocation  <-  typeArguments? THIS  arguments ';'^SemiErr3  /
                                   typeArguments? SUPER arguments ';'^SemiErr4  /
                                   primary '.' typeArguments? SUPER^SUPERErr1 arguments^ArgumentsErr1 ';'^SemiErr5  /
                                   qualIdent '.' typeArguments? SUPER^SUPERErr2 arguments^ArgumentsErr2 ';'^SemiErr6

enumDeclaration       <-  classModifier* ENUM Identifier^IdErr4 superinterfaces? enumBody^EnumBodyErr

enumBody              <-  '{' enumConstantList? ','? enumBodyDeclarations? '}'^CurRBrackErr3

enumConstantList      <-  enumConstant (',' enumConstant)*

enumConstant          <-  enumConstantModifier* Identifier arguments? classBody?

enumConstantModifier  <-  annotation

enumBodyDeclarations  <-  ';' classBodyDeclaration*


-- JLS 9 Interfaces
interfaceDeclaration  <-  normalInterfaceDeclaration  /  annotationTypeDeclaration

normalInterfaceDeclaration  <-  interfaceModifier* INTERFACE Identifier^IdErr5 typeParameters?
                                  extendsInterfaces? interfaceBody^InterfaceBodyErr

interfaceModifier     <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /
                          ABSTRACT  /  STATIC  /  STRICTFP

extendsInterfaces     <-  EXTENDS interfaceTypeList^InterfaceTypeListErr2

interfaceBody         <-  '{' interfaceMemberDeclaration* '}'^CurRBrackErr4

interfaceMemberDeclaration  <-  constantDeclaration  /  interfaceMethodDeclaration  /
                                classDeclaration  /  interfaceDeclaration  /  ';'

constantDeclaration   <-  constantModifier* unannType variableDeclaratorList^VariableDeclaratorListErr ';'

constantModifier      <-  annotation  /  PUBLIC  /  STATIC  /  FINAL

interfaceMethodDeclaration  <-  interfaceMethodModifier* methodHeader methodBody^MethodBodyErr2

interfaceMethodModifier  <-  annotation  /  PUBLIC  /  ABSTRACT  /
                             DEFAULT  /  STATIC  /  STRICTFP

annotationTypeDeclaration  <-  interfaceModifier* '@' INTERFACE^InterfaceWordErr Identifier^IdErr6 annotationTypeBody^AnnotationTypeBodyErr

annotationTypeBody    <-  '{' annotationTypeMemberDeclaration* '}'^CurRBrackErr5

annotationTypeMemberDeclaration  <-  annotationTypeElementDeclaration  /
                                     constantDeclaration               /
                                     classDeclaration                  /
                                     interfaceDeclaration              /
                                     ';'

annotationTypeElementDeclaration  <-  annotationTypeElementModifier* unannType
                                      Identifier^IdErr7 '('^LParErr3 ')'^RParErr3 dim* defaultValue? ';'^SemiErr7

annotationTypeElementModifier  <-  annotation  /  PUBLIC  /  ABSTRACT

defaultValue          <-  DEFAULT elementValue^ElementValueErr1

annotation            <-  '@' (normalAnnotation         /
                               singleElementAnnotation  /
                               markerAnnotation)

normalAnnotation      <-  qualIdent '(' elementValuePairList* ')'

elementValuePairList  <-  elementValuePair (',' elementValuePair^ElementValuePairErr)*

elementValuePair      <-  Identifier '=' !'=' elementValue^ElementValueErr2

elementValue          <-  conditionalExpression         /
                          elementValueArrayInitializer  /
                          annotation

elementValueArrayInitializer  <-  '{' elementValueList? ','? '}'^CurRBrackErr6

elementValueList      <-  elementValue (',' elementValue)*

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
                         IF parExpression^ParExpressionErr1 statement^StatementErr1 (ELSE statement^StatementErr2)? /
                         basicForStatement                                 /
                         enhancedForStatement                              /
                         WHILE parExpression^ParExpressionErr2 statement^StatementErr3 /
                         DO statement^StatementErr4 WHILE^WHILEErr parExpression^ParExpressionErr3 ';'^SemiErr9 /
                         tryStatement                                      /
                         SWITCH parExpression^ParExpressionErr4 switchBlock^SwitchBlockErr /
                         SYNCHRONIZED parExpression^ParExpressionErr5 block^BlockErr2 /
                         RETURN expression? ';'^SemiErr10                  /
                         THROW expression^ExpressionErr1 ';'^SemiErr11      /
                         BREAK Identifier? ';'^SemiErr12                   /
                         CONTINUE Identifier? ';'^SemiErr13                /
                         ASSERT expression^ExpressionErr2 (':' expression^ExpressionErr3)? ';'^SemiErr14 /
                         ';'                                                 /
                         statementExpression ';'^SemiErr15                   /
                         Identifier ':'^ColonErr1 statement^StatementErr5

statementExpression   <-  assignment                           /
                          ('++' / '--') (primary / qualIdent)^AfterIteratorSymbolErr  /
                          (primary / qualIdent) ('++' / '--')  /
                          primary

switchBlock           <-  '{' switchBlockStatementGroup* switchLabel* '}'^CurRBrackErr9

switchBlockStatementGroup  <-  switchLabels blockStatements

switchLabels          <-  switchLabel switchLabel*

switchLabel           <-  CASE (constantExpression / enumConstantName)^CaseExpressionErr ':'^ColonErr2  /
                          DEFAULT ':'^ColonErr3

enumConstantName      <-  Identifier

basicForStatement     <-  FOR '('^LParErr4 forInit? ';' expression? ';'^SemiErr16 forUpdate? ')'^RParErr5 statement^StatementErr6

forInit               <-  localVariableDeclaration  /  statementExpressionList

forUpdate             <-  statementExpressionList

statementExpressionList  <-  statementExpression (',' statementExpression^StatementExpressionErr)*

enhancedForStatement  <-  FOR '(' variableModifier* unannType variableDeclaratorId ':'^ColonErr4
                            expression^ExpressionErr4 ')'^RParErr6 statement^StatementErr7

tryStatement          <-  TRY ( block (catchClause* finally  /  catchClause+)^AfterBlockErr
                                / resourceSpecification block^BlockErr3 catchClause* finally? )^AfterTryErr

catchClause           <-  CATCH '('^LParErr5 catchFormalParameter^CatchFormalParameterErr ')'^RParErr7 block^BlockErr4

catchFormalParameter  <-  variableModifier* catchType variableDeclaratorId^VariableDeclaratorIdErr2

catchType             <-  unannClassType ('|' (![=|])^EqVerticalBarAvaliableErr classType^ClassTypeErr4)*

finally               <-  FINALLY block^BlockErr5

resourceSpecification <-  '(' resourceList^ResourceListErr ';'? ')'^RParErr8

resourceList          <-  resource (';' resource^ResourceErr)*

resource              <-  variableModifier* unannType variableDeclaratorId^VariableDeclaratorIdErr3 '=' (!'=')^EqAvaliableErr3 expression^ExpressionErr5


-- JLS 15 Expressions
expression            <-  lambdaExpression  /  assignmentExpression

primary               <-  primaryBase primaryRest*

primaryBase           <-  THIS
                       /  Literal
                       /  parExpression
                       /  SUPER ( '.' typeArguments? Identifier arguments
                                  / '.' Identifier^IdErr8
                                  / '::' typeArguments? Identifier^IdErr9 )^AfterSuperErr
                       /  NEW (classCreator / arrayCreator)^AfterNewErr
                       /  qualIdent ( '[' expression ']'^RBrackErr1
                                    / arguments
                                    / '.' ( THIS
                                          / NEW classCreator^ClassCreatorErr1
                                          / typeArguments Identifier^IdErr10 arguments^ArgumentsErr3
                                          / SUPER '.' typeArguments? Identifier arguments
                                          / SUPER '.' Identifier^IdErr11
                                          / SUPER '::' typeArguments? Identifier^IdErr12 arguments^ArgumentsErr5
                                          )
                                    / ('[' ']'^RBrackErr2)* '.' CLASS
                                    /  '::' typeArguments? Identifier^IdErr13 )
                       /  VOID '.'^DotErr1 CLASS^CLASSErr1
                       /  basicType ('[' ']'^RBrackErr3)* '.' CLASS^CLASSErr2
                       /  referenceType '::' typeArguments? NEW^NEWErr1
                       /  arrayType '::' NEW

primaryRest           <-  '.' ( typeArguments? Identifier arguments
                              / Identifier
                              / NEW classCreator^ClassCreatorErr2 )
                       /  '[' expression^ExpressionErr6 ']'^RBrackErr4
                       /  '::' typeArguments? Identifier^IdErr14

parExpression         <-  '(' expression ')'

-- Commented out: ClassInstanceCreationExpression

classCreator          <-  typeArguments? annotation* classTypeWithDiamond
                            arguments classBody?

classTypeWithDiamond  <-  annotation* Identifier typeArgumentsOrDiamond?
                            ('.' annotation* Identifier^IdErr15 typeArgumentsOrDiamond?)*

typeArgumentsOrDiamond  <-  typeArguments  /  '<' '>'^GreaterErr1 (!'.')^DotAvaliableErr

arrayCreator          <-  type dimExpr+ dim*  /  type dim+ arrayInitializer^ArrayInitializerErr

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

castExpression        <-  '(' primitiveType ')' unaryExpression^UnaryExpressionErr5 /
                          '(' referenceType additionalBound* ')' lambdaExpression /
                          '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus

infixExpression       <-  unaryExpression ((InfixOperator unaryExpression) /
                                           (INSTANCEOF referenceType^ReferenceTypeErr3))*

InfixOperator         <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]          /
                          '=='  /  '!='  /  '<' ![=<]  /  '>'![=>]  /  '<='               /
                          '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /
                          '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]

conditionalExpression <-  infixExpression ('?' expression^ExpressionErr8 ':'^ColonErr5 expression^ExpressionErr9)*

assignmentExpression  <-  assignment  /  conditionalExpression

assignment            <-  leftHandSide AssignmentOperator expression^ExpressionErr10

leftHandSide          <-  primary  /  qualIdent

AssignmentOperator    <-  '='![=]  /  '*='  /  '/='  /  '%='  /
                          '+='  /  '-='  /  '<<='  / '>>='    /
                          '>>>='  /  '&='  /  '^='  /  '|='

lambdaExpression      <-  lambdaParameters '->' lambdaBody^LambdaBodyErr

lambdaParameters      <-  Identifier                          /
                          '(' formalParameterList? ')'       /
                          '(' inferredFormalParameterList ')'

inferredFormalParameterList  <-  Identifier (',' Identifier^IdErr16)*

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

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0]) .. '/test'
if arg[1] then
  dir = util.getPath(arg[1])
end

util.testYes(dir .. '/yes/', 'java', p)
util.testNo(dir .. '/no/', 'java', p) 
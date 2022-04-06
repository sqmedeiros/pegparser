local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
compilation     <-  SKIP^Err_001 compilationUnit^Err_002 !.
basicType       <-  BYTE  /  SHORT  /  INT  /  LONG  /  CHAR  /  FLOAT  /  DOUBLE  /  BOOLEAN
primitiveType   <-  annotation* basicType
referenceType   <-  primitiveType dim+  /  classType dim*
classType       <-  annotation* Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
type            <-  primitiveType  /  classType
arrayType       <-  primitiveType dim+  /  classType dim+
typeVariable    <-  annotation* Identifier
dim             <-  annotation* '[' ']'
typeParameter   <-  typeParameterModifier* Identifier typeBound?
typeParameterModifier <-  annotation
typeBound       <-  EXTENDS (classType additionalBound*  /  typeVariable)
additionalBound <-  AND classType^Err_003
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  EXTENDS referenceType^Err_004  /  SUPER referenceType
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  (packageDeclaration  /  !(STRICTFP  /  STATIC  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  INTERFACE  /  IMPORT  /  FINAL  /  ENUM  /  CLASS  /  ABSTRACT  /  '@'  /  ';'  /  !.) %{Err_005} .)? (importDeclaration  /  !(STRICTFP  /  STATIC  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  INTERFACE  /  FINAL  /  ENUM  /  CLASS  /  ABSTRACT  /  '@'  /  ';'  /  !.) %{Err_006} .)* (typeDeclaration  /  !(!.) %{Err_007} .)*
packageDeclaration <-  packageModifier* PACKAGE Identifier^Err_008 ('.' Identifier^Err_009  /  !';' %{Err_010} .)* ';'^Err_011
packageModifier <-  annotation
importDeclaration <-  IMPORT (STATIC  /  !Identifier %{Err_012} .)? qualIdent^Err_013 ('.' '*'^Err_014  /  !';' %{Err_015} .)? ';'^Err_016  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* CLASS Identifier^Err_017 (typeParameters  /  !('{'  /  IMPLEMENTS  /  EXTENDS) %{Err_018} .)? (superclass  /  !('{'  /  IMPLEMENTS) %{Err_019} .)? (superinterfaces  /  !'{' %{Err_020} .)? classBody^Err_021
classModifier   <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  FINAL  /  STRICTFP
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  EXTENDS classType^Err_022
superinterfaces <-  IMPLEMENTS interfaceTypeList^Err_023
interfaceTypeList <-  classType^Err_024 (',' classType^Err_025  /  !'{' %{Err_026} .)*
classBody       <-  '{' classBodyDeclaration* '}'
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  STATIC  /  FINAL  /  TRANSIENT  /  VOLATILE
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result methodDeclarator throws?
methodDeclarator <-  Identifier '(' formalParameterList? ')' dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_027 !','
variableModifier <-  annotation  /  FINAL
receiverParameter <-  variableModifier* unannType (Identifier '.')? THIS
result          <-  unannType  /  VOID
methodModifier  <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  FINAL  /  SYNCHRONIZED  /  NATIVE  /  STRICTFP
throws          <-  THROWS exceptionTypeList^Err_028
exceptionTypeList <-  exceptionType^Err_029 (',' exceptionType^Err_030  /  !('{'  /  ';') %{Err_031} .)*
exceptionType   <-  (classType  /  typeVariable^Err_032)^Err_033
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  STATIC block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? THIS arguments ';'^Err_034  /  typeArguments? SUPER arguments ';'  /  primary '.' typeArguments? SUPER arguments ';'  /  qualIdent '.' typeArguments? SUPER arguments ';'^Err_035
enumDeclaration <-  classModifier* ENUM Identifier^Err_036 (superinterfaces  /  !'{' %{Err_037} .)? enumBody^Err_038
enumBody        <-  '{'^Err_039 (enumConstantList  /  !('}'  /  ';'  /  ',') %{Err_040} .)? (','  /  !('}'  /  ';') %{Err_041} .)? (enumBodyDeclarations  /  !'}' %{Err_042} .)? '}'^Err_043
enumConstantList <-  enumConstant (',' enumConstant  /  !('}'  /  ';'  /  ',') %{Err_044} .)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' (classBodyDeclaration  /  !'}' %{Err_045} .)*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* INTERFACE Identifier^Err_046 (typeParameters  /  !('{'  /  EXTENDS) %{Err_047} .)? (extendsInterfaces  /  !'{' %{Err_048} .)? interfaceBody^Err_049
interfaceModifier <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  STRICTFP
extendsInterfaces <-  EXTENDS interfaceTypeList^Err_050
interfaceBody   <-  '{'^Err_051 (interfaceMemberDeclaration  /  !'}' %{Err_052} .)* '}'^Err_053
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  PUBLIC  /  STATIC  /  FINAL
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  PUBLIC  /  ABSTRACT  /  DEFAULT  /  STATIC  /  STRICTFP
annotationTypeDeclaration <-  interfaceModifier* '@' INTERFACE Identifier^Err_054 annotationTypeBody^Err_055
annotationTypeBody <-  '{'^Err_056 (annotationTypeMemberDeclaration  /  !'}' %{Err_057} .)* '}'^Err_058
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  PUBLIC  /  ABSTRACT
defaultValue    <-  DEFAULT elementValue
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList? ')'
elementValuePairList <-  elementValuePair (',' elementValuePair)*
elementValuePair <-  Identifier '=' !'=' elementValue
elementValue    <-  conditionalExpression  /  elementValueArrayInitializer  /  annotation
elementValueArrayInitializer <-  '{' elementValueList? ','? '}'
elementValueList <-  elementValue (',' elementValue)*
markerAnnotation <-  qualIdent
singleElementAnnotation <-  qualIdent '(' elementValue ')'
arrayInitializer <-  '{' variableInitializerList? ','? '}'
variableInitializerList <-  variableInitializer (',' variableInitializer)*
block           <-  '{' blockStatements? '}'
blockStatements <-  blockStatement blockStatement*
blockStatement  <-  localVariableDeclarationStatement  /  classDeclaration  /  statement
localVariableDeclarationStatement <-  localVariableDeclaration ';'
localVariableDeclaration <-  variableModifier* unannType variableDeclaratorList
statement       <-  block  /  IF parExpression^Err_059 statement^Err_060 (ELSE statement^Err_061  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_062} .)?  /  basicForStatement  /  enhancedForStatement  /  WHILE parExpression statement  /  DO statement^Err_063 WHILE^Err_064 parExpression^Err_065 ';'^Err_066  /  tryStatement  /  SWITCH parExpression^Err_067 switchBlock^Err_068  /  SYNCHRONIZED parExpression block^Err_069  /  RETURN (expression  /  !';' %{Err_070} .)? ';'^Err_071  /  THROW expression^Err_072 ';'^Err_073  /  BREAK (Identifier  /  !';' %{Err_074} .)? ';'^Err_075  /  CONTINUE (Identifier  /  !';' %{Err_076} .)? ';'^Err_077  /  ASSERT expression^Err_078 (':' expression^Err_079  /  !';' %{Err_080} .)? ';'^Err_081  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_082 (switchBlockStatementGroup  /  !('}'  /  DEFAULT  /  CASE) %{Err_083} .)* (switchLabel  /  !'}' %{Err_084} .)* '}'^Err_085
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  CASE (constantExpression  /  enumConstantName^Err_086)^Err_087 ':'^Err_088  /  DEFAULT ':'
enumConstantName <-  Identifier^Err_089
basicForStatement <-  FOR '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  FOR '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  TRY (block (catchClause* finally  /  (catchClause  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_090} .)+)^Err_091  /  resourceSpecification^Err_092 block^Err_093 (catchClause  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINALLY  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_094} .)* (finally  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_095} .)?)^Err_096
catchClause     <-  CATCH '('^Err_097 catchFormalParameter^Err_098 ')'^Err_099 block^Err_100
catchFormalParameter <-  (variableModifier  /  !Identifier %{Err_101} .)* catchType^Err_102 variableDeclaratorId^Err_103
catchType       <-  unannClassType^Err_104 ('|' ![=|] classType^Err_105  /  !Identifier %{Err_106} .)*
finally         <-  FINALLY block^Err_107
resourceSpecification <-  '('^Err_108 resourceList^Err_109 (';'  /  !')' %{Err_110} .)? ')'^Err_111
resourceList    <-  resource^Err_112 (';' resource  /  !(';'  /  ')') %{Err_113} .)*
resource        <-  variableModifier* unannType variableDeclaratorId '=' !'=' expression
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  THIS  /  Literal  /  parExpression  /  SUPER ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  NEW (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' (THIS  /  NEW classCreator  /  typeArguments Identifier arguments  /  SUPER '.' typeArguments? Identifier arguments  /  SUPER '.' Identifier^Err_114  /  SUPER '::' (typeArguments  /  !Identifier %{Err_115} .)? Identifier^Err_116 arguments^Err_117)  /  ('[' ']')* '.' CLASS  /  '::' typeArguments? Identifier)  /  VOID '.' CLASS^Err_118  /  basicType ('[' ']')* '.' CLASS  /  referenceType '::' typeArguments? NEW  /  arrayType '::' NEW
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  NEW classCreator)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>' !'.'
arrayCreator    <-  type dimExpr+ dim*  /  type dim+ arrayInitializer
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression  /  '-' ![-=>] unaryExpression  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_119  /  '!' ![=&] unaryExpression^Err_120  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression^Err_121  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (infixOperator unaryExpression  /  INSTANCEOF referenceType^Err_122)*
infixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('?' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_123
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_124
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block^Err_125)^Err_126
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  ABSTRACT  /  AND  /  ASSERT  /  BYTE  /  BOOLEAN  /  BREAK  /  CASE  /  CATCH  /  CHAR  /  CLASS  /  CONTINUE  /  DEFAULT  /  DO  /  DOUBLE  /  ELSE  /  ENUM  /  EXTENDS  /  FALSE  /  FINAL  /  FINALLY  /  FLOAT  /  FOR  /  IF  /  IMPLEMENTS  /  IMPORT  /  INSTANCEOF  /  INT  /  INTERFACE  /  LONG  /  NATIVE  /  NEW  /  NULL  /  PACKAGE  /  PRIVATE  /  PROTECTED  /  PUBLIC  /  RETURN  /  SYNCHRONIZED  /  STRICTFP  /  SHORT  /  STATIC  /  SUPER  /  SWITCH  /  THIS  /  THROWS  /  THROW  /  TRANSIENT  /  TRUE  /  TRY  /  VOID  /  VOLATILE  /  WHILE
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
BooleanLiteral  <-  TRUE  /  FALSE
CharLiteral     <-  "'" (%nl  /  '\n'  /  '\0'  /  '\t'  /  '\\'  /  "\'"  /  '\"'  /  '\u' [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9]  /  !"'" .) "'"
StringLiteral   <-  '"' (%nl  /  '\n'  /  '\0'  /  '\t'  /  '\\'  /  "\'"  /  '\"'  /  '\u' [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9]  /  !'"' .)* '"'
NullLiteral     <-  NULL
COMMENT         <-  '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
ABSTRACT        <-  'abstract' ![a-zA-Z_$0-9]
AND             <-  'and' ![a-zA-Z_$0-9]
ASSERT          <-  'assert' ![a-zA-Z_$0-9]
BYTE            <-  'byte' ![a-zA-Z_$0-9]
BOOLEAN         <-  'boolean' ![a-zA-Z_$0-9]
BREAK           <-  'break' ![a-zA-Z_$0-9]
CASE            <-  'case' ![a-zA-Z_$0-9]
CATCH           <-  'catch' ![a-zA-Z_$0-9]
CHAR            <-  'char' ![a-zA-Z_$0-9]
CLASS           <-  'class' ![a-zA-Z_$0-9]
CONTINUE        <-  'continue' ![a-zA-Z_$0-9]
DEFAULT         <-  'default' ![a-zA-Z_$0-9]
DO              <-  'do' ![a-zA-Z_$0-9]
DOUBLE          <-  'double' ![a-zA-Z_$0-9]
ELSE            <-  'else' ![a-zA-Z_$0-9]
ENUM            <-  'enum' ![a-zA-Z_$0-9]
EXTENDS         <-  'extends' ![a-zA-Z_$0-9]
FALSE           <-  'false' ![a-zA-Z_$0-9]
FINAL           <-  'final' ![a-zA-Z_$0-9]
FINALLY         <-  'finally' ![a-zA-Z_$0-9]
FLOAT           <-  'float' ![a-zA-Z_$0-9]
FOR             <-  'for' ![a-zA-Z_$0-9]
IF              <-  'if' ![a-zA-Z_$0-9]
IMPLEMENTS      <-  'implements' ![a-zA-Z_$0-9]
IMPORT          <-  'import' ![a-zA-Z_$0-9]
INSTANCEOF      <-  'instanceof' ![a-zA-Z_$0-9]
INT             <-  'int' ![a-zA-Z_$0-9]
INTERFACE       <-  'interface' ![a-zA-Z_$0-9]
LONG            <-  'long' ![a-zA-Z_$0-9]
NATIVE          <-  'native' ![a-zA-Z_$0-9]
NEW             <-  'new' ![a-zA-Z_$0-9]
NULL            <-  'null' ![a-zA-Z_$0-9]
PACKAGE         <-  'package' ![a-zA-Z_$0-9]
PRIVATE         <-  'private' ![a-zA-Z_$0-9]
PROTECTED       <-  'protected' ![a-zA-Z_$0-9]
PUBLIC          <-  'public' ![a-zA-Z_$0-9]
RETURN          <-  'return' ![a-zA-Z_$0-9]
SYNCHRONIZED    <-  'synchronized' ![a-zA-Z_$0-9]
STRICTFP        <-  'strictfp' ![a-zA-Z_$0-9]
SHORT           <-  'short' ![a-zA-Z_$0-9]
STATIC          <-  'static' ![a-zA-Z_$0-9]
SUPER           <-  'super' ![a-zA-Z_$0-9]
SWITCH          <-  'switch' ![a-zA-Z_$0-9]
THIS            <-  'this' ![a-zA-Z_$0-9]
THROWS          <-  'throws' ![a-zA-Z_$0-9]
THROW           <-  'throw' ![a-zA-Z_$0-9]
TRANSIENT       <-  'transient' ![a-zA-Z_$0-9]
TRUE            <-  'true' ![a-zA-Z_$0-9]
TRY             <-  'try' ![a-zA-Z_$0-9]
VOID            <-  'void' ![a-zA-Z_$0-9]
VOLATILE        <-  'volatile' ![a-zA-Z_$0-9]
WHILE           <-  'while' ![a-zA-Z_$0-9]
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'java', p)

util.testNo(dir .. '/test/no/', 'java', p)

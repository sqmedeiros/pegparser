local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
compilation     <-  SKIP compilationUnit !.
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
additionalBound <-  AND classType^Err_001
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  EXTENDS referenceType^Err_002  /  SUPER referenceType
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  (packageDeclaration  /  !(STRICTFP  /  STATIC  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  INTERFACE  /  IMPORT  /  FINAL  /  ENUM  /  CLASS  /  ABSTRACT  /  '@'  /  ';'  /  !.) %{Err_003} .)? (importDeclaration  /  !(STRICTFP  /  STATIC  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  INTERFACE  /  FINAL  /  ENUM  /  CLASS  /  ABSTRACT  /  '@'  /  ';'  /  !.) %{Err_004} .)* (typeDeclaration  /  !(!.) %{Err_005} .)*
packageDeclaration <-  packageModifier* PACKAGE Identifier^Err_006 ('.' Identifier^Err_007  /  !';' %{Err_008} .)* ';'^Err_009
packageModifier <-  annotation
importDeclaration <-  IMPORT (STATIC  /  !Identifier %{Err_010} .)? qualIdent^Err_011 ('.' '*'^Err_012  /  !';' %{Err_013} .)? ';'^Err_014  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* CLASS Identifier^Err_015 (typeParameters  /  !('{'  /  IMPLEMENTS  /  EXTENDS) %{Err_016} .)? (superclass  /  !('{'  /  IMPLEMENTS) %{Err_017} .)? (superinterfaces  /  !'{' %{Err_018} .)? classBody^Err_019
classModifier   <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  FINAL  /  STRICTFP
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  EXTENDS classType^Err_020
superinterfaces <-  IMPLEMENTS interfaceTypeList^Err_021
interfaceTypeList <-  classType^Err_022 (',' classType^Err_023  /  !'{' %{Err_024} .)*
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
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_025 !','
variableModifier <-  annotation  /  FINAL
receiverParameter <-  variableModifier* unannType (Identifier '.')? THIS
result          <-  unannType  /  VOID
methodModifier  <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  FINAL  /  SYNCHRONIZED  /  NATIVE  /  STRICTFP
throws          <-  THROWS exceptionTypeList^Err_026
exceptionTypeList <-  exceptionType^Err_027 (',' exceptionType^Err_028  /  !('{'  /  ';') %{Err_029} .)*
exceptionType   <-  (classType  /  typeVariable^Err_030)^Err_031
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  STATIC block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? THIS arguments ';'^Err_032  /  typeArguments? SUPER arguments ';'  /  primary '.' typeArguments? SUPER arguments ';'  /  qualIdent '.' typeArguments? SUPER arguments ';'^Err_033
enumDeclaration <-  classModifier* ENUM Identifier^Err_034 (superinterfaces  /  !'{' %{Err_035} .)? enumBody^Err_036
enumBody        <-  '{'^Err_037 (enumConstantList  /  !('}'  /  ';'  /  ',') %{Err_038} .)? (','  /  !('}'  /  ';') %{Err_039} .)? (enumBodyDeclarations  /  !'}' %{Err_040} .)? '}'^Err_041
enumConstantList <-  enumConstant (',' enumConstant  /  !('}'  /  ';'  /  ',') %{Err_042} .)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' (classBodyDeclaration  /  !'}' %{Err_043} .)*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* INTERFACE Identifier^Err_044 (typeParameters  /  !('{'  /  EXTENDS) %{Err_045} .)? (extendsInterfaces  /  !'{' %{Err_046} .)? interfaceBody^Err_047
interfaceModifier <-  annotation  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  ABSTRACT  /  STATIC  /  STRICTFP
extendsInterfaces <-  EXTENDS interfaceTypeList^Err_048
interfaceBody   <-  '{'^Err_049 (interfaceMemberDeclaration  /  !'}' %{Err_050} .)* '}'^Err_051
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  PUBLIC  /  STATIC  /  FINAL
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  PUBLIC  /  ABSTRACT  /  DEFAULT  /  STATIC  /  STRICTFP
annotationTypeDeclaration <-  interfaceModifier* '@' INTERFACE Identifier^Err_052 annotationTypeBody^Err_053
annotationTypeBody <-  '{'^Err_054 (annotationTypeMemberDeclaration  /  !'}' %{Err_055} .)* '}'^Err_056
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
statement       <-  block  /  IF parExpression^Err_057 statement^Err_058 (ELSE statement^Err_059  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_060} .)?  /  basicForStatement  /  enhancedForStatement  /  WHILE parExpression statement  /  DO statement^Err_061 WHILE^Err_062 parExpression^Err_063 ';'^Err_064  /  tryStatement  /  SWITCH parExpression^Err_065 switchBlock^Err_066  /  SYNCHRONIZED parExpression block^Err_067  /  RETURN (expression  /  !';' %{Err_068} .)? ';'^Err_069  /  THROW expression^Err_070 ';'^Err_071  /  BREAK (Identifier  /  !';' %{Err_072} .)? ';'^Err_073  /  CONTINUE (Identifier  /  !';' %{Err_074} .)? ';'^Err_075  /  ASSERT expression^Err_076 (':' expression^Err_077  /  !';' %{Err_078} .)? ';'^Err_079  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_080 (switchBlockStatementGroup  /  !('}'  /  DEFAULT  /  CASE) %{Err_081} .)* (switchLabel  /  !'}' %{Err_082} .)* '}'^Err_083
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  CASE (constantExpression  /  enumConstantName^Err_084)^Err_085 ':'^Err_086  /  DEFAULT ':'
enumConstantName <-  Identifier^Err_087
basicForStatement <-  FOR '(' forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  FOR '(' variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  TRY (block (catchClause* finally  /  (catchClause  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_088} .)+)^Err_089  /  resourceSpecification^Err_090 block^Err_091 (catchClause  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINALLY  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_092} .)* (finally  /  !('}'  /  '{'  /  WHILE  /  VOID  /  TRY  /  THROW  /  THIS  /  SYNCHRONIZED  /  SWITCH  /  SUPER  /  STRICTFP  /  STATIC  /  SHORT  /  RETURN  /  PUBLIC  /  PROTECTED  /  PRIVATE  /  NEW  /  Literal  /  LONG  /  Identifier  /  INT  /  IF  /  FOR  /  FLOAT  /  FINAL  /  ENUM  /  ELSE  /  DOUBLE  /  DO  /  DEFAULT  /  CONTINUE  /  CLASS  /  CHAR  /  CASE  /  BYTE  /  BREAK  /  BOOLEAN  /  ASSERT  /  ABSTRACT  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') %{Err_093} .)?)^Err_094
catchClause     <-  CATCH '('^Err_095 catchFormalParameter^Err_096 ')'^Err_097 block^Err_098
catchFormalParameter <-  (variableModifier  /  !Identifier %{Err_099} .)* catchType^Err_100 variableDeclaratorId^Err_101
catchType       <-  unannClassType^Err_102 ('|' ![=|] classType^Err_103  /  !Identifier %{Err_104} .)*
finally         <-  FINALLY block^Err_105
resourceSpecification <-  '('^Err_106 resourceList^Err_107 (';'  /  !')' %{Err_108} .)? ')'^Err_109
resourceList    <-  resource^Err_110 (';' resource  /  !(';'  /  ')') %{Err_111} .)*
resource        <-  variableModifier* unannType variableDeclaratorId '=' !'=' expression
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  THIS  /  Literal  /  parExpression  /  SUPER ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  NEW (classCreator  /  arrayCreator)  /  qualIdent ('[' expression ']'  /  arguments  /  '.' (THIS  /  NEW classCreator  /  typeArguments Identifier arguments  /  SUPER '.' typeArguments? Identifier arguments  /  SUPER '.' Identifier^Err_112  /  SUPER '::' (typeArguments  /  !Identifier %{Err_113} .)? Identifier^Err_114 arguments^Err_115)  /  ('[' ']')* '.' CLASS  /  '::' typeArguments? Identifier)  /  VOID '.' CLASS^Err_116  /  basicType ('[' ']')* '.' CLASS  /  referenceType '::' typeArguments? NEW  /  arrayType '::' NEW
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
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_117  /  '!' ![=&] unaryExpression^Err_118  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression^Err_119  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (infixOperator unaryExpression  /  INSTANCEOF referenceType^Err_120)*
infixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('?' expression ':' expression)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_121
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_122
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block^Err_123)^Err_124
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

--util.testNo(dir .. '/test/no/', 'java', p)

util.testNoRec(dir .. '/test/no/', 'java', p)

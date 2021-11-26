Unique Path (UPath)
Uunique
assert	 = 	1
while	 = 	2
stictfp	 = 	1
do	 = 	1
import	 = 	1
throws	 = 	1
~	 = 	1
finally	 = 	1
query	 = 	1
enum	 = 	1
void	 = 	2
|	 = 	1
}	 = 	9
{	 = 	9
long	 = 	1
--	 = 	4
throw	 = 	1
extends	 = 	4
default	 = 	3
int	 = 	1
double	 = 	1
static	 = 	8
switch	 = 	1
]	 = 	6
[	 = 	6
.	 = 	18
break	 = 	1
boolean	 = 	1
return	 = 	1
(	 = 	16
)	 = 	16
this	 = 	4
final	 = 	5
-	 = 	1
*	 = 	1
+	 = 	1
@	 = 	2
char	 = 	1
>	 = 	3
?	 = 	1
instanceof	 = 	1
transient	 = 	1
->	 = 	1
continue	 = 	1
InfixOperator	 = 	1
!	 = 	1
<	 = 	3
=	 = 	3
:	 = 	6
;	 = 	28
new	 = 	5
Literal	 = 	1
::	 = 	6
float	 = 	1
catch	 = 	1
try	 = 	1
for	 = 	2
private	 = 	5
native	 = 	1
...	 = 	1
++	 = 	4
case	 = 	1
interface	 = 	2
SKIP	 = 	1
package	 = 	1
short	 = 	1
abstract	 = 	5
byte	 = 	1
,	 = 	17
Identifier	 = 	41
else	 = 	1
protected	 = 	5
volatile	 = 	1
AssignmentOperator	 = 	1
class	 = 	4
super	 = 	8
if	 = 	1
strictfp	 = 	3
implements	 = 	1
synchronized	 = 	2
public	 = 	8
and	 = 	1
Token 	1	 = 	46
Token 	2	 = 	6
Token 	3	 = 	5
Token 	4	 = 	5
Token 	5	 = 	5
Token 	6	 = 	4
Token 	7	 = 	nil
Token 	8	 = 	3
Token 	9	 = 	2
Token 	10	 = 	nil
Unique tokens (# 45): !, *, +, -, ->, ..., ?, AssignmentOperator, InfixOperator, Literal, and, assert, boolean, break, byte, case, catch, char, continue, do, double, else, enum, finally, float, if, implements, import, instanceof, int, long, native, package, query, return, short, stictfp, switch, throw, throws, transient, try, volatile, |, ~
calcTail
compilation: 	;, __SKIP, __empty, }
basicType: 	boolean, byte, char, double, float, int, long, short
primitiveType: 	boolean, byte, char, double, float, int, long, short
referenceType: 	>, ], __Identifier
classType: 	>, __Identifier
type: 	>, __Identifier, boolean, byte, char, double, float, int, long, short
arrayType: 	]
typeVariable: 	__Identifier
dim: 	]
typeParameter: 	>, __Identifier
typeParameterModifier: 	), __Identifier
typeBound: 	>, __Identifier
additionalBound: 	>, __Identifier
typeArguments: 	>
typeArgumentList: 	>, ?, ], __Identifier
typeArgument: 	>, ?, ], __Identifier
wildcard: 	>, ?, ], __Identifier
wildcardBounds: 	>, ], __Identifier
qualIdent: 	__Identifier
compilationUnit: 	;, __empty, }
packageDeclaration: 	;
packageModifier: 	), __Identifier
importDeclaration: 	;
typeDeclaration: 	;, }
classDeclaration: 	}
normalClassDeclaration: 	}
classModifier: 	), __Identifier, abstract, final, private, protected, public, static, strictfp
typeParameters: 	>
typeParameterList: 	>, __Identifier
superclass: 	>, __Identifier
superinterfaces: 	>, __Identifier
interfaceTypeList: 	>, __Identifier
classBody: 	}
classBodyDeclaration: 	;, }
classMemberDeclaration: 	;, }
fieldDeclaration: 	;
variableDeclaratorList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
variableDeclarator: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
variableDeclaratorId: 	], __Identifier
variableInitializer: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
unannClassType: 	>, __Identifier
unannType: 	>, ], __Identifier, boolean, byte, char, double, float, int, long, short
fieldModifier: 	), __Identifier, final, private, protected, public, static, transient, volatile
methodDeclaration: 	;, }
methodHeader: 	), >, ], __Identifier
methodDeclarator: 	), ]
formalParameterList: 	], __Identifier, this
formalParameter: 	], __Identifier
variableModifier: 	), __Identifier, final
receiverParameter: 	this
result: 	>, ], __Identifier, boolean, byte, char, double, float, int, long, short, void
methodModifier: 	), __Identifier, abstract, final, native, private, protected, public, static, stictfp, synchronized
throws: 	>, __Identifier
exceptionTypeList: 	>, __Identifier
exceptionType: 	>, __Identifier
methodBody: 	;, }
instanceInitializer: 	}
staticInitializer: 	}
constructorDeclaration: 	}
constructorDeclarator: 	)
constructorModifier: 	), __Identifier, private, protected, public
constructorBody: 	}
explicitConstructorInvocation: 	;
enumDeclaration: 	}
enumBody: 	}
enumConstantList: 	), __Identifier, }
enumConstant: 	), __Identifier, }
enumConstantModifier: 	), __Identifier
enumBodyDeclarations: 	;, }
interfaceDeclaration: 	}
normalInterfaceDeclaration: 	}
interfaceModifier: 	), __Identifier, abstract, private, protected, public, static, strictfp
extendsInterfaces: 	>, __Identifier
interfaceBody: 	}
interfaceMemberDeclaration: 	;, }
constantDeclaration: 	;
constantModifier: 	), __Identifier, final, public, static
interfaceMethodDeclaration: 	;, }
interfaceMethodModifier: 	), __Identifier, abstract, default, public, static, strictfp
annotationTypeDeclaration: 	}
annotationTypeBody: 	}
annotationTypeMemberDeclaration: 	;, }
annotationTypeElementDeclaration: 	;
annotationTypeElementModifier: 	), __Identifier, abstract, public
defaultValue: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
annotation: 	), __Identifier
normalAnnotation: 	)
elementValuePairList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
elementValuePair: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
elementValue: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
elementValueArrayInitializer: 	}
elementValueList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
markerAnnotation: 	__Identifier
singleElementAnnotation: 	)
arrayInitializer: 	}
variableInitializerList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
block: 	}
blockStatements: 	;, }
blockStatement: 	;, }
localVariableDeclarationStatement: 	;
localVariableDeclaration: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
statement: 	;, }
statementExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
switchBlock: 	}
switchBlockStatementGroup: 	;, }
switchLabels: 	:
switchLabel: 	:
enumConstantName: 	__Identifier
basicForStatement: 	;, }
forInit: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
forUpdate: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
statementExpressionList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
enhancedForStatement: 	;, }
tryStatement: 	}
catchClause: 	}
catchFormalParameter: 	], __Identifier
catchType: 	>, __Identifier
finally: 	}
resourceSpecification: 	)
resourceList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
resource: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
expression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
primary: 	), ], __Identifier, __Literal, class, new, this, }
primaryBase: 	), ], __Identifier, __Literal, class, new, this, }
primaryRest: 	), ], __Identifier, }
parExpression: 	)
classCreator: 	), }
classTypeWithDiamond: 	>, __Identifier
typeArgumentsOrDiamond: 	>
arrayCreator: 	], }
dimExpr: 	]
arguments: 	)
argumentList: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
unaryExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
unaryExpressionNotPlusMinus: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
castExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
infixExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
InfixOperator: 	!=, %, &, &&, *, +, -, /, <, <<, <=, ==, >, >=, >>, >>>, ^, |, ||
conditionalExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
assignmentExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
assignment: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
leftHandSide: 	), ], __Identifier, __Literal, class, new, this, }
AssignmentOperator: 	%=, &=, *=, +=, -=, /=, <<=, =, >>=, >>>=, ^=, |=
lambdaExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
lambdaParameters: 	), __Identifier
inferredFormalParameterList: 	__Identifier
lambdaBody: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
constantExpression: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
Identifier: 	$, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, _, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
Keywords: 	abstract, assert, boolean, break, byte, case, catch, char, class, const, continue, default, do, double, else, enum, extends, false, final, finally, float, for, goto, if, implements, import, instanceof, int, interface, long, native, new, null, package, private, protected, public, return, short, static, strictfp, super, switch, synchronized, this, throw, throws, transient, true, try, void, volatile, while
Literal: 	__BooleanLiteral, __CharLiteral, __FloatLiteral, __IntegerLiteral, __NullLiteral, __StringLiteral
IntegerLiteral: 	L, __BinaryNumeral, __DecimalNumeral, __HexNumeral, __OctalNumeral, l
DecimalNumeral: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
HexNumeral: 	__HexDigits
OctalNumeral: 	0, 1, 2, 3, 4, 5, 6, 7
BinaryNumeral: 	0, 1
FloatLiteral: 	__DecimalFloatingPointLiteral, __HexaDecimalFloatingPointLiteral
DecimalFloatingPointLiteral: 	., D, F, __Digits, __Exponent, d, f
Exponent: 	__Digits
HexaDecimalFloatingPointLiteral: 	D, F, __BinaryExponent, d, f
HexSignificand: 	., __HexDigits, __HexNumeral
HexDigits: 	__HexDigit
HexDigit: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, a, b, c, d, e, f
BinaryExponent: 	__Digits
Digits: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
BooleanLiteral: 	false, true
CharLiteral: 	'
StringLiteral: 	"
NullLiteral: 	null
COMMENT: 	*/, //, __any
SPACE: 		, 
, , , ,  , __COMMENT
SKIP: 		, 
, , , ,  , __COMMENT, __empty
Global Prefix
compilation: 	
basicType: 	!, (, ), +, ++, ,, -, --, ->, :, ;, <, =, >, [, __AssignmentOperator, __Identifier, __InfixOperator, abstract, assert, case, default, do, else, extends, final, instanceof, native, new, private, protected, public, query, return, static, stictfp, strictfp, super, synchronized, throw, transient, volatile, {, }, ~
primitiveType: 	!, (, ), +, ++, ,, -, --, ->, :, ;, <, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, extends, instanceof, new, query, return, super, throw, {, }, ~
referenceType: 	!, (, ), +, ++, ,, -, --, ->, :, ;, <, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, extends, instanceof, query, return, super, throw, {, }, ~
classType: 	!, (, ), +, ++, ,, -, --, ->, :, ;, <, =, [, __AssignmentOperator, __InfixOperator, and, assert, case, default, do, else, extends, implements, instanceof, new, query, return, super, throw, throws, {, |, }, ~
type: 	new
arrayType: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
typeVariable: 	,, extends, throws
dim: 	), >, ], __Identifier, boolean, byte, char, double, float, int, long, short
typeParameter: 	,, <
typeParameterModifier: 	), ,, <, __Identifier
typeBound: 	__Identifier
additionalBound: 	>, ], __Identifier
typeArguments: 	., ::, __Identifier, new, {
typeArgumentList: 	<
typeArgument: 	,, <
wildcard: 	,, <
wildcardBounds: 	?
qualIdent: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, @, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, import, query, return, static, throw, {, }, ~
compilationUnit: 	__SKIP
packageDeclaration: 	__SKIP
packageModifier: 	), __Identifier, __SKIP
importDeclaration: 	;, __SKIP
typeDeclaration: 	;, __SKIP, }
classDeclaration: 	:, ;, __SKIP, {, }
normalClassDeclaration: 	:, ;, __SKIP, {, }
classModifier: 	), :, ;, __Identifier, __SKIP, abstract, final, private, protected, public, static, strictfp, {, }
typeParameters: 	), ;, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }
typeParameterList: 	<
superclass: 	>, __Identifier
superinterfaces: 	>, __Identifier
interfaceTypeList: 	extends, implements
classBody: 	), >, __Identifier
classBodyDeclaration: 	;, {, }
classMemberDeclaration: 	;, {, }
fieldDeclaration: 	;, {, }
variableDeclaratorList: 	>, ], __Identifier, boolean, byte, char, double, float, int, long, short
variableDeclarator: 	,, >, ], __Identifier, boolean, byte, char, double, float, int, long, short
variableDeclaratorId: 	,, ..., >, ], __Identifier, boolean, byte, char, double, float, int, long, short
variableInitializer: 	,, =, {
unannClassType: 	(, ), ,, :, ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, transient, volatile, {, }
unannType: 	(, ), ,, :, ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, transient, volatile, {, }
fieldModifier: 	), ;, __Identifier, final, private, protected, public, static, transient, volatile, {, }
methodDeclaration: 	;, {, }
methodHeader: 	), ;, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }
methodDeclarator: 	>, ], __Identifier, boolean, byte, char, double, float, int, long, short, void
formalParameterList: 	(
formalParameter: 	(, ,
variableModifier: 	(, ), ,, :, ;, __Identifier, final, {, }
receiverParameter: 	(
result: 	), ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }
methodModifier: 	), ;, __Identifier, abstract, final, native, private, protected, public, static, stictfp, synchronized, {, }
throws: 	), ]
exceptionTypeList: 	throws
exceptionType: 	,, throws
methodBody: 	), >, ], __Identifier
instanceInitializer: 	;, {, }
staticInitializer: 	;, {, }
constructorDeclaration: 	;, {, }
constructorDeclarator: 	), ;, __Identifier, private, protected, public, {, }
constructorModifier: 	), ;, __Identifier, private, protected, public, {, }
constructorBody: 	), >, __Identifier
explicitConstructorInvocation: 	{
enumDeclaration: 	:, ;, __SKIP, {, }
enumBody: 	>, __Identifier
enumConstantList: 	{
enumConstant: 	,, {
enumConstantModifier: 	), ,, __Identifier, {
enumBodyDeclarations: 	), ,, __Identifier, {, }
interfaceDeclaration: 	;, __SKIP, {, }
normalInterfaceDeclaration: 	;, __SKIP, {, }
interfaceModifier: 	), ;, __Identifier, __SKIP, abstract, private, protected, public, static, strictfp, {, }
extendsInterfaces: 	>, __Identifier
interfaceBody: 	>, __Identifier
interfaceMemberDeclaration: 	;, {, }
constantDeclaration: 	;, {, }
constantModifier: 	), ;, __Identifier, final, public, static, {, }
interfaceMethodDeclaration: 	;, {, }
interfaceMethodModifier: 	), ;, __Identifier, abstract, default, public, static, strictfp, {, }
annotationTypeDeclaration: 	;, __SKIP, {, }
annotationTypeBody: 	__Identifier
annotationTypeMemberDeclaration: 	;, {, }
annotationTypeElementDeclaration: 	;, {, }
annotationTypeElementModifier: 	), ;, __Identifier, abstract, public, {, }
defaultValue: 	), ]
annotation: 	!, (, ), +, ++, ,, -, --, ->, ., :, ;, <, =, >, [, ], __AssignmentOperator, __Identifier, __InfixOperator, __SKIP, abstract, and, assert, boolean, byte, case, char, default, do, double, else, extends, final, float, implements, instanceof, int, long, native, new, private, protected, public, query, return, short, static, stictfp, strictfp, super, synchronized, throw, throws, transient, volatile, {, |, }, ~
normalAnnotation: 	@
elementValuePairList: 	(, ), ++, --, >, ], __Identifier, __Literal, class, new, this, }
elementValuePair: 	(, ), ++, ,, --, >, ], __Identifier, __Literal, class, new, this, }
elementValue: 	(, ,, =, default, {
elementValueArrayInitializer: 	(, ,, =, default, {
elementValueList: 	{
markerAnnotation: 	@
singleElementAnnotation: 	@
arrayInitializer: 	,, =, ], {
variableInitializerList: 	{
block: 	), ->, :, ;, >, ], __Identifier, do, else, finally, static, try, {, }
blockStatements: 	:, ;, {
blockStatement: 	:, ;, {, }
localVariableDeclarationStatement: 	:, ;, {, }
localVariableDeclaration: 	(, :, ;, {, }
statement: 	), :, ;, do, else, {, }
statementExpression: 	(, ), ,, :, ;, do, else, {, }
switchBlock: 	)
switchBlockStatementGroup: 	;, {, }
switchLabels: 	;, {, }
switchLabel: 	:, ;, {, }
enumConstantName: 	case
basicForStatement: 	), :, ;, do, else, {, }
forInit: 	(
forUpdate: 	;
statementExpressionList: 	(, ;
enhancedForStatement: 	), :, ;, do, else, {, }
tryStatement: 	), :, ;, do, else, {, }
catchClause: 	}
catchFormalParameter: 	(
catchType: 	(, ), __Identifier, final
finally: 	}
resourceSpecification: 	try
resourceList: 	(
resource: 	(, ,
expression: 	(, ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {
primary: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
primaryBase: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
primaryRest: 	), ], __Identifier, __Literal, class, new, this, }
parExpression: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, if, query, return, switch, synchronized, throw, while, {, }, ~
classCreator: 	new
classTypeWithDiamond: 	), >, __Identifier, new
typeArgumentsOrDiamond: 	__Identifier
arrayCreator: 	new
dimExpr: 	]
arguments: 	>, __Identifier, super, this
argumentList: 	(
unaryExpression: 	!, (, ), +, ,, -, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, query, return, throw, {, ~
unaryExpressionNotPlusMinus: 	!, (, ), +, ,, -, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, query, return, throw, {, ~
castExpression: 	!, (, ), +, ,, -, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, query, return, throw, {, ~
infixExpression: 	(, ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, default, query, return, throw, {
InfixOperator: 	), ++, --, >, ], __Identifier, __Literal, class, new, this, }
conditionalExpression: 	(, ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, default, query, return, throw, {
assignmentExpression: 	(, ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {
assignment: 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, do, else, query, return, throw, {, }
leftHandSide: 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, do, else, query, return, throw, {, }
AssignmentOperator: 	), ], __Identifier, __Literal, class, new, this, }
lambdaExpression: 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {
lambdaParameters: 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {
inferredFormalParameterList: 	(
lambdaBody: 	->
constantExpression: 	case
Identifier: 	!, (, ), +, ++, ,, -, --, ->, ., ..., :, ::, ;, <, =, >, @, [, ], __AssignmentOperator, __Identifier, __InfixOperator, __Literal, abstract, and, assert, boolean, break, byte, case, char, class, continue, default, do, double, else, enum, extends, final, float, implements, import, instanceof, int, interface, long, native, new, package, private, protected, public, query, return, short, static, stictfp, strictfp, super, synchronized, this, throw, throws, transient, void, volatile, {, |, }, ~
Keywords: 	
Literal: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
IntegerLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
DecimalNumeral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
HexNumeral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
OctalNumeral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
BinaryNumeral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
FloatLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
DecimalFloatingPointLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
Exponent: 	., __Digits
HexaDecimalFloatingPointLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
HexSignificand: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
HexDigits: 	., 0X, 0x
HexDigit: 	., 0X, 0x, _, __HexDigit
BinaryExponent: 	__HexSignificand
Digits: 	!, (, ), +, ++, ,, -, --, ->, ., :, ;, =, E, P, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, e, else, p, query, return, throw, {, }, ~
BooleanLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
CharLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
StringLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
NullLiteral: 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~
COMMENT: 		, 
, , , ,  , __COMMENT
SPACE: 	
SKIP: 	
foi true22
passou três	compilationUnit	compilation
passou três	primitiveType	type
foi true22
passou três	classType	additionalBound
passou três	wildcard	typeArgument
foi true22
passou três	wildcardBounds	wildcard
foi true22
foi true22
passou três	referenceType	wildcardBounds
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	interfaceTypeList	superinterfaces
foi true22
passou três	variableDeclaratorId	formalParameter
UniqueFlw	__void	rule = 	result	pref = 	), ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }	flw = 	__Identifier	nInt = 	1	nEq = 	0	pflw = 	nil
UniqueFlw	__synchronized	rule = 	methodModifier	pref = 	), ;, __Identifier, abstract, final, native, private, protected, public, static, stictfp, synchronized, {, }	flw = 	<, @, __Identifier, abstract, boolean, byte, char, double, final, float, int, long, native, private, protected, public, short, static, stictfp, synchronized, void	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
passou três	exceptionTypeList	throws
passou três	exceptionType	exceptionTypeList
passou três	block	staticInitializer
passou três	arguments	explicitConstructorInvocation
foi true22
foi true22
foi true22
foi true22
passou três	normalAnnotation	annotation
passou três	singleElementAnnotation	annotation
passou três	markerAnnotation	annotation
foi true22
passou três	parExpression	statement
foi true22
passou três	statement	statement
foi true22
passou três	statement	statement
passou três	tryStatement	statement
foi true22
passou três	parExpression	statement
passou três	parExpression	statement
foi true22
passou três	expression	statement
foi true22
passou três	expression	statement
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	expression	statement
foi true22
foi true22
passou três	block	tryStatement
passou três	resourceSpecification	tryStatement
foi true22
foi true22
foi true22
passou três	classType	catchType
foi true22
passou três	block	finally
foi true22
UniqueFlw	__this	rule = 	primaryBase	pref = 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~	flw = 	), ++, ,, --, ., :, ::, ;, [, ], __AssignmentOperator, __Identifier, __InfixOperator, instanceof, query, }	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
foi true22
passou três	typeArguments	classCreator
foi true22
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
foi true22
passou três	unaryExpression	infixExpression
foi true22
passou três	referenceType	infixExpression
foi true22
passou três	expression	conditionalExpression
foi true22
passou três	expression	assignment
foi true22
passou três	lambdaBody	lambdaExpression
UniqueFlw	Identifier	rule = 	lambdaParameters	pref = 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {	flw = 	->	nInt = 	17	nEq = 	3	pflw = 	nil
passou três	expression	lambdaBody
passou três	block	lambdaBody
unique var 	compilationUnit
Unique usage	compilationUnit
unique var 	classType
unique var 	wildcardBounds
Unique usage	wildcardBounds
unique var 	referenceType
unique var 	referenceType
unique var 	typeDeclaration
Unique usage	typeDeclaration
unique var 	qualIdent
unique var 	interfaceDeclaration
unique var 	typeParameters
unique var 	superclass
Unique usage	superclass
unique var 	superinterfaces
unique var 	classBody
unique var 	classType
unique var 	interfaceTypeList
unique var 	variableDeclaratorId
unique var 	exceptionTypeList
Unique usage	exceptionTypeList
unique var 	exceptionType
unique var 	exceptionType
Unique usage	exceptionType
unique var 	typeVariable
unique var 	superinterfaces
Unique usage	superinterfaces
unique var 	enumBody
Unique usage	enumBody
unique var 	enumConstantList
Unique usage	enumConstantList
unique var 	enumBodyDeclarations
Unique usage	enumBodyDeclarations
unique var 	enumConstant
unique var 	classBodyDeclaration
unique var 	typeParameters
unique var 	extendsInterfaces
Unique usage	extendsInterfaces
unique var 	interfaceBody
Unique usage	interfaceBody
unique var 	interfaceTypeList
Unique usage	interfaceTypeList
unique var 	interfaceMemberDeclaration
Unique usage	interfaceMemberDeclaration
unique var 	interfaceDeclaration
unique var 	annotationTypeBody
Unique usage	annotationTypeBody
unique var 	annotationTypeMemberDeclaration
Unique usage	annotationTypeMemberDeclaration
unique var 	interfaceDeclaration
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var 	parExpression
unique var 	switchBlock
Unique usage	switchBlock
unique var 	block
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	switchLabel
unique var 	enumConstantName
Unique usage	enumConstantName
unique var 	block
unique var 	catchClause
unique var 	resourceSpecification
Unique usage	resourceSpecification
unique var 	block
unique var 	catchClause
unique var 	finally
unique var 	catchFormalParameter
Unique usage	catchFormalParameter
unique var 	block
unique var 	variableModifier
unique var 	catchType
Unique usage	catchType
unique var 	variableDeclaratorId
unique var 	unannClassType
unique var 	classType
unique var 	block
unique var 	resourceList
Unique usage	resourceList
unique var 	resource
unique var 	resource
Unique usage	resource
unique var 	variableModifier
unique var 	unannType
unique var 	variableDeclaratorId
unique var 	expression
unique var 	arrayCreator
Unique usage	arrayCreator
unique var 	typeArguments
unique var 	arguments
unique var 	type
unique var 	dim
unique var 	arrayInitializer
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	referenceType
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	lambdaBody
Unique usage	lambdaBody
unique var 	expression
unique var 	block
foi true22
passou três	primitiveType	type
foi true22
passou três	classType	additionalBound
foi true22
foi true22
foi true22
passou três	referenceType	wildcardBounds
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	interfaceTypeList	superinterfaces
foi true22
passou três	variableDeclaratorId	formalParameter
UniqueFlw	__void	rule = 	result	pref = 	), ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }	flw = 	__Identifier	nInt = 	1	nEq = 	0	pflw = 	nil
UniqueFlw	__synchronized	rule = 	methodModifier	pref = 	), ;, __Identifier, abstract, final, native, private, protected, public, static, stictfp, synchronized, {, }	flw = 	<, @, __Identifier, abstract, boolean, byte, char, double, final, float, int, long, native, private, protected, public, short, static, stictfp, synchronized, void	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
passou três	block	staticInitializer
passou três	arguments	explicitConstructorInvocation
foi true22
foi true22
foi true22
foi true22
passou três	normalAnnotation	annotation
passou três	singleElementAnnotation	annotation
passou três	markerAnnotation	annotation
foi true22
passou três	parExpression	statement
foi true22
passou três	statement	statement
foi true22
passou três	statement	statement
foi true22
passou três	parExpression	statement
passou três	parExpression	statement
foi true22
passou três	expression	statement
foi true22
passou três	expression	statement
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	expression	statement
foi true22
foi true22
passou três	block	tryStatement
foi true22
foi true22
foi true22
passou três	classType	catchType
foi true22
passou três	block	finally
foi true22
UniqueFlw	__this	rule = 	primaryBase	pref = 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~	flw = 	), ++, ,, --, ., :, ::, ;, [, ], __AssignmentOperator, __Identifier, __InfixOperator, instanceof, query, }	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
foi true22
passou três	typeArguments	classCreator
foi true22
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
foi true22
passou três	unaryExpression	infixExpression
foi true22
passou três	referenceType	infixExpression
foi true22
passou três	expression	conditionalExpression
foi true22
passou três	expression	assignment
foi true22
UniqueFlw	Identifier	rule = 	lambdaParameters	pref = 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {	flw = 	->	nInt = 	17	nEq = 	3	pflw = 	nil
passou três	expression	lambdaBody
passou três	block	lambdaBody
unique var 	compilationUnit
Unique usage	compilationUnit
unique var 	classType
unique var2 	wildcard
unique var 	wildcardBounds
Unique usage	wildcardBounds
unique var 	referenceType
unique var 	referenceType
unique var2 	packageDeclaration
unique var 	typeDeclaration
Unique usage	typeDeclaration
unique var 	qualIdent
unique var 	interfaceDeclaration
unique var2 	normalClassDeclaration
unique var2 	enumDeclaration
unique var 	typeParameters
unique var 	superclass
Unique usage	superclass
unique var 	superinterfaces
Unique usage	superinterfaces
unique var 	classBody
unique var 	classType
unique var 	interfaceTypeList
Unique usage	interfaceTypeList
unique var 	classType
unique var 	classType
unique var2 	staticInitializer
unique var 	variableDeclaratorId
unique var 	exceptionTypeList
Unique usage	exceptionTypeList
unique var 	exceptionType
Unique usage	exceptionType
unique var 	exceptionType
Unique usage	exceptionType
unique var 	typeVariable
unique var 	superinterfaces
Unique usage	superinterfaces
unique var 	enumBody
Unique usage	enumBody
unique var 	enumConstantList
Unique usage	enumConstantList
unique var 	enumBodyDeclarations
Unique usage	enumBodyDeclarations
unique var 	enumConstant
unique var 	classBodyDeclaration
unique var2 	normalInterfaceDeclaration
unique var2 	annotationTypeDeclaration
unique var 	typeParameters
unique var 	extendsInterfaces
Unique usage	extendsInterfaces
unique var 	interfaceBody
Unique usage	interfaceBody
unique var 	interfaceTypeList
Unique usage	interfaceTypeList
unique var 	interfaceMemberDeclaration
Unique usage	interfaceMemberDeclaration
unique var 	interfaceDeclaration
unique var 	annotationTypeBody
Unique usage	annotationTypeBody
unique var 	annotationTypeMemberDeclaration
Unique usage	annotationTypeMemberDeclaration
unique var 	interfaceDeclaration
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var2 	tryStatement
unique var 	parExpression
unique var 	switchBlock
Unique usage	switchBlock
unique var 	block
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	switchLabel
unique var 	enumConstantName
Unique usage	enumConstantName
unique var 	block
unique var 	catchClause
Unique usage	catchClause
unique var 	resourceSpecification
Unique usage	resourceSpecification
unique var 	block
unique var 	catchClause
Unique usage	catchClause
unique var 	finally
Unique usage	finally
unique var 	catchFormalParameter
Unique usage	catchFormalParameter
unique var 	block
unique var 	variableModifier
unique var 	catchType
Unique usage	catchType
unique var 	variableDeclaratorId
unique var 	unannClassType
unique var 	classType
unique var 	block
unique var 	resourceList
Unique usage	resourceList
unique var 	resource
Unique usage	resource
unique var 	resource
Unique usage	resource
unique var 	variableModifier
unique var 	unannType
unique var 	variableDeclaratorId
unique var 	expression
unique var 	arrayCreator
Unique usage	arrayCreator
unique var 	typeArguments
unique var 	arguments
unique var 	type
unique var 	dim
unique var 	arrayInitializer
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	referenceType
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	lambdaBody
Unique usage	lambdaBody
unique var 	expression
unique var 	block
foi true22
passou três	primitiveType	type
foi true22
passou três	classType	additionalBound
foi true22
foi true22
foi true22
passou três	referenceType	wildcardBounds
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	interfaceTypeList	superinterfaces
foi true22
passou três	variableDeclaratorId	formalParameter
UniqueFlw	__void	rule = 	result	pref = 	), ;, >, __Identifier, abstract, default, final, native, private, protected, public, static, stictfp, strictfp, synchronized, {, }	flw = 	__Identifier	nInt = 	1	nEq = 	0	pflw = 	nil
UniqueFlw	__synchronized	rule = 	methodModifier	pref = 	), ;, __Identifier, abstract, final, native, private, protected, public, static, stictfp, synchronized, {, }	flw = 	<, @, __Identifier, abstract, boolean, byte, char, double, final, float, int, long, native, private, protected, public, short, static, stictfp, synchronized, void	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
passou três	block	staticInitializer
passou três	arguments	explicitConstructorInvocation
foi true22
foi true22
foi true22
foi true22
passou três	normalAnnotation	annotation
passou três	singleElementAnnotation	annotation
passou três	markerAnnotation	annotation
foi true22
passou três	parExpression	statement
foi true22
passou três	statement	statement
foi true22
passou três	statement	statement
foi true22
passou três	parExpression	statement
passou três	parExpression	statement
foi true22
passou três	expression	statement
foi true22
passou três	expression	statement
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	expression	statement
foi true22
foi true22
passou três	block	tryStatement
foi true22
foi true22
foi true22
passou três	classType	catchType
foi true22
passou três	block	finally
foi true22
UniqueFlw	__this	rule = 	primaryBase	pref = 	!, (, ), +, ++, ,, -, --, ->, :, ;, =, [, __AssignmentOperator, __InfixOperator, assert, case, default, do, else, query, return, throw, {, }, ~	flw = 	), ++, ,, --, ., :, ::, ;, [, ], __AssignmentOperator, __Identifier, __InfixOperator, instanceof, query, }	nInt = 	1	nEq = 	0	pflw = 	nil
foi true22
foi true22
passou três	typeArguments	classCreator
foi true22
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpression
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
passou três	unaryExpression	unaryExpressionNotPlusMinus
foi true22
foi true22
passou três	unaryExpression	infixExpression
foi true22
passou três	referenceType	infixExpression
foi true22
passou três	expression	conditionalExpression
foi true22
passou três	expression	assignment
foi true22
UniqueFlw	Identifier	rule = 	lambdaParameters	pref = 	(, ), ,, ->, :, ;, =, [, __AssignmentOperator, assert, case, query, return, throw, {	flw = 	->	nInt = 	17	nEq = 	3	pflw = 	nil
passou três	expression	lambdaBody
passou três	block	lambdaBody
unique var 	compilationUnit
Unique usage	compilationUnit
unique var 	classType
unique var2 	wildcard
unique var 	wildcardBounds
Unique usage	wildcardBounds
unique var 	referenceType
unique var 	referenceType
unique var2 	packageDeclaration
unique var 	typeDeclaration
Unique usage	typeDeclaration
unique var 	qualIdent
unique var 	interfaceDeclaration
unique var2 	normalClassDeclaration
unique var2 	enumDeclaration
unique var 	typeParameters
unique var 	superclass
Unique usage	superclass
unique var 	superinterfaces
Unique usage	superinterfaces
unique var 	classBody
unique var 	classType
unique var 	interfaceTypeList
Unique usage	interfaceTypeList
unique var 	classType
unique var 	classType
unique var2 	staticInitializer
unique var 	variableDeclaratorId
unique var 	exceptionTypeList
Unique usage	exceptionTypeList
unique var 	exceptionType
Unique usage	exceptionType
unique var 	exceptionType
Unique usage	exceptionType
unique var 	typeVariable
unique var 	superinterfaces
Unique usage	superinterfaces
unique var 	enumBody
Unique usage	enumBody
unique var 	enumConstantList
Unique usage	enumConstantList
unique var 	enumBodyDeclarations
Unique usage	enumBodyDeclarations
unique var 	enumConstant
unique var 	classBodyDeclaration
unique var2 	normalInterfaceDeclaration
unique var2 	annotationTypeDeclaration
unique var 	typeParameters
unique var 	extendsInterfaces
Unique usage	extendsInterfaces
unique var 	interfaceBody
Unique usage	interfaceBody
unique var 	interfaceTypeList
Unique usage	interfaceTypeList
unique var 	interfaceMemberDeclaration
Unique usage	interfaceMemberDeclaration
unique var 	interfaceDeclaration
unique var 	annotationTypeBody
Unique usage	annotationTypeBody
unique var 	annotationTypeMemberDeclaration
Unique usage	annotationTypeMemberDeclaration
unique var 	interfaceDeclaration
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var 	statement
unique var 	statement
unique var 	parExpression
unique var2 	tryStatement
unique var 	parExpression
unique var 	switchBlock
Unique usage	switchBlock
unique var 	block
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	switchLabel
unique var 	enumConstantName
Unique usage	enumConstantName
unique var 	block
unique var 	catchClause
Unique usage	catchClause
unique var 	resourceSpecification
Unique usage	resourceSpecification
unique var 	block
unique var 	catchClause
Unique usage	catchClause
unique var 	finally
Unique usage	finally
unique var 	catchFormalParameter
Unique usage	catchFormalParameter
unique var 	block
unique var 	variableModifier
unique var 	catchType
Unique usage	catchType
unique var 	variableDeclaratorId
unique var 	unannClassType
unique var 	classType
unique var 	block
unique var 	resourceList
Unique usage	resourceList
unique var 	resource
Unique usage	resource
unique var 	resource
Unique usage	resource
unique var 	variableModifier
unique var 	unannType
unique var 	variableDeclaratorId
unique var 	expression
unique var 	arrayCreator
Unique usage	arrayCreator
unique var 	typeArguments
unique var 	arguments
unique var 	type
unique var 	dim
unique var 	arrayInitializer
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	unaryExpression
unique var 	referenceType
unique var 	expression
unique var 	expression
unique var 	expression
unique var 	lambdaBody
Unique usage	lambdaBody
unique var 	expression
unique var 	block
insideLoop: basicType, primitiveType, referenceType, classType, arrayType, dim, typeParameterModifier, typeBound, additionalBound, typeArguments, wildcardBounds, qualIdent, packageDeclaration, packageModifier, importDeclaration, typeDeclaration, classDeclaration, normalClassDeclaration, classModifier, typeParameters, superclass, superinterfaces, classBody, classBodyDeclaration, classMemberDeclaration, fieldDeclaration, variableInitializer, unannClassType, unannType, fieldModifier, methodDeclaration, methodHeader, formalParameterList, formalParameter, variableModifier, receiverParameter, result, methodModifier, throws, instanceInitializer, staticInitializer, constructorDeclaration, constructorDeclarator, constructorModifier, explicitConstructorInvocation, enumDeclaration, enumConstantList, enumConstant, enumConstantModifier, enumBodyDeclarations, interfaceDeclaration, normalInterfaceDeclaration, interfaceModifier, extendsInterfaces, interfaceMemberDeclaration, constantDeclaration, constantModifier, interfaceMethodDeclaration, interfaceMethodModifier, annotationTypeDeclaration, annotationTypeMemberDeclaration, annotationTypeElementDeclaration, annotationTypeElementModifier, defaultValue, annotation, elementValuePairList, elementValuePair, elementValue, elementValueArrayInitializer, elementValueList, arrayInitializer, variableInitializerList, block, blockStatements, blockStatement, localVariableDeclarationStatement, localVariableDeclaration, statement, statementExpression, switchBlockStatementGroup, switchLabels, switchLabel, basicForStatement, forInit, forUpdate, statementExpressionList, enhancedForStatement, tryStatement, catchClause, finally, expression, primary, primaryBase, primaryRest, parExpression, typeArgumentsOrDiamond, dimExpr, arguments, argumentList, unaryExpression, unaryExpressionNotPlusMinus, castExpression, infixExpression, conditionalExpression, assignmentExpression, assignment, leftHandSide, lambdaExpression, lambdaParameters, 
Unique vars: compilation, wildcardBounds, compilationUnit, typeDeclaration, superclass, superinterfaces, interfaceTypeList, exceptionTypeList, exceptionType, enumBody, enumConstantList, enumBodyDeclarations, extendsInterfaces, interfaceBody, interfaceMemberDeclaration, annotationTypeBody, annotationTypeMemberDeclaration, switchBlock, enumConstantName, catchClause, catchFormalParameter, catchType, finally, resourceSpecification, resourceList, resource, arrayCreator, lambdaBody, 
matchUPath: compilation, basicType, additionalBound, wildcard, wildcardBounds, compilationUnit, packageDeclaration, typeDeclaration, classDeclaration, normalClassDeclaration, superclass, superinterfaces, interfaceTypeList, throws, exceptionTypeList, exceptionType, staticInitializer, enumDeclaration, enumBody, enumConstantList, enumBodyDeclarations, interfaceDeclaration, normalInterfaceDeclaration, extendsInterfaces, interfaceBody, interfaceMemberDeclaration, annotationTypeDeclaration, annotationTypeBody, annotationTypeMemberDeclaration, annotation, switchBlock, switchLabel, enumConstantName, tryStatement, catchClause, catchFormalParameter, catchType, finally, resourceSpecification, resourceList, resource, arrayCreator, assignment, lambdaExpression, lambdaBody, 
Adding labels: Err_1, Err_2, Err_3, Err_4, Err_5, Err_6, Err_7, Err_8, Err_9, Err_10, Err_11, Err_12, Err_13, Err_14, Err_15, Err_16, Err_17, Err_18, Err_19, Err_20, Err_21, Err_22, Err_23, Err_24, Err_25, Err_26, Err_27, Err_28, Err_29, Err_30, Err_31, Err_32, Err_33, Err_34, Err_35, Err_36, Err_37, Err_38, Err_39, Err_40, Err_41, Err_42, Err_43, Err_44, Err_45, Err_46, Err_47, Err_48, Err_49, Err_50, Err_51, Err_52, Err_53, Err_54, Err_55, Err_56, Err_57, Err_58, Err_59, Err_60, Err_61, Err_62, Err_63, Err_64, Err_65, Err_66, Err_67, Err_68, Err_69, Err_70, Err_71, Err_72, Err_73, Err_74, Err_75, Err_76, Err_77, Err_78, Err_79, Err_80, Err_81, Err_82, Err_83, Err_84, Err_85, Err_86, Err_87, Err_88, Err_89, Err_90, Err_91, Err_92, Err_93, Err_94, Err_95, Err_96, Err_97, Err_98, Err_99, Err_100, Err_101, Err_102, Err_103, Err_104, 

Property 	nil
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
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)
additionalBound <-  'and' classType^Err_001
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard
wildcard        <-  annotation* '?' wildcardBounds?
wildcardBounds  <-  'extends' referenceType^Err_002  /  'super' referenceType^Err_003
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration? importDeclaration* typeDeclaration*
packageDeclaration <-  packageModifier* 'package' Identifier^Err_004 ('.' Identifier^Err_005)* ';'^Err_006
packageModifier <-  annotation
importDeclaration <-  'import' 'static'? qualIdent^Err_007 ('.' '*'^Err_008)? ';'^Err_009  /  ';'
typeDeclaration <-  classDeclaration  /  interfaceDeclaration  /  ';'
classDeclaration <-  normalClassDeclaration  /  enumDeclaration
normalClassDeclaration <-  classModifier* 'class' Identifier^Err_010 typeParameters? superclass? superinterfaces? classBody^Err_011
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  'extends' classType^Err_012
superinterfaces <-  'implements' interfaceTypeList^Err_013
interfaceTypeList <-  classType^Err_014 (',' classType^Err_015)*
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
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  'transient'  /  'volatile'
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result methodDeclarator throws?
methodDeclarator <-  Identifier '(' formalParameterList? ')' dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...' variableDeclaratorId^Err_016 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  'native'  /  'stictfp'
throws          <-  'throws' exceptionTypeList^Err_017
exceptionTypeList <-  exceptionType^Err_018 (',' exceptionType^Err_019)*
exceptionType   <-  (classType  /  typeVariable)^Err_020
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? 'this' arguments ';'^Err_021  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum' Identifier^Err_022 superinterfaces? enumBody^Err_023
enumBody        <-  '{'^Err_024 enumConstantList? ','? enumBodyDeclarations? '}'^Err_025
enumConstantList <-  enumConstant (',' enumConstant)*
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';' classBodyDeclaration*
interfaceDeclaration <-  normalInterfaceDeclaration  /  annotationTypeDeclaration
normalInterfaceDeclaration <-  interfaceModifier* 'interface' Identifier^Err_026 typeParameters? extendsInterfaces? interfaceBody^Err_027
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends' interfaceTypeList^Err_028
interfaceBody   <-  '{'^Err_029 interfaceMemberDeclaration* '}'^Err_030
interfaceMemberDeclaration <-  constantDeclaration  /  interfaceMethodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface' Identifier^Err_031 annotationTypeBody^Err_032
annotationTypeBody <-  '{'^Err_033 annotationTypeMemberDeclaration* '}'^Err_034
annotationTypeMemberDeclaration <-  annotationTypeElementDeclaration  /  constantDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue
annotation      <-  '@' (normalAnnotation  /  singleElementAnnotation  /  markerAnnotation)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
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
statement       <-  block  /  'if' parExpression^Err_035 statement^Err_036 ('else' statement^Err_037)?  /  basicForStatement  /  enhancedForStatement  /  'while' parExpression^Err_038 statement^Err_039  /  'do' statement^Err_040 'while'^Err_041 parExpression^Err_042 ';'^Err_043  /  tryStatement  /  'switch' parExpression^Err_044 switchBlock^Err_045  /  'synchronized' parExpression block^Err_046  /  'return' expression? ';'^Err_047  /  'throw' expression^Err_048 ';'^Err_049  /  'break' Identifier? ';'^Err_050  /  'continue' Identifier? ';'^Err_051  /  'assert' expression^Err_052 (':' expression^Err_053)? ';'^Err_054  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'^Err_055 switchBlockStatementGroup* switchLabel* '}'^Err_056
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  'case' (constantExpression  /  enumConstantName)^Err_057 ':'^Err_058  /  'default' ':'
enumConstantName <-  Identifier^Err_059
basicForStatement <-  'for' '('^Err_060 forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  'for' '('^Err_061 variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try' (block (catchClause* finally  /  catchClause+)^Err_062  /  resourceSpecification block^Err_063 catchClause* finally?)^Err_064
catchClause     <-  'catch' '('^Err_065 catchFormalParameter^Err_066 ')'^Err_067 block^Err_068
catchFormalParameter <-  variableModifier* catchType^Err_069 variableDeclaratorId^Err_070
catchType       <-  unannClassType^Err_071 ('|' ![=|] classType^Err_072)*
finally         <-  'finally' block^Err_073
resourceSpecification <-  '('^Err_074 resourceList^Err_075 ';'? ')'^Err_076
resourceList    <-  resource^Err_077 (',' resource^Err_078)*
resource        <-  variableModifier* unannType^Err_079 variableDeclaratorId^Err_080 '='^Err_081 !'=' expression^Err_082
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal  /  parExpression  /  'super' ('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)  /  'new' (classCreator  /  arrayCreator)^Err_083  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator^Err_084  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::' typeArguments? Identifier^Err_085 arguments^Err_086)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.' 'class'^Err_087  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator^Err_088)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>' !'.'
arrayCreator    <-  (type dimExpr+ dim*  /  type dim+^Err_089 arrayInitializer^Err_090)^Err_091
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+' ![=+] unaryExpression^Err_092  /  '-' ![-=>] unaryExpression^Err_093  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~' unaryExpression^Err_094  /  '!' ![=&] unaryExpression^Err_095  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')' unaryExpression^Err_096  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression (InfixOperator unaryExpression^Err_097  /  'instanceof' referenceType^Err_098)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query' expression^Err_099 ':'^Err_100 expression^Err_101)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator expression^Err_102
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->' lambdaBody^Err_103
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  (expression  /  block)^Err_104
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  ('abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected'  /  'public'  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while') ![a-zA-Z_$0-9]
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
COMMENT         <-  '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~'  /  '}'  /  '{'  /  'stictfp'  /  'query'  /  'and'  /  StringLiteral  /  OctalNumeral  /  NullLiteral  /  Literal  /  Keywords  /  IntegerLiteral  /  InfixOperator  /  Identifier  /  HexaDecimalFloatingPointLiteral  /  HexSignificand  /  HexNumeral  /  HexDigits  /  HexDigit  /  FloatLiteral  /  Exponent  /  Digits  /  DecimalNumeral  /  DecimalFloatingPointLiteral  /  CharLiteral  /  COMMENT  /  BooleanLiteral  /  BinaryNumeral  /  BinaryExponent  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '?'  /  ';'  /  '::'  /  ':'  /  '...'  /  '->'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_002         <-  (!('>'  /  ',') EatToken)*
Err_003         <-  (!('>'  /  ',') EatToken)*
Err_004         <-  (!(';'  /  '.') EatToken)*
Err_005         <-  (!(';'  /  '.') EatToken)*
Err_006         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_007         <-  (!(';'  /  '.') EatToken)*
Err_008         <-  (!';' EatToken)*
Err_009         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_010         <-  (!('{'  /  'implements'  /  'extends'  /  '<') EatToken)*
Err_011         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_012         <-  (!('{'  /  'implements') EatToken)*
Err_013         <-  (!'{' EatToken)*
Err_014         <-  (!('{'  /  ',') EatToken)*
Err_015         <-  (!('{'  /  ',') EatToken)*
Err_016         <-  (!(','  /  ')') EatToken)*
Err_017         <-  (!('{'  /  ';') EatToken)*
Err_018         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_019         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_020         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_021         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'continue'  /  'class'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_022         <-  (!('{'  /  'implements') EatToken)*
Err_023         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_024         <-  (!('}'  /  Identifier  /  '@'  /  ';'  /  ',') EatToken)*
Err_025         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_026         <-  (!('{'  /  'extends'  /  '<') EatToken)*
Err_027         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_028         <-  (!'{' EatToken)*
Err_029         <-  (!('}'  /  'void'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_030         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_031         <-  (!'{' EatToken)*
Err_032         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_033         <-  (!('}'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  ';') EatToken)*
Err_034         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_035         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_036         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_037         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_038         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_039         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_040         <-  (!'while' EatToken)*
Err_041         <-  (!'(' EatToken)*
Err_042         <-  (!';' EatToken)*
Err_043         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_044         <-  (!'{' EatToken)*
Err_045         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_046         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_047         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_048         <-  (!';' EatToken)*
Err_049         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_050         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_051         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_052         <-  (!(';'  /  ':') EatToken)*
Err_053         <-  (!';' EatToken)*
Err_054         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_055         <-  (!('}'  /  'default'  /  'case') EatToken)*
Err_056         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_057         <-  (!':' EatToken)*
Err_058         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_059         <-  (!':' EatToken)*
Err_060         <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_061         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_062         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_063         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_064         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_065         <-  (!('final'  /  Identifier  /  '@') EatToken)*
Err_066         <-  (!')' EatToken)*
Err_067         <-  (!'{' EatToken)*
Err_068         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_069         <-  (!Identifier EatToken)*
Err_070         <-  (!')' EatToken)*
Err_071         <-  (!('|'  /  Identifier) EatToken)*
Err_072         <-  (!('|'  /  Identifier) EatToken)*
Err_073         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_074         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_075         <-  (!(';'  /  ')') EatToken)*
Err_076         <-  (!'{' EatToken)*
Err_077         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_078         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_079         <-  (!Identifier EatToken)*
Err_080         <-  (!'=' EatToken)*
Err_081         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_082         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_083         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_084         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_085         <-  (!'(' EatToken)*
Err_086         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_087         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_088         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_089         <-  (!('{'  /  '['  /  '@') EatToken)*
Err_090         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_091         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_092         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_093         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_094         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_095         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_096         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_097         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_098         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_099         <-  (!':' EatToken)*
Err_100         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_101         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_102         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_103         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_104         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*	

Property 	unique
compilation     <-  SKIP_unique compilationUnit_unique !.
basicType       <-  ('byte'_unique  /  ('short'_unique  /  ('int'_unique  /  ('long'_unique  /  ('char'_unique  /  ('float'_unique  /  ('double'_unique  /  'boolean'_unique)_unique)_unique)_unique)_unique)_unique)_unique)_unique
primitiveType   <-  annotation* basicType
referenceType   <-  primitiveType dim+  /  classType dim*
classType       <-  annotation* Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
type            <-  primitiveType_unique  /  classType
arrayType       <-  primitiveType dim+  /  classType dim+
typeVariable    <-  annotation* Identifier
dim             <-  annotation* '[' ']'
typeParameter   <-  typeParameterModifier* Identifier typeBound?
typeParameterModifier <-  annotation
typeBound       <-  'extends' (classType additionalBound*  /  typeVariable)
additionalBound <-  'and'_unique classType_unique^Err_001
typeArguments   <-  '<' typeArgumentList '>'
typeArgumentList <-  typeArgument (',' typeArgument)*
typeArgument    <-  referenceType  /  wildcard_unique
wildcard        <-  annotation* '?'_unique wildcardBounds_unique?_unique
wildcardBounds  <-  ('extends'_unique referenceType_unique^Err_002  /  'super'_unique referenceType_unique^Err_003)_unique
qualIdent       <-  Identifier ('.' Identifier)*
compilationUnit <-  packageDeclaration_unique?_unique importDeclaration*_unique typeDeclaration_unique*_unique
packageDeclaration <-  packageModifier* 'package'_unique Identifier_unique^Err_004 ('.'_unique Identifier_unique^Err_005)*_unique ';'_unique^Err_006
packageModifier <-  annotation
importDeclaration <-  'import'_unique 'static'_unique?_unique qualIdent_unique^Err_007 ('.'_unique '*'_unique^Err_008)?_unique ';'_unique^Err_009  /  ';'
typeDeclaration <-  (classDeclaration  /  (interfaceDeclaration_unique  /  ';'_unique)_unique)_unique
classDeclaration <-  (normalClassDeclaration_unique  /  enumDeclaration_unique)_unique
normalClassDeclaration <-  classModifier* 'class'_unique Identifier_unique^Err_010 typeParameters_unique?_unique superclass_unique?_unique superinterfaces_unique?_unique classBody_unique^Err_011
classModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'strictfp'
typeParameters  <-  '<' typeParameterList '>'
typeParameterList <-  typeParameter (',' typeParameter)*
superclass      <-  'extends'_unique classType_unique^Err_012
superinterfaces <-  'implements'_unique interfaceTypeList_unique^Err_013
interfaceTypeList <-  classType_unique^Err_014 (','_unique classType_unique^Err_015)*_unique
classBody       <-  '{' classBodyDeclaration* '}'
classBodyDeclaration <-  classMemberDeclaration  /  instanceInitializer  /  staticInitializer_unique  /  constructorDeclaration
classMemberDeclaration <-  fieldDeclaration  /  methodDeclaration  /  classDeclaration  /  interfaceDeclaration  /  ';'
fieldDeclaration <-  fieldModifier* unannType variableDeclaratorList ';'
variableDeclaratorList <-  variableDeclarator (',' variableDeclarator)*
variableDeclarator <-  variableDeclaratorId ('=' !'=' variableInitializer)?
variableDeclaratorId <-  Identifier dim*
variableInitializer <-  expression  /  arrayInitializer
unannClassType  <-  Identifier typeArguments? ('.' annotation* Identifier typeArguments?)*
unannType       <-  basicType dim*  /  unannClassType dim*
fieldModifier   <-  annotation  /  'public'  /  'protected'  /  'private'  /  'static'  /  'final'  /  ('transient'_unique  /  'volatile'_unique)_unique
methodDeclaration <-  methodModifier* methodHeader methodBody
methodHeader    <-  result methodDeclarator throws?  /  typeParameters annotation* result methodDeclarator throws?
methodDeclarator <-  Identifier '(' formalParameterList? ')' dim*
formalParameterList <-  (receiverParameter  /  formalParameter) (',' formalParameter)*
formalParameter <-  variableModifier* unannType variableDeclaratorId  /  variableModifier* unannType annotation* '...'_unique variableDeclaratorId_unique^Err_016 !','
variableModifier <-  annotation  /  'final'
receiverParameter <-  variableModifier* unannType (Identifier '.')? 'this'
result          <-  unannType  /  'void'
methodModifier  <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'final'  /  'synchronized'  /  ('native'_unique  /  'stictfp'_unique)_unique
throws          <-  'throws'_unique exceptionTypeList_unique^Err_017
exceptionTypeList <-  exceptionType_unique^Err_018 (','_unique exceptionType_unique^Err_019)*_unique
exceptionType   <-  ((classType  /  typeVariable_unique)_unique)^Err_020
methodBody      <-  block  /  ';'
instanceInitializer <-  block
staticInitializer <-  'static' block_unique
constructorDeclaration <-  constructorModifier* constructorDeclarator throws? constructorBody
constructorDeclarator <-  typeParameters? Identifier '(' formalParameterList? ')'
constructorModifier <-  annotation  /  'public'  /  'protected'  /  'private'
constructorBody <-  '{' explicitConstructorInvocation? blockStatements? '}'
explicitConstructorInvocation <-  typeArguments? 'this' arguments_unique ';'_unique^Err_021  /  typeArguments? 'super' arguments ';'  /  primary '.' typeArguments? 'super' arguments ';'  /  qualIdent '.' typeArguments? 'super' arguments ';'
enumDeclaration <-  classModifier* 'enum'_unique Identifier_unique^Err_022 superinterfaces_unique?_unique enumBody_unique^Err_023
enumBody        <-  '{'_unique^Err_024 enumConstantList_unique?_unique ','_unique?_unique enumBodyDeclarations_unique?_unique '}'_unique^Err_025
enumConstantList <-  enumConstant_unique (',' enumConstant)*_unique
enumConstant    <-  enumConstantModifier* Identifier arguments? classBody?
enumConstantModifier <-  annotation
enumBodyDeclarations <-  ';'_unique classBodyDeclaration_unique*_unique
interfaceDeclaration <-  (normalInterfaceDeclaration_unique  /  annotationTypeDeclaration_unique)_unique
normalInterfaceDeclaration <-  interfaceModifier* 'interface'_unique Identifier_unique^Err_026 typeParameters_unique?_unique extendsInterfaces_unique?_unique interfaceBody_unique^Err_027
interfaceModifier <-  annotation  /  'public'  /  'protected'  /  'private'  /  'abstract'  /  'static'  /  'strictfp'
extendsInterfaces <-  'extends'_unique interfaceTypeList_unique^Err_028
interfaceBody   <-  '{'_unique^Err_029 interfaceMemberDeclaration_unique*_unique '}'_unique^Err_030
interfaceMemberDeclaration <-  (constantDeclaration  /  (interfaceMethodDeclaration  /  (classDeclaration  /  (interfaceDeclaration_unique  /  ';'_unique)_unique)_unique)_unique)_unique
constantDeclaration <-  constantModifier* unannType variableDeclaratorList ';'
constantModifier <-  annotation  /  'public'  /  'static'  /  'final'
interfaceMethodDeclaration <-  interfaceMethodModifier* methodHeader methodBody
interfaceMethodModifier <-  annotation  /  'public'  /  'abstract'  /  'default'  /  'static'  /  'strictfp'
annotationTypeDeclaration <-  interfaceModifier* '@' 'interface'_unique Identifier_unique^Err_031 annotationTypeBody_unique^Err_032
annotationTypeBody <-  '{'_unique^Err_033 annotationTypeMemberDeclaration_unique*_unique '}'_unique^Err_034
annotationTypeMemberDeclaration <-  (annotationTypeElementDeclaration  /  (constantDeclaration  /  (classDeclaration  /  (interfaceDeclaration_unique  /  ';'_unique)_unique)_unique)_unique)_unique
annotationTypeElementDeclaration <-  annotationTypeElementModifier* unannType Identifier '(' ')' dim* defaultValue? ';'
annotationTypeElementModifier <-  annotation  /  'public'  /  'abstract'
defaultValue    <-  'default' elementValue
annotation      <-  '@' ((normalAnnotation_unique  /  (singleElementAnnotation_unique  /  markerAnnotation_unique)_unique)_unique)
normalAnnotation <-  qualIdent '(' elementValuePairList* ')'
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
statement       <-  block  /  'if'_unique parExpression_unique^Err_035 statement_unique^Err_036 ('else'_unique statement_unique^Err_037)?_unique  /  basicForStatement  /  enhancedForStatement  /  'while'_unique parExpression_unique^Err_038 statement_unique^Err_039  /  'do'_unique statement_unique^Err_040 'while'_unique^Err_041 parExpression_unique^Err_042 ';'_unique^Err_043  /  tryStatement_unique  /  'switch'_unique parExpression_unique^Err_044 switchBlock_unique^Err_045  /  'synchronized' parExpression_unique block_unique^Err_046  /  'return'_unique expression_unique?_unique ';'_unique^Err_047  /  'throw'_unique expression_unique^Err_048 ';'_unique^Err_049  /  'break'_unique Identifier_unique?_unique ';'_unique^Err_050  /  'continue'_unique Identifier_unique?_unique ';'_unique^Err_051  /  'assert'_unique expression_unique^Err_052 (':'_unique expression_unique^Err_053)?_unique ';'_unique^Err_054  /  ';'  /  statementExpression ';'  /  Identifier ':' statement
statementExpression <-  assignment  /  ('++'  /  '--') (primary  /  qualIdent)  /  (primary  /  qualIdent) ('++'  /  '--')  /  primary
switchBlock     <-  '{'_unique^Err_055 switchBlockStatementGroup*_unique switchLabel_unique*_unique '}'_unique^Err_056
switchBlockStatementGroup <-  switchLabels blockStatements
switchLabels    <-  switchLabel switchLabel*
switchLabel     <-  ('case'_unique ((constantExpression  /  enumConstantName_unique)_unique)^Err_057 ':'_unique^Err_058  /  'default' ':'_unique)_unique
enumConstantName <-  Identifier_unique^Err_059
basicForStatement <-  'for' '('^Err_060 forInit? ';' expression? ';' forUpdate? ')' statement
forInit         <-  localVariableDeclaration  /  statementExpressionList
forUpdate       <-  statementExpressionList
statementExpressionList <-  statementExpression (',' statementExpression)*
enhancedForStatement <-  'for' '('^Err_061 variableModifier* unannType variableDeclaratorId ':' expression ')' statement
tryStatement    <-  'try'_unique ((block_unique ((catchClause_unique* finally_unique  /  catchClause_unique+_unique)_unique)^Err_062  /  resourceSpecification_unique block_unique^Err_063 catchClause_unique*_unique finally_unique?_unique)_unique)^Err_064
catchClause     <-  'catch'_unique '('_unique^Err_065 catchFormalParameter_unique^Err_066 ')'_unique^Err_067 block_unique^Err_068
catchFormalParameter <-  variableModifier_unique*_unique catchType_unique^Err_069 variableDeclaratorId_unique^Err_070
catchType       <-  unannClassType_unique^Err_071 ('|'_unique ![=|] classType_unique^Err_072)*_unique
finally         <-  'finally'_unique block_unique^Err_073
resourceSpecification <-  '('_unique^Err_074 resourceList_unique^Err_075 ';'_unique?_unique ')'_unique^Err_076
resourceList    <-  resource_unique^Err_077 (','_unique resource_unique^Err_078)*_unique
resource        <-  variableModifier_unique*_unique unannType_unique^Err_079 variableDeclaratorId_unique^Err_080 '='_unique^Err_081 !'=' expression_unique^Err_082
expression      <-  lambdaExpression  /  assignmentExpression
primary         <-  primaryBase primaryRest*
primaryBase     <-  'this'  /  Literal_unique  /  parExpression  /  'super' (('.' typeArguments? Identifier arguments  /  '.' Identifier  /  '::' typeArguments? Identifier)_unique)  /  'new'_unique ((classCreator  /  arrayCreator_unique)_unique)^Err_083  /  qualIdent ('[' expression ']'  /  arguments  /  '.' ('this'  /  'new' classCreator^Err_084  /  typeArguments Identifier arguments  /  'super' '.' typeArguments? Identifier arguments  /  'super' '.' Identifier  /  'super' '::'_unique typeArguments_unique?_unique Identifier_unique^Err_085 arguments_unique^Err_086)  /  ('[' ']')* '.' 'class'  /  '::' typeArguments? Identifier)  /  'void' '.'_unique 'class'_unique^Err_087  /  basicType ('[' ']')* '.' 'class'  /  referenceType '::' typeArguments? 'new'  /  arrayType '::' 'new'
primaryRest     <-  '.' (typeArguments? Identifier arguments  /  Identifier  /  'new' classCreator^Err_088)  /  '[' expression ']'  /  '::' typeArguments? Identifier
parExpression   <-  '(' expression ')'
classCreator    <-  typeArguments_unique? annotation* classTypeWithDiamond arguments classBody?
classTypeWithDiamond <-  annotation* Identifier typeArgumentsOrDiamond? ('.' annotation* Identifier typeArgumentsOrDiamond?)*
typeArgumentsOrDiamond <-  typeArguments  /  '<' '>'_unique !'.'
arrayCreator    <-  ((type dimExpr+ dim*  /  type_unique dim_unique+_unique^Err_089 arrayInitializer_unique^Err_090)_unique)^Err_091
dimExpr         <-  annotation* '[' expression ']'
arguments       <-  '(' argumentList? ')'
argumentList    <-  expression (',' expression)*
unaryExpression <-  ('++'  /  '--') (primary  /  qualIdent)  /  '+'_unique ![=+] unaryExpression_unique^Err_092  /  '-'_unique ![-=>] unaryExpression_unique^Err_093  /  unaryExpressionNotPlusMinus
unaryExpressionNotPlusMinus <-  '~'_unique unaryExpression_unique^Err_094  /  '!'_unique ![=&] unaryExpression_unique^Err_095  /  castExpression  /  (primary  /  qualIdent) ('++'  /  '--')?
castExpression  <-  '(' primitiveType ')'_unique unaryExpression_unique^Err_096  /  '(' referenceType additionalBound* ')' lambdaExpression  /  '(' referenceType additionalBound* ')' unaryExpressionNotPlusMinus
infixExpression <-  unaryExpression ((InfixOperator_unique unaryExpression_unique^Err_097  /  'instanceof'_unique referenceType_unique^Err_098)_unique)*
InfixOperator   <-  '||'  /  '&&'  /  '|' ![=|]  /  '^' ![=]  /  '&' ![=&]  /  '=='  /  '!='  /  '<' ![=<]  /  '>' ![=>]  /  '<='  /  '>='  /  '<<' ![=]  /  '>>' ![=>]  /  '>>>' ![=]  /  '+' ![=+]  /  '-' ![-=>]  /  '*' ![=]  /  '/' ![=]  /  '%' ![=]
conditionalExpression <-  infixExpression ('query'_unique expression_unique^Err_099 ':'_unique^Err_100 expression_unique^Err_101)*
assignmentExpression <-  assignment  /  conditionalExpression
assignment      <-  leftHandSide AssignmentOperator_unique expression_unique^Err_102
leftHandSide    <-  primary  /  qualIdent
AssignmentOperator <-  '=' ![=]  /  '*='  /  '/='  /  '%='  /  '+='  /  '-='  /  '<<='  /  '>>='  /  '>>>='  /  '&='  /  '^='  /  '|='
lambdaExpression <-  lambdaParameters '->'_unique lambdaBody_unique^Err_103
lambdaParameters <-  Identifier  /  '(' formalParameterList? ')'  /  '(' inferredFormalParameterList ')'
inferredFormalParameterList <-  Identifier (',' Identifier)*
lambdaBody      <-  ((expression_unique  /  block_unique)_unique)^Err_104
constantExpression <-  expression
Identifier      <-  !Keywords [a-zA-Z_] [a-zA-Z_$0-9]*
Keywords        <-  ('abstract'  /  'assert'  /  'boolean'  /  'break'  /  'byte'  /  'case'  /  'catch'  /  'char'  /  'class'  /  'const'  /  'continue'  /  'default'  /  'double'  /  'do'  /  'else'  /  'enum'  /  'extends'  /  'false'  /  'finally'  /  'final'  /  'float'  /  'for'  /  'goto'  /  'if'  /  'implements'  /  'import'  /  'interface'  /  'int'  /  'instanceof'  /  'long'  /  'native'  /  'new'  /  'null'  /  'package'  /  'private'  /  'protected'  /  'public'  /  'return'  /  'short'  /  'static'  /  'strictfp'  /  'super'  /  'switch'  /  'synchronized'  /  'this'  /  'throws'  /  'throw'  /  'transient'  /  'true'  /  'try'  /  'void'  /  'volatile'  /  'while') ![a-zA-Z_$0-9]
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
COMMENT         <-  '//' (!%nl .)*  /  '/*' (!'*/' .)* '*/'
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '~'  /  '}'  /  '{'  /  'stictfp'  /  'query'  /  'and'  /  StringLiteral  /  OctalNumeral  /  NullLiteral  /  Literal  /  Keywords  /  IntegerLiteral  /  InfixOperator  /  Identifier  /  HexaDecimalFloatingPointLiteral  /  HexSignificand  /  HexNumeral  /  HexDigits  /  HexDigit  /  FloatLiteral  /  Exponent  /  Digits  /  DecimalNumeral  /  DecimalFloatingPointLiteral  /  CharLiteral  /  COMMENT  /  BooleanLiteral  /  BinaryNumeral  /  BinaryExponent  /  AssignmentOperator  /  ']'  /  '['  /  '@'  /  '?'  /  ';'  /  '::'  /  ':'  /  '...'  /  '->'  /  '--'  /  ','  /  '++'  /  ')'  /  '('  /  '!'
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!('and'  /  '>'  /  ','  /  ')') EatToken)*
Err_002         <-  (!('>'  /  ',') EatToken)*
Err_003         <-  (!('>'  /  ',') EatToken)*
Err_004         <-  (!(';'  /  '.') EatToken)*
Err_005         <-  (!(';'  /  '.') EatToken)*
Err_006         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_007         <-  (!(';'  /  '.') EatToken)*
Err_008         <-  (!';' EatToken)*
Err_009         <-  (!('strictfp'  /  'static'  /  'public'  /  'protected'  /  'private'  /  'interface'  /  'import'  /  'final'  /  'enum'  /  'class'  /  'abstract'  /  '@'  /  ';'  /  !.) EatToken)*
Err_010         <-  (!('{'  /  'implements'  /  'extends'  /  '<') EatToken)*
Err_011         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_012         <-  (!('{'  /  'implements') EatToken)*
Err_013         <-  (!'{' EatToken)*
Err_014         <-  (!('{'  /  ',') EatToken)*
Err_015         <-  (!('{'  /  ',') EatToken)*
Err_016         <-  (!(','  /  ')') EatToken)*
Err_017         <-  (!('{'  /  ';') EatToken)*
Err_018         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_019         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_020         <-  (!('{'  /  ';'  /  ',') EatToken)*
Err_021         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'continue'  /  'class'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_022         <-  (!('{'  /  'implements') EatToken)*
Err_023         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_024         <-  (!('}'  /  Identifier  /  '@'  /  ';'  /  ',') EatToken)*
Err_025         <-  (!('}'  /  '{'  /  'while'  /  'volatile'  /  'void'  /  'try'  /  'transient'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  '<'  /  ';'  /  '--'  /  '++'  /  '('  /  !.) EatToken)*
Err_026         <-  (!('{'  /  'extends'  /  '<') EatToken)*
Err_027         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_028         <-  (!'{' EatToken)*
Err_029         <-  (!('}'  /  'void'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';') EatToken)*
Err_030         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_031         <-  (!'{' EatToken)*
Err_032         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_033         <-  (!('}'  /  'strictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  ';') EatToken)*
Err_034         <-  (!('}'  /  '{'  /  'volatile'  /  'void'  /  'transient'  /  'synchronized'  /  'strictfp'  /  'stictfp'  /  'static'  /  'short'  /  'public'  /  'protected'  /  'private'  /  'native'  /  'long'  /  'interface'  /  'int'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'default'  /  'class'  /  'char'  /  'byte'  /  'boolean'  /  'abstract'  /  Identifier  /  '@'  /  '<'  /  ';'  /  !.) EatToken)*
Err_035         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_036         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_037         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_038         <-  (!('{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'short'  /  'return'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'double'  /  'do'  /  'continue'  /  'char'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_039         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_040         <-  (!'while' EatToken)*
Err_041         <-  (!'(' EatToken)*
Err_042         <-  (!';' EatToken)*
Err_043         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_044         <-  (!'{' EatToken)*
Err_045         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_046         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_047         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_048         <-  (!';' EatToken)*
Err_049         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_050         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_051         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_052         <-  (!(';'  /  ':') EatToken)*
Err_053         <-  (!';' EatToken)*
Err_054         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_055         <-  (!('}'  /  'default'  /  'case') EatToken)*
Err_056         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_057         <-  (!':' EatToken)*
Err_058         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_059         <-  (!':' EatToken)*
Err_060         <-  (!('void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_061         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_062         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_063         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_064         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_065         <-  (!('final'  /  Identifier  /  '@') EatToken)*
Err_066         <-  (!')' EatToken)*
Err_067         <-  (!'{' EatToken)*
Err_068         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'finally'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'catch'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_069         <-  (!Identifier EatToken)*
Err_070         <-  (!')' EatToken)*
Err_071         <-  (!('|'  /  Identifier) EatToken)*
Err_072         <-  (!('|'  /  Identifier) EatToken)*
Err_073         <-  (!('}'  /  '{'  /  'while'  /  'void'  /  'try'  /  'throw'  /  'this'  /  'synchronized'  /  'switch'  /  'super'  /  'strictfp'  /  'static'  /  'short'  /  'return'  /  'public'  /  'protected'  /  'private'  /  'new'  /  'long'  /  'int'  /  'if'  /  'for'  /  'float'  /  'final'  /  'enum'  /  'else'  /  'double'  /  'do'  /  'default'  /  'continue'  /  'class'  /  'char'  /  'case'  /  'byte'  /  'break'  /  'boolean'  /  'assert'  /  'abstract'  /  Literal  /  Identifier  /  '@'  /  ';'  /  '--'  /  '++'  /  '(') EatToken)*
Err_074         <-  (!('short'  /  'long'  /  'int'  /  'float'  /  'final'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Identifier  /  '@') EatToken)*
Err_075         <-  (!(';'  /  ')') EatToken)*
Err_076         <-  (!'{' EatToken)*
Err_077         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_078         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_079         <-  (!Identifier EatToken)*
Err_080         <-  (!'=' EatToken)*
Err_081         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_082         <-  (!(';'  /  ','  /  ')') EatToken)*
Err_083         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_084         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_085         <-  (!'(' EatToken)*
Err_086         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_087         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_088         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_089         <-  (!('{'  /  '['  /  '@') EatToken)*
Err_090         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_091         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  AssignmentOperator  /  ']'  /  '['  /  ';'  /  '::'  /  ':'  /  '.'  /  '--'  /  ','  /  '++'  /  ')') EatToken)*
Err_092         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_093         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_094         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_095         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_096         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_097         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_098         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_099         <-  (!':' EatToken)*
Err_100         <-  (!('~'  /  'void'  /  'this'  /  'super'  /  'short'  /  'new'  /  'long'  /  'int'  /  'float'  /  'double'  /  'char'  /  'byte'  /  'boolean'  /  Literal  /  Identifier  /  '@'  /  '--'  /  '-'  /  '++'  /  '+'  /  '('  /  '!') EatToken)*
Err_101         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_102         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_103         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*
Err_104         <-  (!('}'  /  'query'  /  'instanceof'  /  InfixOperator  /  Identifier  /  ']'  /  ';'  /  ':'  /  ','  /  ')') EatToken)*	

End UPath

Yes: 	AllTests.java
Yes: 	Aluno.java
Yes: 	AnInterface.java
Yes: 	Anotacao.java
Yes: 	ArgumentsErr4.java
Yes: 	ArrayAverage.java
Yes: 	BlockStatementsErr.java
Yes: 	Car.java
Yes: 	Currency.java
Yes: 	DAOAtividade.java
Yes: 	Disciplina.java
Yes: 	ElementValueErr3.java
Yes: 	Empty.java
Yes: 	EqAvaliableErr2.java
Yes: 	Expression.java
Yes: 	HelloWorld.java
Yes: 	IssueController.java
Yes: 	JsonField.java
Yes: 	JsonSerializer.java
Yes: 	LambdaExpressions.java
Yes: 	MultithreadingDemo.java
Yes: 	MyTestRunner.java
Yes: 	MyTests.java
Yes: 	Pessoa.java
Yes: 	Pilha.java
Yes: 	Singleton.java
Yes: 	SortMain.java
Yes: 	Tester.java
Yes: 	UnaryExpressionNotPlusMinusErr.java
Yes: 	Veiculo.java
No: 	AfterBlockErr.java
r = nil lab = fail line: 6 col: 7
No: 	AfterIteratorSymbolErr.java
r = nil lab = fail line: 3 col: 6
No: 	AfterNewErr.java
r = nil lab = fail line: 3 col: 26
No: 	AfterSuperErr.java
r = nil lab = fail line: 3 col: 18
No: 	AfterTryErr.java
r = nil lab = fail line: 3 col: 7
No: 	AnnotationTypeBodyErr.java
r = nil lab = fail line: 2 col: 2
No: 	ArgumentsErr1.java
r = nil lab = fail line: 3 col: 13
No: 	ArgumentsErr2.java
r = nil lab = fail line: 3 col: 10
No: 	ArgumentsErr3.java
r = nil lab = fail line: 3 col: 16
No: 	ArgumentsErr5.java
r = nil lab = fail line: 3 col: 20
No: 	ArrayInitializerErr.java
r = nil lab = fail line: 3 col: 30
No: 	AsteriskErr.java
r = nil lab = fail line: 1 col: 13
No: 	BlockErr1.java
r = nil lab = fail line: 2 col: 9
No: 	BlockErr2.java
r = nil lab = fail line: 4 col: 4
No: 	BlockErr3.java
r = nil lab = fail line: 4 col: 4
No: 	BlockErr4.java
r = nil lab = fail line: 6 col: 23
No: 	BlockErr5.java
r = nil lab = fail line: 7 col: 11
No: 	CLASSErr1.java
r = nil lab = fail line: 3 col: 18
No: 	CLASSErr2.java
r = nil lab = fail line: 3 col: 19
No: 	CaseExpressionErr.java
r = nil lab = fail line: 4 col: 10
No: 	CatchFormalParameterErr.java
r = nil lab = fail line: 6 col: 10
No: 	ClassBodyErr.java
r = nil lab = fail line: 2 col: 2
No: 	ClassCreatorErr1.java
r = nil lab = fail line: 3 col: 19
No: 	ClassCreatorErr2.java
r = nil lab = fail line: 3 col: 24
No: 	ClassTypeErr1.java
r = nil lab = fail line: 1 col: 45
No: 	ClassTypeErr2.java
r = nil lab = fail line: 1 col: 41
No: 	ClassTypeErr3.java
r = nil lab = fail line: 1 col: 44
No: 	ClassTypeErr4.java
r = nil lab = fail line: 6 col: 22
No: 	ColonErr1.java
r = nil lab = fail line: 3 col: 6
No: 	ColonErr2.java
r = nil lab = fail line: 5 col: 5
No: 	ColonErr3.java
r = nil lab = fail line: 8 col: 18
No: 	ColonErr4.java
r = nil lab = fail line: 3 col: 14
No: 	ColonErr5.java
r = nil lab = fail line: 3 col: 24
No: 	CommaAvaliableErr.java
r = nil lab = fail line: 2 col: 32
No: 	ConstructorBodyErr.java
r = nil lab = fail line: 2 col: 23
No: 	CurRBrackErr1.java
r = nil lab = fail line: 2 col: 14
No: 	CurRBrackErr2.java
r = nil lab = fail line: 2 col: 19
No: 	CurRBrackErr3.java
r = nil lab = fail line: 4 col: 1
No: 	CurRBrackErr4.java
r = nil lab = fail line: 4 col: 1
No: 	CurRBrackErr5.java
r = nil lab = fail line: 2 col: 16
No: 	CurRBrackErr6.java
r = nil lab = fail line: 1 col: 23
No: 	CurRBrackErr7.java
r = nil lab = fail line: 3 col: 17
No: 	CurRBrackErr8.java
r = nil lab = fail line: 5 col: 8
No: 	CurRBrackErr9.java
r = nil lab = fail line: 9 col: 3
No: 	DotAvaliableErr.java
r = nil lab = fail line: 3 col: 34
No: 	DotErr1.java
r = nil lab = fail line: 3 col: 13
No: 	ElementValueErr1.java
r = nil lab = fail line: 2 col: 22
No: 	ElementValueErr2.java
r = nil lab = fail line: 1 col: 21
No: 	ElementValueErr4.java
r = nil lab = fail line: 1 col: 14
No: 	ElementValuePairErr.java
r = nil lab = fail line: 1 col: 19
No: 	EndErr.java
r = nil lab = fail line: 5 col: 1
No: 	EnumBodyErr.java
r = nil lab = fail line: 3 col: 1
No: 	EqAvaliableErr1.java
r = nil lab = fail line: 3 col: 13
No: 	EqAvaliableErr3.java
r = nil lab = fail line: 3 col: 15
No: 	EqVerticalBarAvaliableErr.java
r = nil lab = fail line: 6 col: 21
No: 	EqualAmpersandErr.java
r = nil lab = fail line: 3 col: 14
No: 	EqualPlusErr.java
r = nil lab = fail line: 3 col: 14
No: 	ExceptionTypeErr.java
r = nil lab = fail line: 2 col: 46
No: 	ExceptionTypeListErr.java
r = nil lab = fail line: 2 col: 43
No: 	ExpressionErr1.java
r = nil lab = fail line: 3 col: 10
No: 	ExpressionErr10.java
r = nil lab = fail line: 3 col: 11
No: 	ExpressionErr2.java
r = nil lab = fail line: 3 col: 11
No: 	ExpressionErr3.java
r = nil lab = fail line: 3 col: 14
No: 	ExpressionErr4.java
r = nil lab = fail line: 3 col: 17
No: 	ExpressionErr5.java
r = nil lab = fail line: 3 col: 17
No: 	ExpressionErr6.java
r = nil lab = fail line: 3 col: 20
No: 	ExpressionErr7.java
r = nil lab = fail line: 3 col: 35
No: 	ExpressionErr8.java
r = nil lab = fail line: 3 col: 24
No: 	ExpressionErr9.java
r = nil lab = fail line: 3 col: 27
No: 	FormalParameterErr.java
r = nil lab = fail line: 2 col: 30
No: 	GeqErr.java
r = nil lab = fail line: 1 col: 23
No: 	GreaterErr1.java
r = nil lab = fail line: 3 col: 33
No: 	IdErr1.java
r = nil lab = fail line: 1 col: 9
No: 	IdErr10.java
r = nil lab = fail line: 3 col: 14
No: 	IdErr11.java
r = nil lab = fail line: 3 col: 17
No: 	IdErr12.java
r = nil lab = fail line: 3 col: 18
No: 	IdErr13.java
r = nil lab = fail line: 3 col: 12
No: 	IdErr14.java
r = nil lab = fail line: 3 col: 21
No: 	IdErr15.java
r = nil lab = fail line: 3 col: 33
No: 	IdErr16.java
r = nil lab = fail line: 3 col: 14
No: 	IdErr2.java
r = nil lab = fail line: 1 col: 14
No: 	IdErr3.java
r = nil lab = fail line: 1 col: 14
No: 	IdErr4.java
r = nil lab = fail line: 1 col: 13
No: 	IdErr5.java
r = nil lab = fail line: 1 col: 18
No: 	IdErr6.java
r = nil lab = fail line: 1 col: 19
No: 	IdErr7.java
r = nil lab = fail line: 2 col: 6
No: 	IdErr8.java
r = nil lab = fail line: 3 col: 19
No: 	IdErr9.java
r = nil lab = fail line: 3 col: 20
No: 	InterfaceBodyErr.java
r = nil lab = fail line: 3 col: 1
No: 	InterfaceTypeListErr1.java
r = nil lab = fail line: 1 col: 49
No: 	InterfaceTypeListErr2.java
r = nil lab = fail line: 1 col: 50
No: 	InterfaceWordErr.java
r = nil lab = fail line: 1 col: 12
No: 	LParErr1.java
r = nil lab = fail line: 2 col: 25
No: 	LParErr2.java
r = nil lab = fail line: 2 col: 10
No: 	LParErr3.java
r = nil lab = fail line: 2 col: 11
No: 	LParErr4.java
r = nil lab = fail line: 3 col: 7
No: 	LParErr5.java
r = nil lab = fail line: 6 col: 9
No: 	LambdaBodyErr.java
r = nil lab = fail line: 3 col: 17
No: 	MethodBodyErr1.java
r = nil lab = fail line: 4 col: 2
No: 	MethodBodyErr2.java
r = nil lab = fail line: 2 col: 20
No: 	MethodDeclaratorErr.java
r = nil lab = fail line: 2 col: 18
No: 	MinusEqualGreaterErr.java
r = nil lab = fail line: 3 col: 14
No: 	NEWErr1.java
r = nil lab = fail line: 3 col: 18
No: 	ParExpressionErr1.java
r = nil lab = fail line: 3 col: 6
No: 	ParExpressionErr2.java
r = nil lab = fail line: 3 col: 9
No: 	ParExpressionErr3.java
r = nil lab = fail line: 5 col: 9
No: 	ParExpressionErr4.java
r = nil lab = fail line: 3 col: 10
No: 	ParExpressionErr5.java
r = nil lab = fail line: 3 col: 16
No: 	PrimaryQualIdentErr.java
r = nil lab = fail line: 3 col: 16
No: 	QualIdentErr1.java
r = nil lab = fail line: 1 col: 8
No: 	RBrackErr1.java
r = nil lab = fail line: 3 col: 17
No: 	RBrackErr2.java
r = nil lab = fail line: 3 col: 12
No: 	RBrackErr3.java
r = nil lab = fail line: 3 col: 13
No: 	RBrackErr4.java
r = nil lab = fail line: 3 col: 25
No: 	RBrackErr5.java
r = nil lab = fail line: 3 col: 31
No: 	RParErr1.java
r = nil lab = fail line: 2 col: 29
No: 	RParErr10.java
r = nil lab = fail line: 3 col: 33
No: 	RParErr11.java
r = nil lab = fail line: 3 col: 19
No: 	RParErr2.java
r = nil lab = fail line: 2 col: 12
No: 	RParErr3.java
r = nil lab = fail line: 2 col: 12
No: 	RParErr4.java
r = nil lab = fail line: 2 col: 1
No: 	RParErr5.java
r = nil lab = fail line: 3 col: 31
No: 	RParErr6.java
r = nil lab = fail line: 3 col: 18
No: 	RParErr7.java
r = nil lab = fail line: 6 col: 22
No: 	RParErr8.java
r = nil lab = fail line: 3 col: 18
No: 	RParErr9.java
r = nil lab = fail line: 3 col: 19
No: 	ReferenceTypeErr1.java
r = nil lab = fail line: 1 col: 53
No: 	ReferenceTypeErr2.java
r = nil lab = fail line: 1 col: 51
No: 	ReferenceTypeErr3.java
r = nil lab = fail line: 3 col: 22
No: 	ResourceErr.java
r = nil lab = fail line: 3 col: 19
No: 	ResourceListErr.java
r = nil lab = fail line: 3 col: 8
No: 	ResultErr.java
r = nil lab = fail line: 2 col: 13
No: 	SUPERErr1.java
r = nil lab = fail line: 3 col: 13
No: 	SUPERErr2.java
r = nil lab = fail line: 3 col: 16
No: 	SemiErr1.java
r = nil lab = fail line: 1 col: 15
No: 	SemiErr10.java
r = nil lab = fail line: 3 col: 9
No: 	SemiErr11.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr12.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr13.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr14.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr15.java
r = nil lab = fail line: 4 col: 3
No: 	SemiErr16.java
r = nil lab = fail line: 3 col: 27
No: 	SemiErr2.java
r = nil lab = fail line: 1 col: 14
No: 	SemiErr3.java
r = nil lab = fail line: 4 col: 3
No: 	SemiErr4.java
r = nil lab = fail line: 4 col: 3
No: 	SemiErr5.java
r = nil lab = fail line: 4 col: 5
No: 	SemiErr6.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr7.java
r = nil lab = fail line: 3 col: 1
No: 	SemiErr8.java
r = nil lab = fail line: 4 col: 2
No: 	SemiErr9.java
r = nil lab = fail line: 6 col: 2
No: 	StatementErr1.java
r = nil lab = fail line: 4 col: 5
No: 	StatementErr2.java
r = nil lab = fail line: 6 col: 5
No: 	StatementErr3.java
r = nil lab = fail line: 4 col: 5
No: 	StatementErr4.java
r = nil lab = fail line: 5 col: 8
No: 	StatementErr5.java
r = nil lab = fail line: 3 col: 8
No: 	StatementErr6.java
r = nil lab = fail line: 4 col: 13
No: 	StatementErr7.java
r = nil lab = fail line: 4 col: 4
No: 	StatementExpressionErr.java
r = nil lab = fail line: 3 col: 15
No: 	SwitchBlockErr.java
r = nil lab = fail line: 4 col: 4
No: 	TypeArgumentErr.java
r = nil lab = fail line: 1 col: 44
No: 	TypeParameterErr.java
r = nil lab = fail line: 1 col: 33
No: 	TypeParameterListErr.java
r = nil lab = fail line: 1 col: 36
No: 	UnaryExpressionErr1.java
r = nil lab = fail line: 3 col: 15
No: 	UnaryExpressionErr2.java
r = nil lab = fail line: 3 col: 15
No: 	UnaryExpressionErr3.java
r = nil lab = fail line: 3 col: 15
No: 	UnaryExpressionErr4.java
r = nil lab = fail line: 3 col: 15
No: 	UnaryExpressionErr5.java
r = nil lab = fail line: 3 col: 20
No: 	UnaryExpressionErr6.java
r = nil lab = fail line: 3 col: 18
No: 	VariableDeclaratorErr.java
r = nil lab = fail line: 2 col: 17
No: 	VariableDeclaratorIdErr1.java
r = nil lab = fail line: 2 col: 31
No: 	VariableDeclaratorIdErr2.java
r = nil lab = fail line: 6 col: 20
No: 	VariableDeclaratorIdErr3.java
r = nil lab = fail line: 3 col: 12
No: 	VariableDeclaratorListErr.java
r = nil lab = fail line: 2 col: 12
No: 	VariableInitializerErr1.java
r = nil lab = fail line: 2 col: 19
No: 	WHILEErr.java
r = nil lab = fail line: 5 col: 3

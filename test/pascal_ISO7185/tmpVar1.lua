Unique Path (UPath)
Uunique
PACKED	 = 	1
ARRAY	 = 	1
FUNCTION	 = 	1
Sign	 = 	2
TYPE	 = 	1
BEGIN	 = 	1
SET	 = 	1
SKIP	 = 	1
PROGRAM	 = 	1
Dot	 = 	2
Eq	 = 	2
DotDot	 = 	2
NIL	 = 	1
NOT	 = 	1
MultOp	 = 	1
AddOp	 = 	1
RelOp	 = 	1
FOR	 = 	1
REPEAT	 = 	1
WITH	 = 	1
END	 = 	3
Pointer	 = 	2
TO	 = 	1
LBrack	 = 	3
VAR	 = 	2
LABEL	 = 	1
OF	 = 	5
UNTIL	 = 	1
FILE	 = 	1
ELSE	 = 	1
CONST	 = 	1
THEN	 = 	1
IF	 = 	1
GOTO	 = 	1
WHILE	 = 	1
Assign	 = 	2
UNumber	 = 	2
UInt	 = 	1
DOWNTO	 = 	1
CASE	 = 	2
String	 = 	2
RPar	 = 	6
DO	 = 	3
RECORD	 = 	1
RBrack	 = 	3
Comma	 = 	8
Id	 = 	22
LPar	 = 	6
Semi	 = 	19
PROCEDURE	 = 	1
Colon	 = 	9
Token 	1	 = 	30
Token 	2	 = 	10
Token 	3	 = 	4
Token 	4	 = 	nil
Token 	5	 = 	1
Token 	6	 = 	2
Token 	7	 = 	nil
Token 	8	 = 	1
Token 	9	 = 	1
Token 	10	 = 	nil
Unique tokens (# 29): ARRAY, AddOp, BEGIN, CONST, DOWNTO, ELSE, FILE, FOR, FUNCTION, GOTO, IF, LABEL, MultOp, NIL, NOT, PACKED, PROCEDURE, PROGRAM, RECORD, REPEAT, RelOp, SET, THEN, TO, TYPE, UInt, UNTIL, WHILE, WITH
calcTail
program: 	__Dot
head: 	__Semi
decs: 	__Semi, __empty
ids: 	__Id
labelDecs: 	__Semi, __empty
labels: 	__UInt
label: 	__UInt
constDefs: 	__Semi, __empty
constDef: 	__Id, __String, __UNumber
const: 	__Id, __String, __UNumber
typeDefs: 	__Semi, __empty
typeDef: 	__END, __Id, __RPar, __String, __UNumber
type: 	__END, __Id, __RPar, __String, __UNumber
newType: 	__END, __Id, __RPar, __String, __UNumber
newOrdinalType: 	__Id, __RPar, __String, __UNumber
newStructuredType: 	__END, __Id, __RPar, __String, __UNumber
newPointerType: 	__Id
enumType: 	__RPar
subrangeType: 	__Id, __String, __UNumber
unpackedStructuredType: 	__END, __Id, __RPar, __String, __UNumber
arrayType: 	__END, __Id, __RPar, __String, __UNumber
recordType: 	__END
setType: 	__Id, __RPar, __String, __UNumber
fileType: 	__END, __Id, __RPar, __String, __UNumber
ordinalType: 	__Id, __RPar, __String, __UNumber
fieldList: 	__END, __Id, __RPar, __Semi, __String, __UNumber, __empty
fixedPart: 	__END, __Id, __RPar, __String, __UNumber
variantPart: 	__RPar
variant: 	__RPar
consts: 	__Id, __String, __UNumber
varDecs: 	__Semi, __empty
varDec: 	__END, __Id, __RPar, __String, __UNumber
procAndFuncDecs: 	__Semi, __empty
procDec: 	__END, __Id
procHeading: 	__Id, __RPar
funcDec: 	__END, __Id
funcHeading: 	__END, __Id, __RPar, __String, __UNumber
formalParams: 	__RPar
formalParamsSection: 	__END, __Id, __RPar, __String, __UNumber
block: 	__END
stmts: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __Semi, __String, __THEN, __UInt, __UNumber, __empty
stmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
simpleStmt: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UInt, __UNumber
assignStmt: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
var: 	__Id, __Pointer, __RBrack
procStmt: 	__Id, __RPar
params: 	__RPar
param: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
gotoStmt: 	__UInt
structuredStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
conditionalStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
ifStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
caseStmt: 	__END
caseListElement: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
repetitiveStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
repeatStmt: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
whileStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
forStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
withStmt: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
expr: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
simpleExpr: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
term: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
factor: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
unsignedConst: 	__Id, __NIL, __String, __UNumber
funcCall: 	__RPar
setConstructor: 	__RBrack
memberDesignator: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
AddOp: 	+, -, __OR
Assign: 	:=
Dot: 	.
DotDot: 	..
CloseComment: 	*), }
Colon: 	:
Comma: 	,
COMMENT: 	__CloseComment
Eq: 	=
BodyId: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
Id: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
LBrack: 	[
LPar: 	(
MultOp: 	*, /, __AND, __DIV, __MOD
OpenComment: 	(*, {
Pointer: 	^
RBrack: 	]
RelOp: 	<, <=, <>, =, >, >=, __IN
RPar: 	)
Semi: 	;
Sign: 	+, -
String: 	'
UInt: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
UNumber: 	__UInt, __UReal
UReal: 	0, 1, 2, 3, 4, 5, 6, 7, 8, 9
Reserved: 	__AND, __ARRAY, __BEGIN, __CASE, __CONST, __DIV, __DO, __DOWNTO, __ELSE, __END, __FILE, __FOR, __FUNCTION, __GOTO, __IF, __IN, __LABEL, __MOD, __NIL, __NOT, __OF, __OR, __PACKED, __PROCEDURE, __PROGRAM, __RECORD, __REPEAT, __SET, __THEN, __TO, __TYPE, __UNTIL, __VAR, __WHILE, __WITH
AND: 	D, d
ARRAY: 	Y, y
BEGIN: 	N, n
CASE: 	E, e
CONST: 	T, t
DIV: 	V, v
DO: 	O, o
DOWNTO: 	O, o
ELSE: 	E, e
END: 	D, d
FILE: 	E, e
FOR: 	R, r
FUNCTION: 	N, n
GOTO: 	O, o
IF: 	F, f
IN: 	N, n
LABEL: 	L, l
MOD: 	D, d
NIL: 	L, l
NOT: 	T, t
OF: 	F, f
OR: 	R, r
PACKED: 	D, d
PROCEDURE: 	E, e
PROGRAM: 	M, m
RECORD: 	D, d
REPEAT: 	T, t
SET: 	T, t
THEN: 	N, n
TO: 	O, o
TYPE: 	E, e
UNTIL: 	L, l
VAR: 	R, r
WHILE: 	E, e
WITH: 	H, h
SPACE: 		, 
, , , ,  , __COMMENT
SKIP: 		, 
, , , ,  , __COMMENT, __empty
Global Prefix
program: 	
head: 	__SKIP
decs: 	__Semi
ids: 	__LPar, __RECORD, __Semi, __VAR
labelDecs: 	__Semi
labels: 	__LABEL
label: 	__BEGIN, __Colon, __Comma, __DO, __ELSE, __GOTO, __LABEL, __REPEAT, __Semi, __THEN
constDefs: 	__Semi, __empty
constDef: 	__CONST, __Semi
const: 	__Colon, __Comma, __DotDot, __Eq, __LBrack, __OF, __Semi
typeDefs: 	__Semi, __empty
typeDef: 	__Semi, __TYPE
type: 	__Colon, __Eq, __OF
newType: 	__Colon, __Eq, __OF
newOrdinalType: 	__Colon, __Comma, __Eq, __LBrack, __OF
newStructuredType: 	__Colon, __Eq, __OF
newPointerType: 	__Colon, __Eq, __OF
enumType: 	__Colon, __Comma, __Eq, __LBrack, __OF
subrangeType: 	__Colon, __Comma, __Eq, __LBrack, __OF
unpackedStructuredType: 	__Colon, __Eq, __OF, __PACKED
arrayType: 	__Colon, __Eq, __OF, __PACKED
recordType: 	__Colon, __Eq, __OF, __PACKED
setType: 	__Colon, __Eq, __OF, __PACKED
fileType: 	__Colon, __Eq, __OF, __PACKED
ordinalType: 	__Comma, __LBrack, __OF
fieldList: 	__LPar, __RECORD
fixedPart: 	__LPar, __RECORD
variantPart: 	__LPar, __RECORD, __Semi
variant: 	__OF, __Semi
consts: 	__OF, __Semi
varDecs: 	__Semi, __empty
varDec: 	__LPar, __RECORD, __Semi, __VAR
procAndFuncDecs: 	__Semi, __empty
procDec: 	__Semi, __empty
procHeading: 	__LPar, __Semi, __empty
funcDec: 	__Semi, __empty
funcHeading: 	__LPar, __Semi, __empty
formalParams: 	__Id
formalParamsSection: 	__LPar, __Semi
block: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN, __empty
stmts: 	__BEGIN, __REPEAT
stmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
simpleStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
assignStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
var: 	__AddOp, __Assign, __BEGIN, __CASE, __Colon, __Comma, __DO, __DOWNTO, __DotDot, __ELSE, __IF, __LBrack, __LPar, __MultOp, __NOT, __REPEAT, __RelOp, __Semi, __Sign, __THEN, __TO, __UNTIL, __WHILE, __WITH
procStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
params: 	__Id
param: 	__Comma, __LPar
gotoStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
structuredStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
conditionalStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
ifStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
caseStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
caseListElement: 	__OF, __Semi
repetitiveStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
repeatStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
whileStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
forStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
withStmt: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
expr: 	__Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __TO, __UNTIL, __WHILE
simpleExpr: 	__Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __RelOp, __TO, __UNTIL, __WHILE
term: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __RelOp, __Sign, __TO, __UNTIL, __WHILE
factor: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __RelOp, __Sign, __TO, __UNTIL, __WHILE
unsignedConst: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __NOT, __RelOp, __Sign, __TO, __UNTIL, __WHILE
funcCall: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __NOT, __RelOp, __Sign, __TO, __UNTIL, __WHILE
setConstructor: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __NOT, __RelOp, __Sign, __TO, __UNTIL, __WHILE
memberDesignator: 	__Comma, __LBrack
AddOp: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
Assign: 	__Id, __Pointer, __RBrack
Dot: 	__END, __Id, __Pointer, __RBrack
DotDot: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
CloseComment: 	__OpenComment, __any
Colon: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UInt, __UNumber
Comma: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UInt, __UNumber
COMMENT: 		, 
, , , ,  , __COMMENT
Eq: 	__Id
BodyId: 	
Id: 	__AddOp, __Assign, __BEGIN, __CASE, __CONST, __Colon, __Comma, __DO, __DOWNTO, __Dot, __DotDot, __ELSE, __Eq, __FOR, __FUNCTION, __IF, __LBrack, __LPar, __MultOp, __NOT, __OF, __PROCEDURE, __PROGRAM, __Pointer, __RECORD, __REPEAT, __RelOp, __Semi, __Sign, __THEN, __TO, __TYPE, __UNTIL, __VAR, __WHILE, __WITH
LBrack: 	__ARRAY, __AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __Id, __LBrack, __LPar, __MultOp, __NOT, __Pointer, __RBrack, __RelOp, __Sign, __TO, __UNTIL, __WHILE
LPar: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __Eq, __IF, __Id, __LBrack, __LPar, __MultOp, __NOT, __OF, __RelOp, __Sign, __TO, __UNTIL, __WHILE
MultOp: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
OpenComment: 		, 
, , , ,  , __COMMENT
Pointer: 	__Colon, __Eq, __Id, __OF, __Pointer, __RBrack
RBrack: 	__Id, __LBrack, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
RelOp: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
RPar: 	__END, __Id, __LPar, __NIL, __Pointer, __RBrack, __RPar, __Semi, __String, __UNumber, __empty
Semi: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __OF, __Pointer, __RBrack, __RPar, __Semi, __String, __THEN, __UInt, __UNumber, __empty
Sign: 	__Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __Eq, __IF, __LBrack, __LPar, __OF, __RelOp, __Semi, __TO, __UNTIL, __WHILE
String: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __Eq, __IF, __LBrack, __LPar, __MultOp, __NOT, __OF, __RelOp, __Semi, __Sign, __TO, __UNTIL, __WHILE
UInt: 	__AddOp, __Assign, __BEGIN, __CASE, __Colon, __Comma, __DO, __DOWNTO, __DotDot, __ELSE, __Eq, __GOTO, __IF, __LABEL, __LBrack, __LPar, __MultOp, __NOT, __OF, __REPEAT, __RelOp, __Semi, __Sign, __THEN, __TO, __UNTIL, __WHILE
UNumber: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __Eq, __IF, __LBrack, __LPar, __MultOp, __NOT, __OF, __RelOp, __Semi, __Sign, __TO, __UNTIL, __WHILE
UReal: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __Eq, __IF, __LBrack, __LPar, __MultOp, __NOT, __OF, __RelOp, __Semi, __Sign, __TO, __UNTIL, __WHILE
Reserved: 	
AND: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
ARRAY: 	__Colon, __Eq, __OF, __PACKED
BEGIN: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN, __empty
CASE: 	__BEGIN, __Colon, __DO, __ELSE, __LPar, __RECORD, __REPEAT, __Semi, __THEN
CONST: 	__Semi, __empty
DIV: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
DO: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
DOWNTO: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
ELSE: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __RPar, __String, __THEN, __UInt, __UNumber, __empty
END: 	__BEGIN, __Colon, __DO, __ELSE, __END, __Id, __NIL, __OF, __Pointer, __RBrack, __RECORD, __RPar, __Semi, __String, __THEN, __UInt, __UNumber, __empty
FILE: 	__Colon, __Eq, __OF, __PACKED
FOR: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
FUNCTION: 	__LPar, __Semi, __empty
GOTO: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
IF: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
IN: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
LABEL: 	__Semi
MOD: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
NIL: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __NOT, __RelOp, __Sign, __TO, __UNTIL, __WHILE
NOT: 	__AddOp, __Assign, __CASE, __Colon, __Comma, __DOWNTO, __DotDot, __IF, __LBrack, __LPar, __MultOp, __NOT, __RelOp, __Sign, __TO, __UNTIL, __WHILE
OF: 	__FILE, __Id, __NIL, __Pointer, __RBrack, __RPar, __SET, __String, __UNumber
OR: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
PACKED: 	__Colon, __Eq, __OF
PROCEDURE: 	__LPar, __Semi, __empty
PROGRAM: 	__SKIP
RECORD: 	__Colon, __Eq, __OF, __PACKED
REPEAT: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
SET: 	__Colon, __Eq, __OF, __PACKED
THEN: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
TO: 	__Id, __NIL, __Pointer, __RBrack, __RPar, __String, __UNumber
TYPE: 	__Semi, __empty
UNTIL: 	__Colon, __DO, __ELSE, __END, __Id, __NIL, __Pointer, __RBrack, __REPEAT, __RPar, __Semi, __String, __THEN, __UInt, __UNumber, __empty
VAR: 	__LPar, __Semi, __empty
WHILE: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
WITH: 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN
SPACE: 	
SKIP: 	
foi true22
passou três	head	program
UniqueFlwVar	head	rule = 	program	pref = 	__SKIP	flw = 	__BEGIN, __CONST, __FUNCTION, __LABEL, __PROCEDURE, __TYPE, __VAR
UniqueFlwVar	decs	rule = 	program	pref = 	__Semi	flw = 	__BEGIN
UniqueFlwVar	block	rule = 	program	pref = 	__Semi, __empty	flw = 	__Dot
foi true22
foi true22
foi true22
passou três	labelDecs	decs
UniqueFlwVar	labelDecs	rule = 	decs	pref = 	__Semi	flw = 	__BEGIN, __CONST, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	constDefs	decs
UniqueFlwVar	constDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	typeDefs	decs
UniqueFlwVar	typeDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __VAR
UniqueFlwVar	varDecs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE
passou três	procAndFuncDecs	decs
foi true22
passou três	labels	labelDecs
UniqueFlwVar	labels	rule = 	labelDecs	pref = 	__LABEL	flw = 	__Semi
passou três	label	labels
UniqueFlwVar	label	rule = 	labels	pref = 	__LABEL	flw = 	__Comma, __Semi
foi true22
passou três	label	labels
foi true22
passou três	constDef	constDefs
UniqueFlwVar	constDef	rule = 	constDefs	pref = 	__CONST	flw = 	__Semi
foi true22
passou três	typeDef	typeDefs
UniqueFlwVar	typeDef	rule = 	typeDefs	pref = 	__TYPE	flw = 	__Semi
passou três	type	typeDef
passou três	newStructuredType	newType
passou três	newPointerType	newType
foi true22
passou três	unpackedStructuredType	newStructuredType
foi true22
passou três	arrayType	unpackedStructuredType
passou três	recordType	unpackedStructuredType
passou três	setType	unpackedStructuredType
passou três	fileType	unpackedStructuredType
foi true22
foi true22
foi true22
passou três	fieldList	recordType
UniqueFlwVar	fieldList	rule = 	recordType	pref = 	__RECORD	flw = 	__END
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__Semi	flw = 	__END, __RPar, __Semi
passou três	variantPart	fieldList
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__LPar, __RECORD	flw = 	__END, __RPar, __Semi
passou três	varDec	varDecs
UniqueFlwVar	varDec	rule = 	varDecs	pref = 	__VAR	flw = 	__Semi
passou três	procDec	procAndFuncDecs
UniqueFlwVar	procDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
passou três	funcDec	procAndFuncDecs
UniqueFlwVar	funcDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	procHeading	rule = 	procDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	procDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	funcHeading	rule = 	funcDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	funcDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	formalParams	rule = 	funcHeading	pref = 	__Id	flw = 	__Colon
foi true22
passou três	stmts	block
UniqueFlwVar	stmts	rule = 	block	pref = 	__BEGIN	flw = 	__END
passou três	stmt	stmts
UniqueFlwVar	stmt	rule = 	stmts	pref = 	__BEGIN, __REPEAT	flw = 	__END, __Semi, __UNTIL
passou três	label	stmt
UniqueFlwVar	label	rule = 	stmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Colon
foi true22
passou três	gotoStmt	simpleStmt
UniqueFlwVar	var	rule = 	assignStmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Assign
foi true22
foi true22
foi true22
passou três	label	gotoStmt
passou três	repetitiveStmt	structuredStmt
passou três	withStmt	structuredStmt
passou três	ifStmt	conditionalStmt
foi true22
passou três	expr	ifStmt
UniqueFlwVar	expr	rule = 	ifStmt	pref = 	__IF	flw = 	__THEN
foi true22
passou três	stmt	ifStmt
UniqueFlwVar	stmt	rule = 	ifStmt	pref = 	__THEN	flw = 	__ELSE, __END, __Semi, __UNTIL
foi true22
passou três	stmt	ifStmt
passou três	repeatStmt	repetitiveStmt
passou três	whileStmt	repetitiveStmt
passou três	forStmt	repetitiveStmt
foi true22
passou três	stmts	repeatStmt
UniqueFlwVar	stmts	rule = 	repeatStmt	pref = 	__REPEAT	flw = 	__UNTIL
foi true22
passou três	expr	repeatStmt
foi true22
passou três	expr	whileStmt
UniqueFlwVar	expr	rule = 	whileStmt	pref = 	__WHILE	flw = 	__DO
foi true22
foi true22
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__Assign	flw = 	__DOWNTO, __TO
foi true22
foi true22
passou três	expr	forStmt
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__DOWNTO, __TO	flw = 	__DO
foi true22
passou três	var	withStmt
UniqueFlwVar	var	rule = 	withStmt	pref = 	__WITH	flw = 	__Comma, __DO
foi true22
passou três	simpleExpr	expr
foi true22
passou três	term	simpleExpr
foi true22
passou três	factor	term
foi true22
passou três	setConstructor	factor
foi true22
unique var 	head
Unique usage	head
unique var 	decs
unique var 	block
unique var 	ids
unique var 	constDefs
Unique usage	constDefs
unique var 	typeDefs
Unique usage	typeDefs
unique var 	varDecs
Unique usage	varDecs
unique var 	procAndFuncDecs
Unique usage	procAndFuncDecs
unique var 	labels
Unique usage	labels
unique var 	label
Unique usage	label
unique var 	label
Unique usage	label
unique var 	constDef
unique var 	constDef
Unique usage	constDef
unique var 	const
unique var 	typeDef
unique var 	typeDef
Unique usage	typeDef
unique var 	type
unique var 	ordinalType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	fieldList
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	varDec
unique var 	varDec
unique var 	procDec
Unique usage	procDec
unique var 	funcDec
Unique usage	funcDec
unique var 	procHeading
unique var 	decs
unique var 	block
unique var 	formalParams
unique var 	funcHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	type
unique var 	formalParamsSection
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	ids
unique var 	procHeading
Unique usage	procHeading
unique var 	funcHeading
Unique usage	funcHeading
unique var 	stmts
Unique usage	stmts
unique var 	stmt
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	expr
unique var 	label
Unique usage	label
unique var 	expr
unique var 	stmt
unique var 	stmt
unique var 	stmts
Unique usage	stmts
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	var
unique var 	var
unique var 	stmt
unique var 	simpleExpr
unique var 	term
unique var 	factor
unique var 	memberDesignator
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	expr
unique var 	expr
foi true22
UniqueFlwVar	head	rule = 	program	pref = 	__SKIP	flw = 	__BEGIN, __CONST, __FUNCTION, __LABEL, __PROCEDURE, __TYPE, __VAR
UniqueFlwVar	decs	rule = 	program	pref = 	__Semi	flw = 	__BEGIN
UniqueFlwVar	block	rule = 	program	pref = 	__Semi, __empty	flw = 	__Dot
foi true22
foi true22
foi true22
passou três	labelDecs	decs
UniqueFlwVar	labelDecs	rule = 	decs	pref = 	__Semi	flw = 	__BEGIN, __CONST, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	constDefs	decs
UniqueFlwVar	constDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	typeDefs	decs
UniqueFlwVar	typeDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __VAR
UniqueFlwVar	varDecs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE
passou três	procAndFuncDecs	decs
foi true22
UniqueFlwVar	labels	rule = 	labelDecs	pref = 	__LABEL	flw = 	__Semi
passou três	label	labels
UniqueFlwVar	label	rule = 	labels	pref = 	__LABEL	flw = 	__Comma, __Semi
foi true22
passou três	label	labels
foi true22
UniqueFlwVar	constDef	rule = 	constDefs	pref = 	__CONST	flw = 	__Semi
foi true22
UniqueFlwVar	typeDef	rule = 	typeDefs	pref = 	__TYPE	flw = 	__Semi
passou três	type	typeDef
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	fieldList	recordType
UniqueFlwVar	fieldList	rule = 	recordType	pref = 	__RECORD	flw = 	__END
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__Semi	flw = 	__END, __RPar, __Semi
passou três	variantPart	fieldList
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__LPar, __RECORD	flw = 	__END, __RPar, __Semi
passou três	varDec	varDecs
UniqueFlwVar	varDec	rule = 	varDecs	pref = 	__VAR	flw = 	__Semi
UniqueFlwVar	procDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	funcDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	procHeading	rule = 	procDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	procDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	funcHeading	rule = 	funcDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	funcDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	formalParams	rule = 	funcHeading	pref = 	__Id	flw = 	__Colon
foi true22
passou três	stmts	block
UniqueFlwVar	stmts	rule = 	block	pref = 	__BEGIN	flw = 	__END
passou três	stmt	stmts
UniqueFlwVar	stmt	rule = 	stmts	pref = 	__BEGIN, __REPEAT	flw = 	__END, __Semi, __UNTIL
passou três	label	stmt
UniqueFlwVar	label	rule = 	stmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Colon
foi true22
UniqueFlwVar	var	rule = 	assignStmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Assign
foi true22
foi true22
foi true22
passou três	label	gotoStmt
foi true22
passou três	expr	ifStmt
UniqueFlwVar	expr	rule = 	ifStmt	pref = 	__IF	flw = 	__THEN
foi true22
passou três	stmt	ifStmt
UniqueFlwVar	stmt	rule = 	ifStmt	pref = 	__THEN	flw = 	__ELSE, __END, __Semi, __UNTIL
foi true22
passou três	stmt	ifStmt
foi true22
passou três	stmts	repeatStmt
UniqueFlwVar	stmts	rule = 	repeatStmt	pref = 	__REPEAT	flw = 	__UNTIL
foi true22
passou três	expr	repeatStmt
foi true22
passou três	expr	whileStmt
UniqueFlwVar	expr	rule = 	whileStmt	pref = 	__WHILE	flw = 	__DO
foi true22
foi true22
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__Assign	flw = 	__DOWNTO, __TO
foi true22
foi true22
passou três	expr	forStmt
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__DOWNTO, __TO	flw = 	__DO
foi true22
passou três	var	withStmt
UniqueFlwVar	var	rule = 	withStmt	pref = 	__WITH	flw = 	__Comma, __DO
foi true22
passou três	simpleExpr	expr
foi true22
passou três	term	simpleExpr
foi true22
foi true22
foi true22
unique var 	head
Unique usage	head
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	ids
unique var 	labelDecs
Unique usage	labelDecs
unique var 	constDefs
Unique usage	constDefs
unique var 	typeDefs
Unique usage	typeDefs
unique var 	varDecs
Unique usage	varDecs
unique var 	procAndFuncDecs
Unique usage	procAndFuncDecs
unique var 	labels
Unique usage	labels
unique var 	label
Unique usage	label
unique var 	label
Unique usage	label
unique var 	constDef
Unique usage	constDef
unique var 	constDef
Unique usage	constDef
unique var 	const
unique var 	typeDef
Unique usage	typeDef
unique var 	typeDef
Unique usage	typeDef
unique var 	type
unique var2 	newStructuredType
unique var2 	newPointerType
unique var2 	unpackedStructuredType
unique var2 	arrayType
unique var2 	recordType
unique var2 	setType
unique var2 	fileType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	fieldList
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	varDec
unique var 	varDec
unique var 	procDec
Unique usage	procDec
unique var 	funcDec
Unique usage	funcDec
unique var 	procHeading
Unique usage	procHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	funcHeading
Unique usage	funcHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	type
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	ids
unique var 	procHeading
Unique usage	procHeading
unique var 	funcHeading
Unique usage	funcHeading
unique var 	stmts
Unique usage	stmts
unique var 	stmt
unique var 	stmt
unique var2 	assignStmt
unique var2 	gotoStmt
unique var 	expr
unique var 	expr
unique var 	expr
unique var 	label
Unique usage	label
unique var2 	repetitiveStmt
unique var2 	withStmt
unique var2 	ifStmt
unique var 	expr
unique var 	stmt
unique var 	stmt
unique var2 	repeatStmt
unique var2 	whileStmt
unique var2 	forStmt
unique var 	stmts
Unique usage	stmts
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	var
unique var 	var
unique var 	stmt
unique var 	simpleExpr
unique var 	term
unique var 	factor
Unique usage	factor
unique var 	unsignedConst
Unique usage	unsignedConst
unique var 	setConstructor
Unique usage	setConstructor
unique var 	expr
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	expr
unique var 	expr
foi true22
UniqueFlwVar	head	rule = 	program	pref = 	__SKIP	flw = 	__BEGIN, __CONST, __FUNCTION, __LABEL, __PROCEDURE, __TYPE, __VAR
UniqueFlwVar	decs	rule = 	program	pref = 	__Semi	flw = 	__BEGIN
UniqueFlwVar	block	rule = 	program	pref = 	__Semi, __empty	flw = 	__Dot
foi true22
foi true22
foi true22
passou três	labelDecs	decs
UniqueFlwVar	labelDecs	rule = 	decs	pref = 	__Semi	flw = 	__BEGIN, __CONST, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	constDefs	decs
UniqueFlwVar	constDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	typeDefs	decs
UniqueFlwVar	typeDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __VAR
UniqueFlwVar	varDecs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE
passou três	procAndFuncDecs	decs
foi true22
UniqueFlwVar	labels	rule = 	labelDecs	pref = 	__LABEL	flw = 	__Semi
passou três	label	labels
UniqueFlwVar	label	rule = 	labels	pref = 	__LABEL	flw = 	__Comma, __Semi
foi true22
passou três	label	labels
foi true22
UniqueFlwVar	constDef	rule = 	constDefs	pref = 	__CONST	flw = 	__Semi
foi true22
UniqueFlwVar	typeDef	rule = 	typeDefs	pref = 	__TYPE	flw = 	__Semi
passou três	type	typeDef
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	fieldList	recordType
UniqueFlwVar	fieldList	rule = 	recordType	pref = 	__RECORD	flw = 	__END
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__Semi	flw = 	__END, __RPar, __Semi
passou três	variantPart	fieldList
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__LPar, __RECORD	flw = 	__END, __RPar, __Semi
passou três	varDec	varDecs
UniqueFlwVar	varDec	rule = 	varDecs	pref = 	__VAR	flw = 	__Semi
UniqueFlwVar	procDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	funcDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	procHeading	rule = 	procDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	procDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	funcHeading	rule = 	funcDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	funcDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	formalParams	rule = 	funcHeading	pref = 	__Id	flw = 	__Colon
foi true22
passou três	stmts	block
UniqueFlwVar	stmts	rule = 	block	pref = 	__BEGIN	flw = 	__END
passou três	stmt	stmts
UniqueFlwVar	stmt	rule = 	stmts	pref = 	__BEGIN, __REPEAT	flw = 	__END, __Semi, __UNTIL
passou três	label	stmt
UniqueFlwVar	label	rule = 	stmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Colon
foi true22
UniqueFlwVar	var	rule = 	assignStmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Assign
foi true22
foi true22
foi true22
passou três	label	gotoStmt
foi true22
passou três	expr	ifStmt
UniqueFlwVar	expr	rule = 	ifStmt	pref = 	__IF	flw = 	__THEN
foi true22
passou três	stmt	ifStmt
UniqueFlwVar	stmt	rule = 	ifStmt	pref = 	__THEN	flw = 	__ELSE, __END, __Semi, __UNTIL
foi true22
passou três	stmt	ifStmt
foi true22
passou três	stmts	repeatStmt
UniqueFlwVar	stmts	rule = 	repeatStmt	pref = 	__REPEAT	flw = 	__UNTIL
foi true22
passou três	expr	repeatStmt
foi true22
passou três	expr	whileStmt
UniqueFlwVar	expr	rule = 	whileStmt	pref = 	__WHILE	flw = 	__DO
foi true22
foi true22
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__Assign	flw = 	__DOWNTO, __TO
foi true22
foi true22
passou três	expr	forStmt
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__DOWNTO, __TO	flw = 	__DO
foi true22
passou três	var	withStmt
UniqueFlwVar	var	rule = 	withStmt	pref = 	__WITH	flw = 	__Comma, __DO
foi true22
passou três	simpleExpr	expr
foi true22
foi true22
foi true22
foi true22
unique var 	head
Unique usage	head
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	ids
unique var 	labelDecs
Unique usage	labelDecs
unique var 	constDefs
Unique usage	constDefs
unique var 	typeDefs
Unique usage	typeDefs
unique var 	varDecs
Unique usage	varDecs
unique var 	procAndFuncDecs
Unique usage	procAndFuncDecs
unique var 	labels
Unique usage	labels
unique var 	label
Unique usage	label
unique var 	label
Unique usage	label
unique var 	constDef
Unique usage	constDef
unique var 	constDef
Unique usage	constDef
unique var 	const
unique var 	typeDef
Unique usage	typeDef
unique var 	typeDef
Unique usage	typeDef
unique var 	type
unique var2 	newStructuredType
unique var2 	newPointerType
unique var2 	unpackedStructuredType
unique var2 	arrayType
unique var2 	recordType
unique var2 	setType
unique var2 	fileType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	fieldList
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	varDec
unique var 	varDec
unique var 	procDec
Unique usage	procDec
unique var 	funcDec
Unique usage	funcDec
unique var 	procHeading
Unique usage	procHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	funcHeading
Unique usage	funcHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	type
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	ids
unique var 	procHeading
Unique usage	procHeading
unique var 	funcHeading
Unique usage	funcHeading
unique var 	stmts
Unique usage	stmts
unique var 	stmt
unique var 	stmt
unique var2 	assignStmt
unique var2 	gotoStmt
unique var 	expr
unique var 	expr
unique var 	expr
unique var 	label
Unique usage	label
unique var2 	repetitiveStmt
unique var2 	withStmt
unique var2 	ifStmt
unique var 	expr
unique var 	stmt
unique var 	stmt
unique var2 	repeatStmt
unique var2 	whileStmt
unique var2 	forStmt
unique var 	stmts
Unique usage	stmts
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	var
unique var 	var
unique var 	stmt
unique var 	simpleExpr
unique var 	term
Unique usage	term
unique var 	factor
Unique usage	factor
unique var 	factor
Unique usage	factor
unique var 	unsignedConst
Unique usage	unsignedConst
unique var 	setConstructor
Unique usage	setConstructor
unique var 	expr
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	expr
unique var 	expr
foi true22
UniqueFlwVar	head	rule = 	program	pref = 	__SKIP	flw = 	__BEGIN, __CONST, __FUNCTION, __LABEL, __PROCEDURE, __TYPE, __VAR
UniqueFlwVar	decs	rule = 	program	pref = 	__Semi	flw = 	__BEGIN
UniqueFlwVar	block	rule = 	program	pref = 	__Semi, __empty	flw = 	__Dot
foi true22
foi true22
foi true22
passou três	labelDecs	decs
UniqueFlwVar	labelDecs	rule = 	decs	pref = 	__Semi	flw = 	__BEGIN, __CONST, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	constDefs	decs
UniqueFlwVar	constDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	typeDefs	decs
UniqueFlwVar	typeDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __VAR
UniqueFlwVar	varDecs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE
passou três	procAndFuncDecs	decs
foi true22
UniqueFlwVar	labels	rule = 	labelDecs	pref = 	__LABEL	flw = 	__Semi
passou três	label	labels
UniqueFlwVar	label	rule = 	labels	pref = 	__LABEL	flw = 	__Comma, __Semi
foi true22
passou três	label	labels
foi true22
UniqueFlwVar	constDef	rule = 	constDefs	pref = 	__CONST	flw = 	__Semi
foi true22
UniqueFlwVar	typeDef	rule = 	typeDefs	pref = 	__TYPE	flw = 	__Semi
passou três	type	typeDef
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	fieldList	recordType
UniqueFlwVar	fieldList	rule = 	recordType	pref = 	__RECORD	flw = 	__END
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__Semi	flw = 	__END, __RPar, __Semi
passou três	variantPart	fieldList
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__LPar, __RECORD	flw = 	__END, __RPar, __Semi
passou três	varDec	varDecs
UniqueFlwVar	varDec	rule = 	varDecs	pref = 	__VAR	flw = 	__Semi
UniqueFlwVar	procDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	funcDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	procHeading	rule = 	procDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	procDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	funcHeading	rule = 	funcDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	funcDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	formalParams	rule = 	funcHeading	pref = 	__Id	flw = 	__Colon
foi true22
passou três	stmts	block
UniqueFlwVar	stmts	rule = 	block	pref = 	__BEGIN	flw = 	__END
passou três	stmt	stmts
UniqueFlwVar	stmt	rule = 	stmts	pref = 	__BEGIN, __REPEAT	flw = 	__END, __Semi, __UNTIL
passou três	label	stmt
UniqueFlwVar	label	rule = 	stmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Colon
foi true22
UniqueFlwVar	var	rule = 	assignStmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Assign
foi true22
foi true22
foi true22
passou três	label	gotoStmt
foi true22
passou três	expr	ifStmt
UniqueFlwVar	expr	rule = 	ifStmt	pref = 	__IF	flw = 	__THEN
foi true22
passou três	stmt	ifStmt
UniqueFlwVar	stmt	rule = 	ifStmt	pref = 	__THEN	flw = 	__ELSE, __END, __Semi, __UNTIL
foi true22
passou três	stmt	ifStmt
foi true22
passou três	stmts	repeatStmt
UniqueFlwVar	stmts	rule = 	repeatStmt	pref = 	__REPEAT	flw = 	__UNTIL
foi true22
passou três	expr	repeatStmt
foi true22
passou três	expr	whileStmt
UniqueFlwVar	expr	rule = 	whileStmt	pref = 	__WHILE	flw = 	__DO
foi true22
foi true22
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__Assign	flw = 	__DOWNTO, __TO
foi true22
foi true22
passou três	expr	forStmt
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__DOWNTO, __TO	flw = 	__DO
foi true22
passou três	var	withStmt
UniqueFlwVar	var	rule = 	withStmt	pref = 	__WITH	flw = 	__Comma, __DO
foi true22
foi true22
foi true22
foi true22
foi true22
unique var 	head
Unique usage	head
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	ids
unique var 	labelDecs
Unique usage	labelDecs
unique var 	constDefs
Unique usage	constDefs
unique var 	typeDefs
Unique usage	typeDefs
unique var 	varDecs
Unique usage	varDecs
unique var 	procAndFuncDecs
Unique usage	procAndFuncDecs
unique var 	labels
Unique usage	labels
unique var 	label
Unique usage	label
unique var 	label
Unique usage	label
unique var 	constDef
Unique usage	constDef
unique var 	constDef
Unique usage	constDef
unique var 	const
unique var 	typeDef
Unique usage	typeDef
unique var 	typeDef
Unique usage	typeDef
unique var 	type
unique var2 	newStructuredType
unique var2 	newPointerType
unique var2 	unpackedStructuredType
unique var2 	arrayType
unique var2 	recordType
unique var2 	setType
unique var2 	fileType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	fieldList
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	varDec
unique var 	varDec
unique var 	procDec
Unique usage	procDec
unique var 	funcDec
Unique usage	funcDec
unique var 	procHeading
Unique usage	procHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	funcHeading
Unique usage	funcHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	type
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	ids
unique var 	procHeading
Unique usage	procHeading
unique var 	funcHeading
Unique usage	funcHeading
unique var 	stmts
Unique usage	stmts
unique var 	stmt
unique var 	stmt
unique var2 	assignStmt
unique var2 	gotoStmt
unique var 	expr
unique var 	expr
unique var 	expr
unique var 	label
Unique usage	label
unique var2 	repetitiveStmt
unique var2 	withStmt
unique var2 	ifStmt
unique var 	expr
unique var 	stmt
unique var 	stmt
unique var2 	repeatStmt
unique var2 	whileStmt
unique var2 	forStmt
unique var 	stmts
Unique usage	stmts
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	var
unique var 	var
unique var 	stmt
unique var 	simpleExpr
Unique usage	simpleExpr
unique var 	term
Unique usage	term
unique var 	term
Unique usage	term
unique var 	factor
Unique usage	factor
unique var 	factor
Unique usage	factor
unique var 	unsignedConst
Unique usage	unsignedConst
unique var 	setConstructor
Unique usage	setConstructor
unique var 	expr
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	expr
unique var 	expr
foi true22
UniqueFlwVar	head	rule = 	program	pref = 	__SKIP	flw = 	__BEGIN, __CONST, __FUNCTION, __LABEL, __PROCEDURE, __TYPE, __VAR
UniqueFlwVar	decs	rule = 	program	pref = 	__Semi	flw = 	__BEGIN
UniqueFlwVar	block	rule = 	program	pref = 	__Semi, __empty	flw = 	__Dot
foi true22
foi true22
foi true22
passou três	labelDecs	decs
UniqueFlwVar	labelDecs	rule = 	decs	pref = 	__Semi	flw = 	__BEGIN, __CONST, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	constDefs	decs
UniqueFlwVar	constDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __TYPE, __VAR
passou três	typeDefs	decs
UniqueFlwVar	typeDefs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE, __VAR
UniqueFlwVar	varDecs	rule = 	decs	pref = 	__Semi, __empty	flw = 	__BEGIN, __FUNCTION, __PROCEDURE
passou três	procAndFuncDecs	decs
foi true22
UniqueFlwVar	labels	rule = 	labelDecs	pref = 	__LABEL	flw = 	__Semi
passou três	label	labels
UniqueFlwVar	label	rule = 	labels	pref = 	__LABEL	flw = 	__Comma, __Semi
foi true22
passou três	label	labels
foi true22
UniqueFlwVar	constDef	rule = 	constDefs	pref = 	__CONST	flw = 	__Semi
foi true22
UniqueFlwVar	typeDef	rule = 	typeDefs	pref = 	__TYPE	flw = 	__Semi
passou três	type	typeDef
foi true22
foi true22
foi true22
foi true22
foi true22
passou três	fieldList	recordType
UniqueFlwVar	fieldList	rule = 	recordType	pref = 	__RECORD	flw = 	__END
foi true22
foi true22
foi true22
foi true22
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__Semi	flw = 	__END, __RPar, __Semi
passou três	variantPart	fieldList
UniqueFlwVar	variantPart	rule = 	fieldList	pref = 	__LPar, __RECORD	flw = 	__END, __RPar, __Semi
passou três	varDec	varDecs
UniqueFlwVar	varDec	rule = 	varDecs	pref = 	__VAR	flw = 	__Semi
UniqueFlwVar	procDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	funcDec	rule = 	procAndFuncDecs	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	procHeading	rule = 	procDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	procDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	funcHeading	rule = 	funcDec	pref = 	__Semi, __empty	flw = 	__Semi
UniqueFlwVar	decs	rule = 	funcDec	pref = 	__Semi	flw = 	__BEGIN
foi true22
foi true22
UniqueFlwVar	formalParams	rule = 	funcHeading	pref = 	__Id	flw = 	__Colon
foi true22
passou três	stmts	block
UniqueFlwVar	stmts	rule = 	block	pref = 	__BEGIN	flw = 	__END
passou três	stmt	stmts
UniqueFlwVar	stmt	rule = 	stmts	pref = 	__BEGIN, __REPEAT	flw = 	__END, __Semi, __UNTIL
passou três	label	stmt
UniqueFlwVar	label	rule = 	stmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Colon
foi true22
UniqueFlwVar	var	rule = 	assignStmt	pref = 	__BEGIN, __Colon, __DO, __ELSE, __REPEAT, __Semi, __THEN	flw = 	__Assign
foi true22
foi true22
foi true22
passou três	label	gotoStmt
foi true22
passou três	expr	ifStmt
UniqueFlwVar	expr	rule = 	ifStmt	pref = 	__IF	flw = 	__THEN
foi true22
passou três	stmt	ifStmt
UniqueFlwVar	stmt	rule = 	ifStmt	pref = 	__THEN	flw = 	__ELSE, __END, __Semi, __UNTIL
foi true22
passou três	stmt	ifStmt
foi true22
passou três	stmts	repeatStmt
UniqueFlwVar	stmts	rule = 	repeatStmt	pref = 	__REPEAT	flw = 	__UNTIL
foi true22
passou três	expr	repeatStmt
foi true22
passou três	expr	whileStmt
UniqueFlwVar	expr	rule = 	whileStmt	pref = 	__WHILE	flw = 	__DO
foi true22
foi true22
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__Assign	flw = 	__DOWNTO, __TO
foi true22
foi true22
passou três	expr	forStmt
UniqueFlwVar	expr	rule = 	forStmt	pref = 	__DOWNTO, __TO	flw = 	__DO
foi true22
passou três	var	withStmt
UniqueFlwVar	var	rule = 	withStmt	pref = 	__WITH	flw = 	__Comma, __DO
foi true22
foi true22
foi true22
foi true22
foi true22
unique var 	head
Unique usage	head
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	ids
unique var 	labelDecs
Unique usage	labelDecs
unique var 	constDefs
Unique usage	constDefs
unique var 	typeDefs
Unique usage	typeDefs
unique var 	varDecs
Unique usage	varDecs
unique var 	procAndFuncDecs
Unique usage	procAndFuncDecs
unique var 	labels
Unique usage	labels
unique var 	label
Unique usage	label
unique var 	label
Unique usage	label
unique var 	constDef
Unique usage	constDef
unique var 	constDef
Unique usage	constDef
unique var 	const
unique var 	typeDef
Unique usage	typeDef
unique var 	typeDef
Unique usage	typeDef
unique var 	type
unique var2 	newStructuredType
unique var2 	newPointerType
unique var2 	unpackedStructuredType
unique var2 	arrayType
unique var2 	recordType
unique var2 	setType
unique var2 	fileType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	fieldList
unique var 	ordinalType
Unique usage	ordinalType
unique var 	type
unique var 	varDec
unique var 	varDec
unique var 	procDec
Unique usage	procDec
unique var 	funcDec
Unique usage	funcDec
unique var 	procHeading
Unique usage	procHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	funcHeading
Unique usage	funcHeading
unique var 	decs
Unique usage	decs
unique var 	block
unique var 	formalParams
Unique usage	formalParams
unique var 	type
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	formalParamsSection
Unique usage	formalParamsSection
unique var 	ids
unique var 	procHeading
Unique usage	procHeading
unique var 	funcHeading
Unique usage	funcHeading
unique var 	stmts
Unique usage	stmts
unique var 	stmt
unique var 	stmt
unique var2 	assignStmt
unique var2 	gotoStmt
unique var 	expr
unique var 	expr
unique var 	expr
unique var 	label
Unique usage	label
unique var2 	repetitiveStmt
unique var2 	withStmt
unique var2 	ifStmt
unique var 	expr
unique var 	stmt
unique var 	stmt
unique var2 	repeatStmt
unique var2 	whileStmt
unique var2 	forStmt
unique var 	stmts
Unique usage	stmts
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	expr
unique var 	expr
unique var 	stmt
unique var 	var
unique var 	var
unique var 	stmt
unique var 	simpleExpr
Unique usage	simpleExpr
unique var 	term
Unique usage	term
unique var 	term
Unique usage	term
unique var 	factor
Unique usage	factor
unique var 	factor
Unique usage	factor
unique var 	unsignedConst
Unique usage	unsignedConst
unique var 	setConstructor
Unique usage	setConstructor
unique var 	expr
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	memberDesignator
Unique usage	memberDesignator
unique var 	expr
unique var 	expr
insideLoop: ids, label, constDef, typeDef, fixedPart, variantPart, varDec, procDec, procHeading, funcDec, funcHeading, formalParams, block, simpleStmt, assignStmt, var, procStmt, params, param, gotoStmt, structuredStmt, conditionalStmt, ifStmt, caseStmt, repetitiveStmt, repeatStmt, whileStmt, forStmt, withStmt, expr, simpleExpr, term, factor, unsignedConst, funcCall, setConstructor, memberDesignator, 
Unique vars: program, head, decs, labelDecs, labels, label, constDefs, constDef, typeDefs, typeDef, ordinalType, varDecs, procAndFuncDecs, procDec, procHeading, funcDec, funcHeading, formalParams, formalParamsSection, stmts, simpleExpr, term, factor, unsignedConst, setConstructor, memberDesignator, 
matchUPath: program, head, decs, labels, label, constDef, typeDef, newStructuredType, newPointerType, unpackedStructuredType, arrayType, recordType, setType, fileType, ordinalType, procDec, procHeading, funcDec, funcHeading, formalParams, formalParamsSection, block, stmts, stmt, assignStmt, gotoStmt, ifStmt, repetitiveStmt, repeatStmt, whileStmt, forStmt, withStmt, expr, simpleExpr, term, factor, unsignedConst, setConstructor, memberDesignator, 
Adding labels: Err_1, Err_2, Err_3, Err_4, Err_5, Err_6, Err_7, Err_8, Err_9, Err_10, Err_11, Err_12, Err_13, Err_14, Err_15, Err_16, Err_17, Err_18, Err_19, Err_20, Err_21, Err_22, Err_23, Err_24, Err_25, Err_26, Err_27, Err_28, Err_29, Err_30, Err_31, Err_32, Err_33, Err_34, Err_35, Err_36, Err_37, Err_38, Err_39, Err_40, Err_41, Err_42, Err_43, Err_44, Err_45, Err_46, Err_47, Err_48, Err_49, Err_50, Err_51, Err_52, Err_53, Err_54, Err_55, Err_56, Err_57, Err_58, Err_59, Err_60, Err_61, Err_62, Err_63, Err_64, Err_65, Err_66, Err_67, Err_68, Err_69, Err_70, Err_71, Err_72, Err_73, Err_74, Err_75, Err_76, Err_77, Err_78, Err_79, Err_80, Err_81, Err_82, Err_83, Err_84, Err_85, 

Property 	nil
program         <-  SKIP head^Err_001 decs block^Err_002 Dot^Err_003 !.
head            <-  PROGRAM^Err_004 Id^Err_005 (LPar ids^Err_006 RPar^Err_007)? Semi^Err_008
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL labels^Err_009 Semi^Err_010)?
labels          <-  label^Err_011 (Comma label^Err_012)*
label           <-  UInt
constDefs       <-  (CONST constDef^Err_013 Semi^Err_014 (constDef Semi^Err_015)*)?
constDef        <-  Id Eq^Err_016 const^Err_017
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE typeDef^Err_018 Semi^Err_019 (typeDef Semi^Err_020)*)?
typeDef         <-  Id Eq^Err_021 type^Err_022
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer Id^Err_023
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_024 ordinalType^Err_025 (Comma ordinalType^Err_026)* RBrack^Err_027 OF^Err_028 type^Err_029
recordType      <-  RECORD fieldList END^Err_030
setType         <-  SET OF^Err_031 ordinalType^Err_032
fileType        <-  FILE OF^Err_033 type^Err_034
ordinalType     <-  (newOrdinalType  /  Id)^Err_035
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec^Err_036 Semi^Err_037 (varDec Semi^Err_038)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_039)*
procDec         <-  procHeading Semi^Err_040 (decs block  /  Id)^Err_041
procHeading     <-  PROCEDURE Id^Err_042 formalParams?
funcDec         <-  funcHeading Semi^Err_043 (decs block  /  Id)^Err_044
funcHeading     <-  FUNCTION Id^Err_045 formalParams? Colon^Err_046 type^Err_047
formalParams    <-  LPar formalParamsSection^Err_048 (Semi formalParamsSection^Err_049)* RPar^Err_050
formalParamsSection <-  (VAR? ids Colon^Err_051 Id^Err_052  /  procHeading  /  funcHeading)^Err_053
block           <-  BEGIN stmts END^Err_054
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon^Err_055)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr^Err_056
var             <-  Id (LBrack expr^Err_057 (Comma expr^Err_058)* RBrack^Err_059  /  Dot Id^Err_060  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param^Err_061)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_062
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_063 THEN^Err_064 stmt (ELSE stmt)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_065 expr^Err_066
whileStmt       <-  WHILE expr^Err_067 DO^Err_068 stmt
forStmt         <-  FOR Id^Err_069 Assign^Err_070 expr^Err_071 (TO  /  DOWNTO)^Err_072 expr^Err_073 DO^Err_074 stmt
withStmt        <-  WITH var^Err_075 (Comma var^Err_076)* DO^Err_077 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_078)?
simpleExpr      <-  Sign? term (AddOp term^Err_079)*
term            <-  factor (MultOp factor^Err_080)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr^Err_081 RPar^Err_082)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator^Err_083)*)? RBrack^Err_084
memberDesignator <-  expr (DotDot expr^Err_085)?
AddOp           <-  '+'  /  '-'  /  OR
Assign          <-  ':='
Dot             <-  '.'
DotDot          <-  '..'
CloseComment    <-  '*)'  /  '}'
Colon           <-  ':'
Comma           <-  ','
COMMENT         <-  OpenComment (!CloseComment .)* CloseComment
Eq              <-  '='
BodyId          <-  [a-zA-Z0-9]
Id              <-  !Reserved [a-zA-Z] [a-zA-Z0-9]*
LBrack          <-  '['
LPar            <-  '('
MultOp          <-  '*'  /  '/'  /  DIV  /  MOD  /  AND
OpenComment     <-  '(*'  /  '{'
Pointer         <-  '^'
RBrack          <-  ']'
RelOp           <-  '<='  /  '='  /  '<>'  /  '>='  /  '>'  /  '<'  /  IN
RPar            <-  ')'
Semi            <-  ';'
Sign            <-  '+'  /  '-'
String          <-  "'" (!"'" .)* "'"
UInt            <-  [0-9]+
UNumber         <-  UReal  /  UInt
UReal           <-  [0-9]+ ('.' [0-9]+ ([Ee] ('+'  /  '-') [0-9]+)?  /  [Ee] ('+'  /  '-') [0-9]+)
Reserved        <-  AND  /  ARRAY  /  BEGIN  /  CONST  /  CASE  /  DIV  /  DO  /  DOWNTO  /  ELSE  /  END  /  FILE  /  FOR  /  FUNCTION  /  GOTO  /  IF  /  IN  /  LABEL  /  MOD  /  NIL  /  NOT  /  OF  /  OR  /  PACKED  /  PROCEDURE  /  PROGRAM  /  RECORD  /  REPEAT  /  SET  /  THEN  /  TO  /  TYPE  /  UNTIL  /  VAR  /  WHILE  /  WITH
AND             <-  [Aa] [Nn] [Dd] !BodyId
ARRAY           <-  [Aa] [Rr] [Rr] [Aa] [Yy] !BodyId
BEGIN           <-  [Bb] [Ee] [Gg] [Ii] [Nn] !BodyId
CASE            <-  [Cc] [Aa] [Ss] [Ee] !BodyId
CONST           <-  [Cc] [Oo] [Nn] [Ss] [Tt] !BodyId
DIV             <-  [Dd] [Ii] [Vv] !BodyId
DO              <-  [Dd] [Oo] !BodyId
DOWNTO          <-  [Dd] [Oo] [Ww] [Nn] [Tt] [Oo] !BodyId
ELSE            <-  [Ee] [Ll] [Ss] [Ee] !BodyId
END             <-  [Ee] [Nn] [Dd] !BodyId
FILE            <-  [Ff] [Ii] [Ll] [Ee] !BodyId
FOR             <-  [Ff] [Oo] [Rr] !BodyId
FUNCTION        <-  [Ff] [Uu] [Nn] [Cc] [Tt] [Ii] [Oo] [Nn] !BodyId
GOTO            <-  [Gg] [Oo] [Tt] [Oo] !BodyId
IF              <-  [Ii] [Ff] !BodyId
IN              <-  [Ii] [Nn] !BodyId
LABEL           <-  [Ll] [Aa] [Bb] [Ee] [Ll] !BodyId
MOD             <-  [Mm] [Oo] [Dd] !BodyId
NIL             <-  [Nn] [Ii] [Ll] !BodyId
NOT             <-  [Nn] [Oo] [Tt] !BodyId
OF              <-  [Oo] [Ff] !BodyId
OR              <-  [Oo] [Rr] !BodyId
PACKED          <-  [Pp] [Aa] [Cc] [Kk] [Ee] [Dd] !BodyId
PROCEDURE       <-  [Pp] [Rr] [Oo] [Cc] [Ee] [Dd] [Uu] [Rr] [Ee] !BodyId
PROGRAM         <-  [Pp] [Rr] [Oo] [Gg] [Rr] [Aa] [Mm] !BodyId
RECORD          <-  [Rr] [Ee] [Cc] [Oo] [Rr] [Dd] !BodyId
REPEAT          <-  [Rr] [Ee] [Pp] [Ee] [Aa] [Tt] !BodyId
SET             <-  [Ss] [Ee] [Tt] !BodyId
THEN            <-  [Tt] [Hh] [Ee] [Nn] !BodyId
TO              <-  [Tt] [Oo] !BodyId
TYPE            <-  [Tt] [Yy] [Pp] [Ee] !BodyId
UNTIL           <-  [Uu] [Nn] [Tt] [Ii] [Ll] !BodyId
VAR             <-  [Vv] [Aa] [Rr] !BodyId
WHILE           <-  [Ww] [Hh] [Ii] [Ll] [Ee] !BodyId
WITH            <-  [Ww] [Ii] [Tt] [Hh] !BodyId
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  WITH  /  WHILE  /  VAR  /  UReal  /  UNumber  /  UNTIL  /  UInt  /  TYPE  /  TO  /  THEN  /  String  /  Sign  /  Semi  /  SET  /  Reserved  /  RelOp  /  RPar  /  REPEAT  /  RECORD  /  RBrack  /  Pointer  /  PROGRAM  /  PROCEDURE  /  PACKED  /  OpenComment  /  OR  /  OF  /  NOT  /  NIL  /  MultOp  /  MOD  /  LPar  /  LBrack  /  LABEL  /  Id  /  IN  /  IF  /  GOTO  /  FUNCTION  /  FOR  /  FILE  /  Eq  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  DIV  /  Comma  /  Colon  /  CloseComment  /  CONST  /  COMMENT  /  CASE  /  BodyId  /  BEGIN  /  Assign  /  AddOp  /  ARRAY  /  AND
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_002         <-  (!Dot EatToken)*
Err_003         <-  (!(!.) EatToken)*
Err_004         <-  (!Id EatToken)*
Err_005         <-  (!(Semi  /  LPar) EatToken)*
Err_006         <-  (!RPar EatToken)*
Err_007         <-  (!Semi EatToken)*
Err_008         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_009         <-  (!Semi EatToken)*
Err_010         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_011         <-  (!(Semi  /  Comma) EatToken)*
Err_012         <-  (!(Semi  /  Comma) EatToken)*
Err_013         <-  (!Semi EatToken)*
Err_014         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_015         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_016         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_017         <-  (!Semi EatToken)*
Err_018         <-  (!Semi EatToken)*
Err_019         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_020         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_021         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_022         <-  (!Semi EatToken)*
Err_023         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_024         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_025         <-  (!(RBrack  /  Comma) EatToken)*
Err_026         <-  (!(RBrack  /  Comma) EatToken)*
Err_027         <-  (!OF EatToken)*
Err_028         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_029         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_030         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_031         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_032         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_033         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_034         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_035         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_036         <-  (!Semi EatToken)*
Err_037         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_038         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_039         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_040         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_041         <-  (!Semi EatToken)*
Err_042         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_043         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_044         <-  (!Semi EatToken)*
Err_045         <-  (!(LPar  /  Colon) EatToken)*
Err_046         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_047         <-  (!(Semi  /  RPar) EatToken)*
Err_048         <-  (!(Semi  /  RPar) EatToken)*
Err_049         <-  (!(Semi  /  RPar) EatToken)*
Err_050         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_051         <-  (!Id EatToken)*
Err_052         <-  (!(Semi  /  RPar) EatToken)*
Err_053         <-  (!(Semi  /  RPar) EatToken)*
Err_054         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_055         <-  (!(WITH  /  WHILE  /  UNTIL  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_056         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_057         <-  (!(RBrack  /  Comma) EatToken)*
Err_058         <-  (!(RBrack  /  Comma) EatToken)*
Err_059         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_060         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_061         <-  (!(RPar  /  Comma) EatToken)*
Err_062         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_063         <-  (!THEN EatToken)*
Err_064         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_065         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_066         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_067         <-  (!DO EatToken)*
Err_068         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_069         <-  (!Assign EatToken)*
Err_070         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_071         <-  (!(TO  /  DOWNTO) EatToken)*
Err_072         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_073         <-  (!DO EatToken)*
Err_074         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_075         <-  (!(DO  /  Comma) EatToken)*
Err_076         <-  (!(DO  /  Comma) EatToken)*
Err_077         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_078         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_079         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_080         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_081         <-  (!RPar EatToken)*
Err_082         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_083         <-  (!(RBrack  /  Comma) EatToken)*
Err_084         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_085         <-  (!(RBrack  /  Comma) EatToken)*	

Property 	unique
program         <-  SKIP_unique head_unique^Err_001 decs_unique block_unique^Err_002 Dot_unique^Err_003 !.
head            <-  PROGRAM_unique^Err_004 Id_unique^Err_005 (LPar_unique ids_unique^Err_006 RPar_unique^Err_007)?_unique Semi_unique^Err_008
decs            <-  labelDecs_unique constDefs_unique typeDefs_unique varDecs_unique procAndFuncDecs_unique
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL_unique labels_unique^Err_009 Semi_unique^Err_010)?_unique
labels          <-  label_unique^Err_011 (Comma_unique label_unique^Err_012)*_unique
label           <-  UInt_unique
constDefs       <-  (CONST_unique constDef_unique^Err_013 Semi_unique^Err_014 (constDef_unique Semi_unique^Err_015)*_unique)?_unique
constDef        <-  Id_unique Eq_unique^Err_016 const_unique^Err_017
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE_unique typeDef_unique^Err_018 Semi_unique^Err_019 (typeDef_unique Semi_unique^Err_020)*_unique)?_unique
typeDef         <-  Id_unique Eq_unique^Err_021 type_unique^Err_022
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  (newStructuredType_unique  /  newPointerType_unique)_unique
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED_unique? unpackedStructuredType_unique
newPointerType  <-  Pointer_unique Id_unique^Err_023
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  (arrayType_unique  /  (recordType_unique  /  (setType_unique  /  fileType_unique)_unique)_unique)_unique
arrayType       <-  ARRAY_unique LBrack_unique^Err_024 ordinalType_unique^Err_025 (Comma_unique ordinalType_unique^Err_026)*_unique RBrack_unique^Err_027 OF_unique^Err_028 type_unique^Err_029
recordType      <-  RECORD_unique fieldList_unique END_unique^Err_030
setType         <-  SET_unique OF_unique^Err_031 ordinalType_unique^Err_032
fileType        <-  FILE_unique OF_unique^Err_033 type_unique^Err_034
ordinalType     <-  ((newOrdinalType  /  Id_unique)_unique)^Err_035
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart_unique) Semi?_unique)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR_unique varDec_unique^Err_036 Semi_unique^Err_037 (varDec_unique Semi_unique^Err_038)*_unique)?_unique
varDec          <-  ids Colon type
procAndFuncDecs <-  (((procDec_unique  /  funcDec_unique)_unique) Semi_unique^Err_039)*_unique
procDec         <-  procHeading_unique Semi_unique^Err_040 ((decs_unique block_unique  /  Id_unique)_unique)^Err_041
procHeading     <-  PROCEDURE_unique Id_unique^Err_042 formalParams_unique?_unique
funcDec         <-  funcHeading_unique Semi_unique^Err_043 ((decs_unique block_unique  /  Id_unique)_unique)^Err_044
funcHeading     <-  FUNCTION_unique Id_unique^Err_045 formalParams_unique?_unique Colon_unique^Err_046 type_unique^Err_047
formalParams    <-  LPar_unique formalParamsSection_unique^Err_048 (Semi_unique formalParamsSection_unique^Err_049)*_unique RPar_unique^Err_050
formalParamsSection <-  ((VAR_unique?_unique ids_unique Colon_unique^Err_051 Id_unique^Err_052  /  (procHeading_unique  /  funcHeading_unique)_unique)_unique)^Err_053
block           <-  BEGIN_unique stmts_unique END_unique^Err_054
stmts           <-  stmt_unique (Semi_unique stmt_unique)*_unique
stmt            <-  (label_unique Colon_unique^Err_055)? (simpleStmt  /  structuredStmt)?_unique
simpleStmt      <-  assignStmt_unique  /  procStmt  /  gotoStmt_unique
assignStmt      <-  var Assign_unique expr_unique^Err_056
var             <-  Id ((LBrack_unique expr_unique^Err_057 (Comma_unique expr_unique^Err_058)*_unique RBrack_unique^Err_059  /  (Dot_unique Id_unique^Err_060  /  Pointer_unique)_unique)_unique)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param^Err_061)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO_unique label_unique^Err_062
structuredStmt  <-  block  /  conditionalStmt  /  (repetitiveStmt_unique  /  withStmt_unique)_unique
conditionalStmt <-  ifStmt_unique  /  caseStmt
ifStmt          <-  IF_unique expr_unique^Err_063 THEN_unique^Err_064 stmt_unique (ELSE_unique stmt_unique)?_unique
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  (repeatStmt_unique  /  (whileStmt_unique  /  forStmt_unique)_unique)_unique
repeatStmt      <-  REPEAT_unique stmts_unique UNTIL_unique^Err_065 expr_unique^Err_066
whileStmt       <-  WHILE_unique expr_unique^Err_067 DO_unique^Err_068 stmt_unique
forStmt         <-  FOR_unique Id_unique^Err_069 Assign_unique^Err_070 expr_unique^Err_071 ((TO_unique  /  DOWNTO_unique)_unique)^Err_072 expr_unique^Err_073 DO_unique^Err_074 stmt_unique
withStmt        <-  WITH_unique var_unique^Err_075 (Comma_unique var_unique^Err_076)*_unique DO_unique^Err_077 stmt_unique
expr            <-  simpleExpr_unique (RelOp_unique simpleExpr_unique^Err_078)?_unique
simpleExpr      <-  Sign_unique?_unique term_unique (AddOp_unique term_unique^Err_079)*_unique
term            <-  factor_unique (MultOp_unique factor_unique^Err_080)*_unique
factor          <-  NOT_unique*_unique ((funcCall  /  (var  /  (unsignedConst_unique  /  (setConstructor_unique  /  LPar_unique expr_unique^Err_081 RPar_unique^Err_082)_unique)_unique)_unique)_unique)
unsignedConst   <-  (UNumber_unique  /  (String_unique  /  (Id_unique  /  NIL_unique)_unique)_unique)_unique
funcCall        <-  Id params
setConstructor  <-  LBrack_unique (memberDesignator_unique (Comma_unique memberDesignator_unique^Err_083)*_unique)?_unique RBrack_unique^Err_084
memberDesignator <-  expr_unique (DotDot_unique expr_unique^Err_085)?_unique
AddOp           <-  '+'  /  '-'  /  OR
Assign          <-  ':='
Dot             <-  '.'
DotDot          <-  '..'
CloseComment    <-  '*)'  /  '}'
Colon           <-  ':'
Comma           <-  ','
COMMENT         <-  OpenComment (!CloseComment .)* CloseComment
Eq              <-  '='
BodyId          <-  [a-zA-Z0-9]
Id              <-  !Reserved [a-zA-Z] [a-zA-Z0-9]*
LBrack          <-  '['
LPar            <-  '('
MultOp          <-  '*'  /  '/'  /  DIV  /  MOD  /  AND
OpenComment     <-  '(*'  /  '{'
Pointer         <-  '^'
RBrack          <-  ']'
RelOp           <-  '<='  /  '='  /  '<>'  /  '>='  /  '>'  /  '<'  /  IN
RPar            <-  ')'
Semi            <-  ';'
Sign            <-  '+'  /  '-'
String          <-  "'" (!"'" .)* "'"
UInt            <-  [0-9]+
UNumber         <-  UReal  /  UInt
UReal           <-  [0-9]+ ('.' [0-9]+ ([Ee] ('+'  /  '-') [0-9]+)?  /  [Ee] ('+'  /  '-') [0-9]+)
Reserved        <-  AND  /  ARRAY  /  BEGIN  /  CONST  /  CASE  /  DIV  /  DO  /  DOWNTO  /  ELSE  /  END  /  FILE  /  FOR  /  FUNCTION  /  GOTO  /  IF  /  IN  /  LABEL  /  MOD  /  NIL  /  NOT  /  OF  /  OR  /  PACKED  /  PROCEDURE  /  PROGRAM  /  RECORD  /  REPEAT  /  SET  /  THEN  /  TO  /  TYPE  /  UNTIL  /  VAR  /  WHILE  /  WITH
AND             <-  [Aa] [Nn] [Dd] !BodyId
ARRAY           <-  [Aa] [Rr] [Rr] [Aa] [Yy] !BodyId
BEGIN           <-  [Bb] [Ee] [Gg] [Ii] [Nn] !BodyId
CASE            <-  [Cc] [Aa] [Ss] [Ee] !BodyId
CONST           <-  [Cc] [Oo] [Nn] [Ss] [Tt] !BodyId
DIV             <-  [Dd] [Ii] [Vv] !BodyId
DO              <-  [Dd] [Oo] !BodyId
DOWNTO          <-  [Dd] [Oo] [Ww] [Nn] [Tt] [Oo] !BodyId
ELSE            <-  [Ee] [Ll] [Ss] [Ee] !BodyId
END             <-  [Ee] [Nn] [Dd] !BodyId
FILE            <-  [Ff] [Ii] [Ll] [Ee] !BodyId
FOR             <-  [Ff] [Oo] [Rr] !BodyId
FUNCTION        <-  [Ff] [Uu] [Nn] [Cc] [Tt] [Ii] [Oo] [Nn] !BodyId
GOTO            <-  [Gg] [Oo] [Tt] [Oo] !BodyId
IF              <-  [Ii] [Ff] !BodyId
IN              <-  [Ii] [Nn] !BodyId
LABEL           <-  [Ll] [Aa] [Bb] [Ee] [Ll] !BodyId
MOD             <-  [Mm] [Oo] [Dd] !BodyId
NIL             <-  [Nn] [Ii] [Ll] !BodyId
NOT             <-  [Nn] [Oo] [Tt] !BodyId
OF              <-  [Oo] [Ff] !BodyId
OR              <-  [Oo] [Rr] !BodyId
PACKED          <-  [Pp] [Aa] [Cc] [Kk] [Ee] [Dd] !BodyId
PROCEDURE       <-  [Pp] [Rr] [Oo] [Cc] [Ee] [Dd] [Uu] [Rr] [Ee] !BodyId
PROGRAM         <-  [Pp] [Rr] [Oo] [Gg] [Rr] [Aa] [Mm] !BodyId
RECORD          <-  [Rr] [Ee] [Cc] [Oo] [Rr] [Dd] !BodyId
REPEAT          <-  [Rr] [Ee] [Pp] [Ee] [Aa] [Tt] !BodyId
SET             <-  [Ss] [Ee] [Tt] !BodyId
THEN            <-  [Tt] [Hh] [Ee] [Nn] !BodyId
TO              <-  [Tt] [Oo] !BodyId
TYPE            <-  [Tt] [Yy] [Pp] [Ee] !BodyId
UNTIL           <-  [Uu] [Nn] [Tt] [Ii] [Ll] !BodyId
VAR             <-  [Vv] [Aa] [Rr] !BodyId
WHILE           <-  [Ww] [Hh] [Ii] [Ll] [Ee] !BodyId
WITH            <-  [Ww] [Ii] [Tt] [Hh] !BodyId
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  WITH  /  WHILE  /  VAR  /  UReal  /  UNumber  /  UNTIL  /  UInt  /  TYPE  /  TO  /  THEN  /  String  /  Sign  /  Semi  /  SET  /  Reserved  /  RelOp  /  RPar  /  REPEAT  /  RECORD  /  RBrack  /  Pointer  /  PROGRAM  /  PROCEDURE  /  PACKED  /  OpenComment  /  OR  /  OF  /  NOT  /  NIL  /  MultOp  /  MOD  /  LPar  /  LBrack  /  LABEL  /  Id  /  IN  /  IF  /  GOTO  /  FUNCTION  /  FOR  /  FILE  /  Eq  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  DIV  /  Comma  /  Colon  /  CloseComment  /  CONST  /  COMMENT  /  CASE  /  BodyId  /  BEGIN  /  Assign  /  AddOp  /  ARRAY  /  AND
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_002         <-  (!Dot EatToken)*
Err_003         <-  (!(!.) EatToken)*
Err_004         <-  (!Id EatToken)*
Err_005         <-  (!(Semi  /  LPar) EatToken)*
Err_006         <-  (!RPar EatToken)*
Err_007         <-  (!Semi EatToken)*
Err_008         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_009         <-  (!Semi EatToken)*
Err_010         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_011         <-  (!(Semi  /  Comma) EatToken)*
Err_012         <-  (!(Semi  /  Comma) EatToken)*
Err_013         <-  (!Semi EatToken)*
Err_014         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_015         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_016         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_017         <-  (!Semi EatToken)*
Err_018         <-  (!Semi EatToken)*
Err_019         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_020         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_021         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_022         <-  (!Semi EatToken)*
Err_023         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_024         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_025         <-  (!(RBrack  /  Comma) EatToken)*
Err_026         <-  (!(RBrack  /  Comma) EatToken)*
Err_027         <-  (!OF EatToken)*
Err_028         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_029         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_030         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_031         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_032         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_033         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_034         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_035         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_036         <-  (!Semi EatToken)*
Err_037         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_038         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_039         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_040         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_041         <-  (!Semi EatToken)*
Err_042         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_043         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_044         <-  (!Semi EatToken)*
Err_045         <-  (!(LPar  /  Colon) EatToken)*
Err_046         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_047         <-  (!(Semi  /  RPar) EatToken)*
Err_048         <-  (!(Semi  /  RPar) EatToken)*
Err_049         <-  (!(Semi  /  RPar) EatToken)*
Err_050         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_051         <-  (!Id EatToken)*
Err_052         <-  (!(Semi  /  RPar) EatToken)*
Err_053         <-  (!(Semi  /  RPar) EatToken)*
Err_054         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_055         <-  (!(WITH  /  WHILE  /  UNTIL  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_056         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_057         <-  (!(RBrack  /  Comma) EatToken)*
Err_058         <-  (!(RBrack  /  Comma) EatToken)*
Err_059         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_060         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_061         <-  (!(RPar  /  Comma) EatToken)*
Err_062         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_063         <-  (!THEN EatToken)*
Err_064         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_065         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_066         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_067         <-  (!DO EatToken)*
Err_068         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_069         <-  (!Assign EatToken)*
Err_070         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_071         <-  (!(TO  /  DOWNTO) EatToken)*
Err_072         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_073         <-  (!DO EatToken)*
Err_074         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_075         <-  (!(DO  /  Comma) EatToken)*
Err_076         <-  (!(DO  /  Comma) EatToken)*
Err_077         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_078         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_079         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_080         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_081         <-  (!RPar EatToken)*
Err_082         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_083         <-  (!(RBrack  /  Comma) EatToken)*
Err_084         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_085         <-  (!(RBrack  /  Comma) EatToken)*	

End UPath

Yes: 	HelloWorld.pas
Yes: 	PlayingWithDice.pas
Yes: 	Teste.pas
Yes: 	aprovado.pas
Yes: 	bubble.pas
Yes: 	cubo.pas
Yes: 	gasolina.pas
Yes: 	maior.pas
Yes: 	operators.pas
Yes: 	posneg.pas
Yes: 	quadrado.pas
Yes: 	quick.pas
Yes: 	retangulo.pas
Yes: 	sched.pas
Yes: 	somaEProduto.pas
Yes: 	somaParImpar.pas
Yes: 	triangulo.pas
No: 	AssignErr.pas
r = nil lab = fail line: 4 col: 8
No: 	BeginErr.pas
r = nil lab = fail line: 4 col: 1
No: 	ColonErr1.pas
r = nil lab = fail line: 4 col: 33
No: 	ColonErr2.pas
r = nil lab = fail line: 4 col: 7
No: 	ColonErr3.pas
r = nil lab = fail line: 3 col: 12
No: 	ColonErr4.pas
r = nil lab = fail line: 3 col: 15
No: 	ColonErr5.pas
r = nil lab = fail line: 4 col: 4
No: 	ColonErr6.pas
r = nil lab = fail line: 5 col: 5
No: 	ConstErr1.pas
r = nil lab = fail line: 4 col: 7
No: 	ConstErr2.pas
r = nil lab = fail line: 4 col: 13
No: 	ConstErr3.pas
r = nil lab = fail line: 4 col: 31
No: 	ConstErr4.pas
r = nil lab = fail line: 4 col: 34
No: 	ConstErr5.pas
r = nil lab = fail line: 5 col: 3
No: 	DoErr1.pas
r = nil lab = fail line: 5 col: 1
No: 	DoErr2.pas
r = nil lab = fail line: 5 col: 1
No: 	DoErr3.pas
r = nil lab = fail line: 4 col: 9
No: 	DotErr.pas
r = nil lab = fail line: 5 col: 3
No: 	EndErr1.pas
r = nil lab = fail line: 4 col: 27
No: 	EndErr2.pas
r = nil lab = fail line: 5 col: 4
No: 	EndErr3.pas
r = nil lab = fail line: 6 col: 5
No: 	EndInputErr.pas
r = nil lab = fail line: 7 col: 1
No: 	EqErr1.pas
r = nil lab = fail line: 4 col: 4
No: 	EqErr2.pas
r = nil lab = fail line: 4 col: 4
No: 	ExprErr1.pas
r = nil lab = fail line: 4 col: 7
No: 	ExprErr10.pas
r = nil lab = fail line: 4 col: 20
No: 	ExprErr11.pas
r = nil lab = fail line: 4 col: 12
No: 	ExprErr12.pas
r = nil lab = fail line: 4 col: 11
No: 	ExprErr13.pas
r = nil lab = fail line: 4 col: 15
No: 	ExprErr2.pas
r = nil lab = fail line: 4 col: 4
No: 	ExprErr3.pas
r = nil lab = fail line: 4 col: 7
No: 	ExprErr4.pas
r = nil lab = fail line: 4 col: 12
No: 	ExprErr5.pas
r = nil lab = fail line: 4 col: 5
No: 	ExprErr6.pas
r = nil lab = fail line: 4 col: 7
No: 	ExprErr7.pas
r = nil lab = fail line: 6 col: 8
No: 	ExprErr8.pas
r = nil lab = fail line: 4 col: 8
No: 	ExprErr9.pas
r = nil lab = fail line: 4 col: 11
No: 	FactorErr.pas
r = nil lab = fail line: 4 col: 11
No: 	FormalParamErr1.pas
r = nil lab = fail line: 3 col: 13
No: 	FormalParamErr2.pas
r = nil lab = fail line: 3 col: 23
No: 	FuncBodyErr.pas
r = nil lab = fail line: 4 col: 4
No: 	IdErr1.pas
r = nil lab = fail line: 1 col: 22
No: 	IdErr10.pas
r = nil lab = fail line: 3 col: 17
No: 	IdErr11.pas
r = nil lab = fail line: 4 col: 4
No: 	IdErr12.pas
r = nil lab = fail line: 4 col: 6
No: 	IdErr2.pas
r = nil lab = fail line: 4 col: 2
No: 	IdErr3.pas
r = nil lab = fail line: 4 col: 2
No: 	IdErr4.pas
r = nil lab = fail line: 4 col: 7
No: 	IdErr5.pas
r = nil lab = fail line: 4 col: 11
No: 	IdErr6.pas
r = nil lab = fail line: 4 col: 22
No: 	IdErr7.pas
r = nil lab = fail line: 4 col: 26
No: 	IdErr8.pas
r = nil lab = fail line: 3 col: 11
No: 	IdErr9.pas
r = nil lab = fail line: 3 col: 10
No: 	LBrackErr.pas
r = nil lab = fail line: 4 col: 12
No: 	LParErr.pas
r = nil lab = fail line: 7 col: 12
No: 	LabelErr1.pas
r = nil lab = fail line: 4 col: 2
No: 	LabelErr2.pas
r = nil lab = fail line: 4 col: 5
No: 	LabelErr3.pas
r = nil lab = fail line: 4 col: 7
No: 	OfErr1.pas
r = nil lab = fail line: 4 col: 19
No: 	OfErr2.pas
r = nil lab = fail line: 4 col: 10
No: 	OfErr3.pas
r = nil lab = fail line: 4 col: 11
No: 	OfErr4.pas
r = nil lab = fail line: 4 col: 29
No: 	OfErr5.pas
r = nil lab = fail line: 4 col: 11
No: 	OrdinalTypeErr1.pas
r = nil lab = fail line: 4 col: 13
No: 	OrdinalTypeErr2.pas
r = nil lab = fail line: 4 col: 19
No: 	OrdinalTypeErr3.pas
r = nil lab = fail line: 4 col: 14
No: 	ProcBodyErr.pas
r = nil lab = fail line: 4 col: 4
No: 	ProgErr.pas
r = nil lab = fail line: 1 col: 5
No: 	ProgNameErr.pas
r = nil lab = fail line: 1 col: 9
No: 	RBrackErr1.pas
r = nil lab = fail line: 4 col: 18
No: 	RBrackErr2.pas
r = nil lab = fail line: 4 col: 9
No: 	RBrackErr3.pas
r = nil lab = fail line: 4 col: 12
No: 	RParErr1.pas
r = nil lab = fail line: 1 col: 27
No: 	RParErr2.pas
r = nil lab = fail line: 4 col: 18
No: 	RParErr3.pas
r = nil lab = fail line: 7 col: 5
No: 	RParErr4.pas
r = nil lab = fail line: 3 col: 20
No: 	RParErr5.pas
r = nil lab = fail line: 5 col: 1
No: 	RParErr6.pas
r = nil lab = fail line: 4 col: 19
No: 	RealParamErr.pas
r = nil lab = fail line: 4 col: 12
No: 	SemiErr1.pas
r = nil lab = fail line: 3 col: 1
No: 	SemiErr10.pas
r = nil lab = fail line: 4 col: 1
No: 	SemiErr11.pas
r = nil lab = fail line: 4 col: 1
No: 	SemiErr2.pas
r = nil lab = fail line: 6 col: 1
No: 	SemiErr3.pas
r = nil lab = fail line: 6 col: 1
No: 	SemiErr4.pas
r = nil lab = fail line: 7 col: 1
No: 	SemiErr5.pas
r = nil lab = fail line: 5 col: 2
No: 	SemiErr6.pas
r = nil lab = fail line: 7 col: 1
No: 	SemiErr7.pas
r = nil lab = fail line: 4 col: 9
No: 	SemiErr8.pas
r = nil lab = fail line: 6 col: 1
No: 	SemiErr9.pas
r = nil lab = fail line: 8 col: 1
No: 	SimpleExprErr.pas
r = nil lab = fail line: 5 col: 1
No: 	TermErr.pas
r = nil lab = fail line: 4 col: 11
No: 	ThenErr.pas
r = nil lab = fail line: 5 col: 1
No: 	ToDownToErr.pas
r = nil lab = fail line: 4 col: 14
No: 	TypeErr1.pas
r = nil lab = fail line: 4 col: 10
No: 	TypeErr2.pas
r = nil lab = fail line: 4 col: 23
No: 	TypeErr3.pas
r = nil lab = fail line: 4 col: 18
No: 	TypeErr4.pas
r = nil lab = fail line: 4 col: 7
No: 	TypeErr5.pas
r = nil lab = fail line: 3 col: 15
No: 	UntilErr.pas
r = nil lab = fail line: 6 col: 6
No: 	VarErr1.pas
r = nil lab = fail line: 4 col: 7
No: 	VarErr2.pas
r = nil lab = fail line: 4 col: 10

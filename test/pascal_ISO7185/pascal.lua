local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'

g = [[
	program 				<- head decs block Dot (!.)
	head					<- Sp PROGRAM Id (LPar ids RPar)? Semi
	decs 					<- labelDecs constDefs typeDefs varDecs procAndFuncDecs
	ids			 			<- Id (Comma Id)*

	labelDecs 				<- (LABEL labels Semi)?
	labels 					<- label (Comma label)*
	label 					<- UInt

	constDefs 				<- (CONST constDef Semi (constDef Semi)*)?
	constDef 				<- Id Eq const
	const 					<- Sign? (UNumber / Id) / String

	typeDefs 				<- (TYPE typeDef Semi (typeDef Semi)*)?
	typeDef					<- Id Eq type
	type 					<- newType / Id
	newType 				<- newOrdinalType / newStructuredType / newPointerType
	newOrdinalType 			<- enumType / subrangeType
	newStructuredType 		<- PACKED? unpackedStructuredType
	newPointerType 			<- Pointer Id
	enumType 				<- LPar ids RPar
	subrangeType 			<- const DotDot const
	unpackedStructuredType 	<- arrayType / recordType / setType / fileType
	arrayType 				<- ARRAY LBrack ordinalType (Comma ordinalType)* RBrack OF type
	recordType 				<- RECORD fieldList END
	setType 				<- SET OF ordinalType
	fileType 				<- FILE OF type
	ordinalType 			<- newOrdinalType / Id
	fieldList 				<- ((fixedPart (Semi variantPart)? / variantPart) Semi?)?
	fixedPart				<- varDec (Semi varDec)*
	variantPart 			<- CASE Id (Colon Id)? OF variant (Semi variant)*
	variant 				<- consts Colon LPar fieldList RPar
	consts 					<- const (Comma const)*

	varDecs 				<- (VAR varDec Semi (varDec Semi)*)?
	varDec					<- ids Colon type

	procAndFuncDecs			<- ((procDec / funcDec) Semi)*
	procDec					<- procHeading Semi (decs block / Id)
	procHeading 			<- PROCEDURE Id formalParams?
	funcDec 	 			<- funcHeading Semi (decs block / Id)
	funcHeading				<- FUNCTION Id formalParams? Colon type
	formalParams 			<- LPar formalParamsSection (Semi formalParamsSection)* RPar
	formalParamsSection 	<- VAR? ids Colon Id / procHeading / funcHeading

	block 					<- BEGIN stmts END
	stmts 					<- stmt (Semi stmt)*
	stmt 					<- (label Colon)? (simpleStmt / structuredStmt)?
	simpleStmt 				<- assignStmt / procStmt / gotoStmt
	assignStmt 				<- var Assign expr
	var 					<- Id (LBrack expr (Comma expr)* RBrack / Dot Id / Pointer)*
	procStmt				<- Id params?
	params 					<- LPar (param (Comma param)*)? RPar
	param 					<- expr (Colon expr)? (Colon expr)?
	gotoStmt 				<- GOTO label
	structuredStmt			<- block / conditionalStmt / repetitiveStmt / withStmt
	conditionalStmt 		<- ifStmt / caseStmt
	ifStmt 					<- IF expr THEN stmt (ELSE stmt)?
	caseStmt 				<- CASE expr OF caseListElement (Semi caseListElement)* Semi? END
	caseListElement 		<- consts Colon stmt
	repetitiveStmt 			<- repeatStmt / whileStmt / forStmt
	repeatStmt 				<- REPEAT stmts UNTIL expr
	whileStmt 				<- WHILE expr DO stmt
	forStmt 				<- FOR Id Assign expr (TO / DOWNTO) expr DO stmt
	withStmt 				<- WITH var (Comma var)* DO stmt

	expr 					<- simpleExpr (RelOp simpleExpr)?
	simpleExpr 				<- Sign? term (AddOp term)*
	term 					<- factor (MultOp factor)*
	factor 					<- NOT* (funcCall / var / unsignedConst / setConstructor / LPar expr RPar)
	unsignedConst 			<- UNumber / String / Id / NIL
	funcCall 				<- Id params
	setConstructor 			<- LBrack (memberDesignator (Comma memberDesignator)*)? RBrack
	memberDesignator 		<- expr (DotDot expr)?

	AddOp					<- ('+' / '-'/ OR) Sp
	Assign 					<- ':=' Sp
	Dot						<- '.' Sp
	DotDot 					<- '..' Sp
	CloseComment 			<- '*)' / '}'
	Colon			 		<- ':' Sp
	Comma					<- ',' Sp
	Comments 				<- OpenComment (!CloseComment .)* CloseComment
	Eq 						<- '=' Sp
	BodyId 					<- [a-zA-Z0-9]
	Id						<- !Reserved [a-zA-Z][a-zA-Z0-9]* Sp
	LBrack 					<- '[' Sp
	LPar					<- '(' Sp
	MultOp 					<- ('*' / '/' / DIV / MOD / AND) Sp
	OpenComment 			<- '(*' / '{'
	Pointer 			 	<- '^' Sp
	RBrack 					<- ']' Sp
	RelOp 					<- ('<=' / '=' / '<>' / '>=' / '>' / '<' / IN) Sp
	RPar 					<- ')' Sp
	Semi 					<- ';' Sp
	Sign 					<- ('+'/'-') Sp
	Sp						<- (' ' / %nl / Comments)*
	String					<- "'" [^']* "'" Sp
	UInt 					<- [0-9]+ Sp
	UNumber 				<- UReal / UInt
	UReal 					<- [0-9]+ ('.' [0-9]+ (E ('+'/'-') [0-9]+)? / E ('+'/'-') [0-9]+) Sp

	Reserved <- (
		AND / ARRAY /
		BEGIN /
		CONST / CASE /
		DIV / DO / DOWNTO /
		ELSE / END /
		FILE / FOR / FUNCTION /
		GOTO /
		IF / IN /
		LABEL /
		MOD /
		NIL / NOT /
		OF / OR /
		PACKED / PROCEDURE / PROGRAM /
		RECORD /
		REPEAT /
		SET /
		THEN / TO / TYPE /
		UNTIL /
		VAR /
		WHILE / WITH
	)

	AND 			<- A N D 				!BodyId Sp
	ARRAY 			<- A R R A Y 			!BodyId Sp
	BEGIN 			<- B E G I N 			!BodyId Sp
	CASE 			<- C A S E 				!BodyId Sp
	CONST 			<- C O N S T 			!BodyId Sp
	DIV 			<- D I V 				!BodyId Sp
	DO 				<- D O 					!BodyId Sp
	DOWNTO 			<- D O W N T O 			!BodyId Sp
	ELSE			<- E L S E 				!BodyId Sp
	END				<- E N D 				!BodyId Sp
	FILE 			<- F I L E 				!BodyId Sp
	FOR 			<- F O R 				!BodyId Sp
	FUNCTION 		<- F U N C T I O N 		!BodyId Sp
	GOTO 			<- G O T O 				!BodyId Sp
	IF 				<- I F 					!BodyId Sp
	IN 				<- I N 					!BodyId Sp
	LABEL 			<- L A B E L 			!BodyId Sp
	MOD 			<- M O D 				!BodyId Sp
	NIL 			<- N I L 				!BodyId Sp
	NOT 			<- N O T 				!BodyId Sp
	OF 				<- O F 					!BodyId	Sp
	OR 				<- O R 					!BodyId Sp
	PACKED 			<- P A C K E D 			!BodyId Sp
	PROCEDURE 		<- P R O C E D U R E 	!BodyId Sp
	PROGRAM 		<- P R O G R A M 		!BodyId Sp
	RECORD 			<- R E C O R D 			!BodyId Sp
	REPEAT 			<- R E P E A T 			!BodyId Sp
	SET 			<- S E T 				!BodyId Sp
	THEN 			<- T H E N 				!BodyId Sp
	TO 				<- T O 					!BodyId Sp
	TYPE 			<- T Y P E 				!BodyId Sp
	UNTIL 			<- U N T I L 			!BodyId Sp
	VAR 			<- V A R 				!BodyId Sp
	WHILE 			<- W H I L E 			!BodyId Sp
	WITH 			<- W I T H 				!BodyId Sp
	
	A			<- 'a' / 'A'
	B			<- 'b' / 'B'
	C			<- 'c' / 'C'
	D			<- 'd' / 'D'
	E			<- 'e' / 'E'
	F			<- 'f' / 'F'
	G			<- 'g' / 'G'
	H			<- 'h' / 'H'
	I			<- 'i' / 'I'
	J			<- 'j' / 'J'
	K			<- 'k' / 'K'
	L			<- 'l' / 'L'
	M			<- 'm' / 'M'
	N			<- 'n' / 'N'
	O			<- 'o' / 'O'
	P			<- 'p' / 'P'
	Q			<- 'q' / 'Q'
	R			<- 'r' / 'R'
	S			<- 's' / 'S'
	T			<- 't' / 'T'
	U			<- 'u' / 'U'
	V			<- 'v' / 'V'
	W			<- 'w' / 'W'
	X			<- 'x' / 'X'
	Y			<- 'y' / 'Y'
	Z			<- 'z' / 'Z'
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

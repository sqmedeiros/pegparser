local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require 'lfs'
local re = require 'relabel'

g = [[
	program 				<- SKIP head decs block Dot (!.)
	head					<- PROGRAM Id (LPar ids RPar)? Semi
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

	AddOp					<- ('+' / '-'/ OR)
	Assign 					<- ':='
	Dot						<- '.'
	DotDot 					<- '..'
	CloseComment 			<- '*)' / '}'
	Colon			 		<- ':'
	Comma					<- ','
	COMMENT 				<- OpenComment (!CloseComment .)* CloseComment
	Eq 						<- '='
	BodyId 					<- [a-zA-Z0-9]
	Id						<- !Reserved [a-zA-Z][a-zA-Z0-9]*
	LBrack 					<- '['
	LPar					<- '('
	MultOp 					<- ('*' / '/' / DIV / MOD / AND)
	OpenComment 			<- '(*' / '{'
	Pointer 			 	<- '^'
	RBrack 					<- ']'
	RelOp 					<- ('<=' / '=' / '<>' / '>=' / '>' / '<' / IN)
	RPar 					<- ')'
	Semi 					<- ';'
	Sign 					<- ('+'/'-')
	String					<- "'" (!"'" .)* "'"
	UInt 					<- [0-9]+
	UNumber 				<- UReal / UInt
	UReal 					<- [0-9]+ ('.' [0-9]+ (E ('+'/'-') [0-9]+)? / E ('+'/'-') [0-9]+)

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

	AND 			<- A N D 				!BodyId
	ARRAY 			<- A R R A Y 			!BodyId
	BEGIN 			<- B E G I N 			!BodyId
	CASE 			<- C A S E 				!BodyId
	CONST 			<- C O N S T 			!BodyId
	DIV 			<- D I V 				!BodyId
	DO 				<- D O 					!BodyId
	DOWNTO 			<- D O W N T O 			!BodyId
	ELSE			<- E L S E 				!BodyId
	END				<- E N D 				!BodyId
	FILE 			<- F I L E 				!BodyId
	FOR 			<- F O R 				!BodyId
	FUNCTION 		<- F U N C T I O N 		!BodyId
	GOTO 			<- G O T O 				!BodyId
	IF 				<- I F 					!BodyId
	IN 				<- I N 					!BodyId
	LABEL 			<- L A B E L 			!BodyId
	MOD 			<- M O D 				!BodyId
	NIL 			<- N I L 				!BodyId
	NOT 			<- N O T 				!BodyId
	OF 				<- O F 					!BodyId
	OR 				<- O R 					!BodyId
	PACKED 			<- P A C K E D 			!BodyId
	PROCEDURE 		<- P R O C E D U R E 	!BodyId
	PROGRAM 		<- P R O G R A M 		!BodyId
	RECORD 			<- R E C O R D 			!BodyId
	REPEAT 			<- R E P E A T 			!BodyId
	SET 			<- S E T 				!BodyId
	THEN 			<- T H E N 				!BodyId
	TO 				<- T O 					!BodyId
	TYPE 			<- T Y P E 				!BodyId
	UNTIL 			<- U N T I L 			!BodyId
	VAR 			<- V A R 				!BodyId
	WHILE 			<- W H I L E 			!BodyId
	WITH 			<- W I T H 				!BodyId
	
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

local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/'	
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'pas' + 1) == 'pas' then
		print("Yes: ", file)
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

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/'	
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'pas' + 1) == 'pas' then
		print("No: ", file)
		local f = io.open(dir .. file)
		local s = f:read('a')
		f:close()
		local r, lab, pos = p:match(s)
		io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
		local line, col = '', ''
		if not r then
			line, col = re.calcline(s, pos)
			io.write(' line: ' .. line .. ' col: ' .. col)
		end
		io.write('\n')
		assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end


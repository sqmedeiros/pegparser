local m = require 'init'
local pretty = require 'pretty'
local coder = require 'coder'
local recovery = require 'recovery'
local ast = require'ast'
local util = require'util'


local s = [[
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
	UReal 					<- [0-9]+ ('.' [0-9]+ ([Ee] ('+'/'-') [0-9]+)? / [Ee] ('+'/'-') [0-9]+)

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

	AND 			<- [Aa] [Nn] [Dd]								!BodyId
	ARRAY 			<- [Aa] [Rr] [Rr] [Aa] [Yy]						!BodyId
	BEGIN 			<- [Bb] [Ee] [Gg] [Ii] [Nn]						!BodyId
	CASE 			<- [Cc] [Aa] [Ss] [Ee] 							!BodyId
	CONST 			<- [Cc] [Oo] [Nn] [Ss] [Tt] 					!BodyId
	DIV 			<- [Dd] [Ii] [Vv] 								!BodyId
	DO 				<- [Dd] [Oo] 									!BodyId
	DOWNTO 			<- [Dd] [Oo] [Ww] [Nn] [Tt] [Oo]				!BodyId
	ELSE			<- [Ee] [Ll] [Ss] [Ee] 							!BodyId
	END				<- [Ee] [Nn] [Dd] 								!BodyId
	FILE 			<- [Ff] [Ii] [Ll] [Ee] 							!BodyId
	FOR 			<- [Ff] [Oo] [Rr] 								!BodyId
	FUNCTION 		<- [Ff] [Uu] [Nn] [Cc] [Tt] [Ii] [Oo] [Nn]		!BodyId
	GOTO 			<- [Gg] [Oo] [Tt] [Oo] 							!BodyId
	IF 				<- [Ii] [Ff] 									!BodyId
	IN 				<- [Ii] [Nn] 									!BodyId
	LABEL 			<- [Ll] [Aa] [Bb] [Ee] [Ll] 					!BodyId
	MOD 			<- [Mm] [Oo] [Dd]								!BodyId
	NIL 			<- [Nn] [Ii] [Ll] 								!BodyId
	NOT 			<- [Nn] [Oo] [Tt] 								!BodyId
	OF 				<- [Oo] [Ff] 									!BodyId
	OR 				<- [Oo] [Rr] 									!BodyId
	PACKED 			<- [Pp] [Aa] [Cc] [Kk] [Ee] [Dd] 				!BodyId
	PROCEDURE 		<- [Pp] [Rr] [Oo] [Cc] [Ee] [Dd] [Uu] [Rr] [Ee]	!BodyId
	PROGRAM 		<- [Pp] [Rr] [Oo] [Gg] [Rr] [Aa] [Mm] 			!BodyId
	RECORD 			<- [Rr] [Ee] [Cc] [Oo] [Rr] [Dd] 				!BodyId
	REPEAT 			<- [Rr] [Ee] [Pp] [Ee] [Aa] [Tt] 				!BodyId
	SET 			<- [Ss] [Ee] [Tt]				 				!BodyId
	THEN 			<- [Tt] [Hh] [Ee] [Nn]			 				!BodyId
	TO 				<- [Tt] [Oo]				 					!BodyId
	TYPE 			<- [Tt] [Yy] [Pp] [Ee] 							!BodyId
	UNTIL 			<- [Uu] [Nn] [Tt] [Ii] [Ll]			 			!BodyId
	VAR 			<- [Vv] [Aa] [Rr] 								!BodyId
	WHILE 			<- [Ww] [Hh] [Ii] [Ll] [Ee] 					!BodyId
	WITH 			<- [Ww] [Ii] [Tt] [Hh]			 				!BodyId
]]


print("Regular Annotation (SBLP paper)")
g = m.match(s)
local greg = recovery.putlabels(g, 'regular', true)
print(pretty.printg(greg, true), '\n')
print("End Regular\n")


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


print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
print(pretty.printg(gupath, true, 'unique'), '\n')
print("End UPath\n")


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

g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/'
util.testYes(dir, 'pas', p)

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/'
util.testNo(dir, 'pas', p)

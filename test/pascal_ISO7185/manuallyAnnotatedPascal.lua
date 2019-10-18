local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
	program 				<- SKIP head decs block^BeginErr Dot^DotErr (!.)^EndInputErr
	head					<- PROGRAM^ProgErr Id^ProgNameErr (LPar ids RPar^RParErr)? Semi^SemiErr
	decs 					<- labelDecs constDefs typeDefs varDecs procAndFuncDecs
	ids			 			<- Id (Comma Id^IdErr)*

	labelDecs 				<- (LABEL labels^LabelErr Semi^SemiErr)?
	labels 					<- label (Comma label^LabelErr)*
	label 					<- UInt

	constDefs 				<- (CONST constDef^IdErr Semi^SemiErr (constDef Semi^SemiErr)*)?
	constDef 				<- Id Eq^EqErr const^ConstErr
	const 					<- Sign? (UNumber / Id) / String

	typeDefs 				<- (TYPE typeDef^IdErr Semi^SemiErr (typeDef Semi^SemiErr)*)?
	typeDef					<- Id Eq^EqErr type^TypeErr
	type 					<- newType / Id
	newType 				<- newOrdinalType / newStructuredType / newPointerType
	newOrdinalType 			<- enumType / subrangeType
	newStructuredType 		<- PACKED? unpackedStructuredType
	newPointerType 			<- Pointer Id^IdErr
	enumType 				<- LPar ids^IdErr RPar^RParErr
	subrangeType 			<- const DotDot const^ConstErr
	unpackedStructuredType 	<- arrayType / recordType / setType / fileType
	arrayType 				<- ARRAY LBrack^LBrackErr ordinalType^OrdinalTypeErr (Comma ordinalType^OrdinalTypeErr)* RBrack^RBrackErr OF^OfErr type^TypeErr
	recordType 				<- RECORD fieldList END^EndErr
	setType 				<- SET OF^OfErr ordinalType^OrdinalTypeErr
	fileType 				<- FILE OF^OfErr type^TypeErr
	ordinalType 			<- newOrdinalType / Id
	fieldList 				<- ((fixedPart (Semi variantPart)? / variantPart) Semi?)?
	fixedPart				<- varDec (Semi varDec)*
	variantPart 			<- CASE Id^IdErr (Colon Id^IdErr)? OF^OfErr variant^ConstErr (Semi variant)*
	variant 				<- consts Colon^ColonErr LPar^LParErr fieldList RPar^RParErr
	consts 					<- const (Comma const^ConstErr)*

	varDecs 				<- (VAR varDec Semi^SemiErr (varDec Semi^SemiErr)*)?
	varDec					<- ids Colon^ColonErr type^TypeErr

	procAndFuncDecs			<- ((procDec / funcDec) Semi^SemiErr)*
	procDec					<- procHeading Semi^SemiErr (decs block / Id)^ProcBodyErr
	procHeading 			<- PROCEDURE Id^IdErr formalParams?
	funcDec 	 			<- funcHeading Semi^SemiErr (decs block / Id)^FuncBodyErr
	funcHeading				<- FUNCTION Id^IdErr formalParams? Colon^ColonErr type^TypeErr
	formalParams 			<- LPar formalParamsSection^FormalParamErr (Semi formalParamsSection^FormalParamErr)* RPar^RParErr
	formalParamsSection 	<- VAR? ids Colon^ColonErr Id^IdErr / procHeading / funcHeading

	block 					<- BEGIN stmts END^EndErr
	stmts 					<- stmt (Semi stmt)*
	stmt 					<- (label Colon^ColonErr)? (simpleStmt / structuredStmt)?
	simpleStmt 				<- assignStmt / procStmt / gotoStmt
	assignStmt 				<- var Assign expr^ExprErr
	var 					<- Id (LBrack expr^ExprErr (Comma expr^ExprErr)* RBrack^RBrackErr / Dot Id^IdErr / Pointer)*
	procStmt				<- Id params?
	params 					<- LPar (param (Comma param^RealParamErr)*)? RPar^RParErr
	param 					<- expr (Colon expr^ExprErr)? (Colon expr^ExprErr)?
	gotoStmt 				<- GOTO label^LabelErr
	structuredStmt			<- block / conditionalStmt / repetitiveStmt / withStmt
	conditionalStmt 		<- ifStmt / caseStmt
	ifStmt 					<- IF expr^ExprErr THEN^ThenErr stmt (ELSE stmt)?
	caseStmt 				<- CASE expr^ExprErr OF^OfErr caseListElement^ConstErr (Semi caseListElement)* Semi? END^EndErr
	caseListElement 		<- consts Colon^ColonErr stmt
	repetitiveStmt 			<- repeatStmt / whileStmt / forStmt
	repeatStmt 				<- REPEAT stmts UNTIL^UntilErr expr^ExprErr
	whileStmt 				<- WHILE expr^ExprErr DO^DoErr stmt
	forStmt 				<- FOR Id^IdErr Assign^AssignErr expr^ExprErr (TO / DOWNTO)^ToDownToErr expr^ExprErr DO^DoErr stmt
	withStmt 				<- WITH var^VarErr (Comma var^VarErr)* DO^DoErr stmt

	expr 					<- simpleExpr (RelOp simpleExpr^SimpleExprErr)?
	simpleExpr 				<- Sign? term (AddOp term^TermErr)*
	term 					<- factor (MultOp factor^FactorErr)*
	factor 					<- NOT* (funcCall / var / unsignedConst / setConstructor / LPar expr^ExprErr RPar^RParErr)
	unsignedConst 			<- UNumber / String / Id / NIL
	funcCall 				<- Id params
	setConstructor 			<- LBrack (memberDesignator (Comma memberDesignator^ExprErr)*)? RBrack^RBrackErr
	memberDesignator 		<- expr (DotDot expr^ExprErr)?

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

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'pas', p)

util.testNo(dir .. '/test/no/', 'pas', p)

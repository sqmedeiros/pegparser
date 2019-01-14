g = [[
	program 				<- head decs block^BeginErr Dot^DotErr (!.)^EndInputErr
	head					<- Sp PROGRAM^ProgErr Id^ProgNameErr (LPar ids RPar^RParErr)? Semi^SemiErr
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
	Sp						<- (%s / %nl / Comments)*
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
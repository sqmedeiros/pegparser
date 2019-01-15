local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'

g = [[
program         <-  head decs [block]^Err_001 [Dot]^Err_002 !.
head            <-  Sp PROGRAM [Id]^Err_003 (LPar [ids]^Err_004 [RPar]^Err_005)? [Semi]^Err_006
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma [Id]^Err_007)*
labelDecs       <-  (LABEL [labels]^Err_008 [Semi]^Err_009)?
labels          <-  label (Comma [label]^Err_010)*
label           <-  UInt
constDefs       <-  (CONST [constDef]^Err_011 [Semi]^Err_012 (constDef [Semi]^Err_013)*)?
constDef        <-  Id [Eq]^Err_014 [const]^Err_015
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE [typeDef]^Err_016 [Semi]^Err_017 (typeDef [Semi]^Err_018)*)?
typeDef         <-  Id [Eq]^Err_019 [type]^Err_020
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer [Id]^Err_021
enumType        <-  LPar [ids]^Err_022 [RPar]^Err_023
subrangeType    <-  const [DotDot]^Err_024 [const]^Err_025
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY [LBrack]^Err_026 [ordinalType]^Err_027 (Comma [ordinalType]^Err_028)* [RBrack]^Err_029 [OF]^Err_030 [type]^Err_031
recordType      <-  RECORD fieldList [END]^Err_032
setType         <-  SET [OF]^Err_033 [ordinalType]^Err_034
fileType        <-  FILE [OF]^Err_035 [type]^Err_036
ordinalType     <-  newOrdinalType  /  Id
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE [Id]^Err_037 (Colon [Id]^Err_038)? [OF]^Err_039 [variant]^Err_040 (Semi variant)*
variant         <-  consts [Colon]^Err_041 [LPar]^Err_042 fieldList [RPar]^Err_043
consts          <-  const (Comma [const]^Err_044)*
varDecs         <-  (VAR [varDec]^Err_045 [Semi]^Err_046 (varDec [Semi]^Err_047)*)?
varDec          <-  ids [Colon]^Err_048 [type]^Err_049
procAndFuncDecs <-  ((procDec  /  funcDec) [Semi]^Err_050)*
procDec         <-  procHeading [Semi]^Err_051 [decs block  /  Id]^Err_052
procHeading     <-  PROCEDURE [Id]^Err_053 formalParams?
funcDec         <-  funcHeading [Semi]^Err_054 [decs block  /  Id]^Err_055
funcHeading     <-  FUNCTION [Id]^Err_056 formalParams? [Colon]^Err_057 [type]^Err_058
formalParams    <-  LPar [formalParamsSection]^Err_059 (Semi [formalParamsSection]^Err_060)* [RPar]^Err_061
formalParamsSection <-  VAR? ids [Colon]^Err_062 [Id]^Err_063  /  procHeading  /  funcHeading
block           <-  BEGIN stmts [END]^Err_064
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label [Colon]^Err_065)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var [Assign]^Err_066 [expr]^Err_067
var             <-  Id (LBrack [expr]^Err_068 (Comma [expr]^Err_069)* [RBrack]^Err_070  /  Dot [Id]^Err_071  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma [param]^Err_072)*)? [RPar]^Err_073
param           <-  expr (Colon expr)? (Colon [expr]^Err_074)?
gotoStmt        <-  GOTO [label]^Err_075
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF [expr]^Err_076 [THEN]^Err_077 stmt (ELSE stmt)?
caseStmt        <-  CASE [expr]^Err_078 [OF]^Err_079 [caseListElement]^Err_080 (Semi caseListElement)* Semi? [END]^Err_081
caseListElement <-  consts [Colon]^Err_082 stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts [UNTIL]^Err_083 [expr]^Err_084
whileStmt       <-  WHILE [expr]^Err_085 [DO]^Err_086 stmt
forStmt         <-  FOR [Id]^Err_087 [Assign]^Err_088 [expr]^Err_089 [TO  /  DOWNTO]^Err_090 [expr]^Err_091 [DO]^Err_092 stmt
withStmt        <-  WITH [var]^Err_093 (Comma [var]^Err_094)* [DO]^Err_095 stmt
expr            <-  simpleExpr (RelOp [simpleExpr]^Err_096)?
simpleExpr      <-  Sign? term (AddOp [term]^Err_097)*
term            <-  factor (MultOp [factor]^Err_098)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar [expr]^Err_099 [RPar]^Err_100)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id [params]^Err_101
setConstructor  <-  LBrack (memberDesignator (Comma [memberDesignator]^Err_102)*)? [RBrack]^Err_103
memberDesignator <-  expr (DotDot [expr]^Err_104)?
AddOp           <-  ('+'  /  '-'  /  OR) Sp
Assign          <-  ':=' Sp
Dot             <-  '.' Sp
DotDot          <-  '..' Sp
CloseComment    <-  '*)'  /  '}'
Colon           <-  ':' Sp
Comma           <-  ',' Sp
Comments        <-  OpenComment (!CloseComment .)* CloseComment
Eq              <-  '=' Sp
BodyId          <-  [a-zA-Z0-9]
Id              <-  !Reserved [a-zA-Z] [a-zA-Z0-9]* Sp
LBrack          <-  '[' Sp
LPar            <-  '(' Sp
MultOp          <-  ('*'  /  '/'  /  DIV  /  MOD  /  AND) Sp
OpenComment     <-  '(*'  /  '{'
Pointer         <-  '^' Sp
RBrack          <-  ']' Sp
RelOp           <-  ('<='  /  '='  /  '<>'  /  '>='  /  '>'  /  '<'  /  IN) Sp
RPar            <-  ')' Sp
Semi            <-  ';' Sp
Sign            <-  ('+'  /  '-') Sp
Sp              <-  (' '  /  %nl  /  Comments)*
String          <-  "'" [^']* "'" Sp
UInt            <-  [0-9]+ Sp
UNumber         <-  UReal  /  UInt
UReal           <-  [0-9]+ ('.' [0-9]+ (E ('+'  /  '-') [0-9]+)?  /  E ('+'  /  '-') [0-9]+) Sp
Reserved        <-  AND  /  ARRAY  /  BEGIN  /  CONST  /  CASE  /  DIV  /  DO  /  DOWNTO  /  ELSE  /  END  /  FILE  /  FOR  /  FUNCTION  /  GOTO  /  IF  /  IN  /  LABEL  /  MOD  /  NIL  /  NOT  /  OF  /  OR  /  PACKED  /  PROCEDURE  /  PROGRAM  /  RECORD  /  REPEAT  /  SET  /  THEN  /  TO  /  TYPE  /  UNTIL  /  VAR  /  WHILE  /  WITH
AND             <-  A N D !BodyId Sp
ARRAY           <-  A R R A Y !BodyId Sp
BEGIN           <-  B E G I N !BodyId Sp
CASE            <-  C A S E !BodyId Sp
CONST           <-  C O N S T !BodyId Sp
DIV             <-  D I V !BodyId Sp
DO              <-  D O !BodyId Sp
DOWNTO          <-  D O W N T O !BodyId Sp
ELSE            <-  E L S E !BodyId Sp
END             <-  E N D !BodyId Sp
FILE            <-  F I L E !BodyId Sp
FOR             <-  F O R !BodyId Sp
FUNCTION        <-  F U N C T I O N !BodyId Sp
GOTO            <-  G O T O !BodyId Sp
IF              <-  I F !BodyId Sp
IN              <-  I N !BodyId Sp
LABEL           <-  L A B E L !BodyId Sp
MOD             <-  M O D !BodyId Sp
NIL             <-  N I L !BodyId Sp
NOT             <-  N O T !BodyId Sp
OF              <-  O F !BodyId Sp
OR              <-  O R !BodyId Sp
PACKED          <-  P A C K E D !BodyId Sp
PROCEDURE       <-  P R O C E D U R E !BodyId Sp
PROGRAM         <-  P R O G R A M !BodyId Sp
RECORD          <-  R E C O R D !BodyId Sp
REPEAT          <-  R E P E A T !BodyId Sp
SET             <-  S E T !BodyId Sp
THEN            <-  T H E N !BodyId Sp
TO              <-  T O !BodyId Sp
TYPE            <-  T Y P E !BodyId Sp
UNTIL           <-  U N T I L !BodyId Sp
VAR             <-  V A R !BodyId Sp
WHILE           <-  W H I L E !BodyId Sp
WITH            <-  W I T H !BodyId Sp
A               <-  'a'  /  'A'
B               <-  'b'  /  'B'
C               <-  'c'  /  'C'
D               <-  'd'  /  'D'
E               <-  'e'  /  'E'
F               <-  'f'  /  'F'
G               <-  'g'  /  'G'
H               <-  'h'  /  'H'
I               <-  'i'  /  'I'
J               <-  'j'  /  'J'
K               <-  'k'  /  'K'
L               <-  'l'  /  'L'
M               <-  'm'  /  'M'
N               <-  'n'  /  'N'
O               <-  'o'  /  'O'
P               <-  'p'  /  'P'
Q               <-  'q'  /  'Q'
R               <-  'r'  /  'R'
S               <-  's'  /  'S'
T               <-  't'  /  'T'
U               <-  'u'  /  'U'
V               <-  'v'  /  'V'
W               <-  'w'  /  'W'
X               <-  'x'  /  'X'
Y               <-  'y'  /  'Y'
Z               <-  'z'  /  'Z'
Token           <-  Z  /  Y  /  X  /  WITH  /  WHILE  /  W  /  VAR  /  V  /  UReal  /  UNumber  /  UNTIL  /  UInt  /  U  /  TYPE  /  TO  /  THEN  /  T  /  String  /  Sp  /  Sign  /  Semi  /  SET  /  S  /  Reserved  /  RelOp  /  RPar  /  REPEAT  /  RECORD  /  RBrack  /  R  /  Q  /  Pointer  /  PROGRAM  /  PROCEDURE  /  PACKED  /  P  /  OpenComment  /  OR  /  OF  /  O  /  NOT  /  NIL  /  N  /  MultOp  /  MOD  /  M  /  LPar  /  LBrack  /  LABEL  /  L  /  K  /  J  /  Id  /  IN  /  IF  /  I  /  H  /  GOTO  /  G  /  FUNCTION  /  FOR  /  FILE  /  F  /  Eq  /  END  /  ELSE  /  E  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  DIV  /  D  /  Comments  /  Comma  /  Colon  /  CloseComment  /  CONST  /  CASE  /  C  /  BodyId  /  BEGIN  /  B  /  Assign  /  AddOp  /  ARRAY  /  AND  /  A
EatToken        <-  (Token  /  (!SKIP .)+) SKIP
Err_001         <-  (!Dot EatToken)*
Err_002         <-  (!(!.) EatToken)*
Err_003         <-  (!(Semi  /  LPar) EatToken)*
Err_004         <-  (!RPar EatToken)*
Err_005         <-  (!Semi EatToken)*
Err_006         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_007         <-  (!(RPar  /  Colon) EatToken)*
Err_008         <-  (!Semi EatToken)*
Err_009         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_010         <-  (!Semi EatToken)*
Err_011         <-  (!Semi EatToken)*
Err_012         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_013         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_014         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_015         <-  (!Semi EatToken)*
Err_016         <-  (!Semi EatToken)*
Err_017         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_018         <-  (!(VAR  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_019         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_020         <-  (!Semi EatToken)*
Err_021         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_022         <-  (!RPar EatToken)*
Err_023         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_024         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_025         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_026         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_027         <-  (!(RBrack  /  Comma) EatToken)*
Err_028         <-  (!RBrack EatToken)*
Err_029         <-  (!OF EatToken)*
Err_030         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_031         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_032         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_033         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_034         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_035         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_036         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_037         <-  (!(OF  /  Colon) EatToken)*
Err_038         <-  (!OF EatToken)*
Err_039         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_040         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_041         <-  (!LPar EatToken)*
Err_042         <-  (!(RPar  /  Id  /  CASE) EatToken)*
Err_043         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_044         <-  (!Colon EatToken)*
Err_045         <-  (!Semi EatToken)*
Err_046         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_047         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_048         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_049         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_050         <-  (!BEGIN EatToken)*
Err_051         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_052         <-  (!Semi EatToken)*
Err_053         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_054         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_055         <-  (!Semi EatToken)*
Err_056         <-  (!(LPar  /  Colon) EatToken)*
Err_057         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_058         <-  (!(Semi  /  RPar) EatToken)*
Err_059         <-  (!(Semi  /  RPar) EatToken)*
Err_060         <-  (!RPar EatToken)*
Err_061         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_062         <-  (!Id EatToken)*
Err_063         <-  (!(Semi  /  RPar) EatToken)*
Err_064         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_065         <-  (!(WITH  /  WHILE  /  UNTIL  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_066         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_067         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_068         <-  (!(RBrack  /  Comma) EatToken)*
Err_069         <-  (!RBrack EatToken)*
Err_070         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_071         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_072         <-  (!RPar EatToken)*
Err_073         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_074         <-  (!(RPar  /  Comma) EatToken)*
Err_075         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_076         <-  (!THEN EatToken)*
Err_077         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_078         <-  (!OF EatToken)*
Err_079         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_080         <-  (!(Semi  /  END) EatToken)*
Err_081         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_082         <-  (!(WITH  /  WHILE  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  CASE  /  BEGIN) EatToken)*
Err_083         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_084         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_085         <-  (!DO EatToken)*
Err_086         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_087         <-  (!Assign EatToken)*
Err_088         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_089         <-  (!(TO  /  DOWNTO) EatToken)*
Err_090         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_091         <-  (!DO EatToken)*
Err_092         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_093         <-  (!(DO  /  Comma) EatToken)*
Err_094         <-  (!DO EatToken)*
Err_095         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_096         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_097         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_098         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_099         <-  (!RPar EatToken)*
Err_100         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_101         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_102         <-  (!RBrack EatToken)*
Err_103         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_104         <-  (!(RBrack  /  Comma) EatToken)*
]]

local g = m.match(g)

local p = coder.makeg(g)

local dir = lfs.currentdir() .. '/test/titan/test/yes/'	
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'titan' + 1) == 'titan' then
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

local dir = lfs.currentdir() .. '/test/titan/test/no/'	
local irec, ifail = 0, 0
for file in lfs.dir(dir) do
	if string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #'titan' + 1) == 'titan' then
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
      ifail = ifail + 1
		else
			irec = irec + 1
		end
		io.write('\n')
		--assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end

print('irec: ', irec, ' ifail: ', ifail) 

local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'

--[[
	Removed:
		- Err_024 (DotDot in rule subrangeType)
		- Err_066 (Assign in rule assignStmt)
		- Err_073 (RPar in rule params)
		- Err_064 (END in rule block)
		- Err_001 (block in rule program)
		- Err_101 (params in rule funcCall)

]]

g = [[
program         <-  SKIP head decs block^Err_001 Dot^Err_002 !.
head            <-  PROGRAM Id^Err_003 (LPar ids^Err_004 RPar^Err_005)? Semi^Err_006
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id^Err_007)*
labelDecs       <-  (LABEL labels^Err_008 Semi^Err_009)?
labels          <-  label (Comma label^Err_010)*
label           <-  UInt
constDefs       <-  (CONST constDef^Err_011 Semi^Err_012 (constDef Semi^Err_013)*)?
constDef        <-  Id Eq^Err_014 const^Err_015
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE typeDef^Err_016 Semi^Err_017 (typeDef Semi^Err_018)*)?
typeDef         <-  Id Eq^Err_019 type^Err_020
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer Id^Err_021
enumType        <-  LPar ids^Err_022 RPar^Err_023
subrangeType    <-  const DotDot const^Err_025
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_026 ordinalType^Err_027 (Comma ordinalType^Err_028)* RBrack^Err_029 OF^Err_030 type^Err_031
recordType      <-  RECORD fieldList END^Err_032
setType         <-  SET OF^Err_033 ordinalType^Err_034
fileType        <-  FILE OF^Err_035 type^Err_036
ordinalType     <-  newOrdinalType  /  Id
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id^Err_037 (Colon Id^Err_038)? OF^Err_039 variant^Err_040 (Semi variant)*
variant         <-  consts Colon^Err_041 LPar^Err_042 fieldList RPar^Err_043
consts          <-  const (Comma const^Err_044)*
varDecs         <-  (VAR varDec^Err_045 Semi^Err_046 (varDec Semi^Err_047)*)?
varDec          <-  ids Colon^Err_048 type^Err_049
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_050)*
procDec         <-  procHeading Semi^Err_051 (decs block  /  Id)^Err_052
procHeading     <-  PROCEDURE Id^Err_053 formalParams?
funcDec         <-  funcHeading Semi^Err_054 (decs block  /  Id)^Err_055
funcHeading     <-  FUNCTION Id^Err_056 formalParams? Colon^Err_057 type^Err_058
formalParams    <-  LPar formalParamsSection^Err_059 (Semi formalParamsSection^Err_060)* RPar^Err_061
formalParamsSection <-  VAR? ids Colon^Err_062 Id^Err_063  /  procHeading  /  funcHeading
block           <-  BEGIN stmts END
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon^Err_065)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr^Err_067
var             <-  Id (LBrack expr^Err_068 (Comma expr^Err_069)* RBrack^Err_070  /  Dot Id^Err_071  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param^Err_072)*)? RPar
param           <-  expr (Colon expr)? (Colon expr^Err_074)?
gotoStmt        <-  GOTO label^Err_075
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_076 THEN^Err_077 stmt (ELSE stmt)?
caseStmt        <-  CASE expr^Err_078 OF^Err_079 caseListElement^Err_080 (Semi caseListElement)* Semi? END^Err_081
caseListElement <-  consts Colon^Err_082 stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_083 expr^Err_084
whileStmt       <-  WHILE expr^Err_085 DO^Err_086 stmt
forStmt         <-  FOR Id^Err_087 Assign^Err_088 expr^Err_089 (TO  /  DOWNTO)^Err_090 expr^Err_091 DO^Err_092 stmt
withStmt        <-  WITH var^Err_093 (Comma var^Err_094)* DO^Err_095 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_096)?
simpleExpr      <-  Sign? term (AddOp term^Err_097)*
term            <-  factor (MultOp factor^Err_098)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr^Err_099 RPar^Err_100)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator^Err_102)*)? RBrack^Err_103
memberDesignator <-  expr (DotDot expr^Err_104)?
AddOp           <-  '+'  /  '-'  /  OR
Assign          <-  ':='
Dot             <-  '.'
DotDot          <-  '..'
CloseComment    <-  '*)'  /  '}'
Colon           <-  ':'
Comma           <-  ','
COMMENT        	<-  OpenComment (!CloseComment .)* CloseComment
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
UReal           <-  [0-9]+ ('.' [0-9]+ (E ('+'  /  '-') [0-9]+)?  /  E ('+'  /  '-') [0-9]+)
Reserved        <-  AND  /  ARRAY  /  BEGIN  /  CONST  /  CASE  /  DIV  /  DO  /  DOWNTO  /  ELSE  /  END  /  FILE  /  FOR  /  FUNCTION  /  GOTO  /  IF  /  IN  /  LABEL  /  MOD  /  NIL  /  NOT  /  OF  /  OR  /  PACKED  /  PROCEDURE  /  PROGRAM  /  RECORD  /  REPEAT  /  SET  /  THEN  /  TO  /  TYPE  /  UNTIL  /  VAR  /  WHILE  /  WITH
AND             <-  A N D !BodyId
ARRAY           <-  A R R A Y !BodyId
BEGIN           <-  B E G I N !BodyId
CASE            <-  C A S E !BodyId
CONST           <-  C O N S T !BodyId
DIV             <-  D I V !BodyId
DO              <-  D O !BodyId
DOWNTO          <-  D O W N T O !BodyId
ELSE            <-  E L S E !BodyId
END             <-  E N D !BodyId
FILE            <-  F I L E !BodyId
FOR             <-  F O R !BodyId
FUNCTION        <-  F U N C T I O N !BodyId
GOTO            <-  G O T O !BodyId
IF              <-  I F !BodyId
IN              <-  I N !BodyId
LABEL           <-  L A B E L !BodyId
MOD             <-  M O D !BodyId
NIL             <-  N I L !BodyId
NOT             <-  N O T !BodyId
OF              <-  O F !BodyId
OR              <-  O R !BodyId
PACKED          <-  P A C K E D !BodyId
PROCEDURE       <-  P R O C E D U R E !BodyId
PROGRAM         <-  P R O G R A M !BodyId
RECORD          <-  R E C O R D !BodyId
REPEAT          <-  R E P E A T !BodyId
SET             <-  S E T !BodyId
THEN            <-  T H E N !BodyId
TO              <-  T O !BodyId
TYPE            <-  T Y P E !BodyId
UNTIL           <-  U N T I L !BodyId
VAR             <-  V A R !BodyId
WHILE           <-  W H I L E !BodyId
WITH            <-  W I T H !BodyId
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
]]

local g = m.match(g)

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

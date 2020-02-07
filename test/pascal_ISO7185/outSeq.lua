local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
program         <-  SKIP head^Err_001 decs block^Err_002 Dot^Err_003 !.
head            <-  PROGRAM^Err_004 Id^Err_005 (LPar ids^Err_006 RPar^Err_007  /  !Semi %{Err_008} .)? Semi^Err_009
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL labels^Err_010 Semi^Err_011)?
labels          <-  label^Err_012 (Comma label^Err_013  /  !Semi %{Err_014} .)*
label           <-  UInt
constDefs       <-  (CONST constDef^Err_015 Semi^Err_016 (constDef Semi^Err_017  /  !(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  BEGIN) %{Err_018} .)*)?
constDef        <-  Id Eq^Err_019 const^Err_020
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE typeDef^Err_021 Semi^Err_022 (typeDef Semi^Err_023  /  !(VAR  /  PROCEDURE  /  FUNCTION  /  BEGIN) %{Err_024} .)*)?
typeDef         <-  Id Eq^Err_025 type^Err_026
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer Id^Err_027
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_028 ordinalType^Err_029 (Comma ordinalType^Err_030  /  !RBrack %{Err_031} .)* RBrack^Err_032 OF^Err_033 type^Err_034
recordType      <-  RECORD fieldList END^Err_035
setType         <-  SET OF^Err_036 ordinalType^Err_037
fileType        <-  FILE OF^Err_038 type^Err_039
ordinalType     <-  (newOrdinalType  /  Id^Err_040)^Err_041
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec Semi (varDec Semi^Err_042  /  !(PROCEDURE  /  FUNCTION  /  BEGIN) %{Err_043} .)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi)*
procDec         <-  procHeading Semi (decs block  /  Id)
procHeading     <-  PROCEDURE Id^Err_044 (formalParams  /  !(Semi  /  RPar) %{Err_045} .)?
funcDec         <-  funcHeading Semi (decs block  /  Id)
funcHeading     <-  FUNCTION Id^Err_046 (formalParams  /  !Colon %{Err_047} .)? Colon^Err_048 type^Err_049
formalParams    <-  LPar formalParamsSection^Err_050 (Semi formalParamsSection^Err_051  /  !RPar %{Err_052} .)* RPar^Err_053
formalParamsSection <-  (VAR? ids Colon^Err_054 Id^Err_055  /  procHeading  /  funcHeading)^Err_056
block           <-  BEGIN stmts END^Err_057
stmts           <-  stmt (Semi stmt  /  !(UNTIL  /  END) %{Err_058} .)*
stmt            <-  (label Colon^Err_059)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr^Err_060
var             <-  Id (LBrack expr^Err_061 (Comma expr^Err_062  /  !RBrack %{Err_063} .)* RBrack^Err_064  /  Dot Id^Err_065  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_066
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_067 THEN^Err_068 stmt (ELSE stmt  /  !(UNTIL  /  Semi  /  END  /  ELSE) %{Err_069} .)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_070 expr^Err_071
whileStmt       <-  WHILE expr^Err_072 DO^Err_073 stmt
forStmt         <-  FOR Id^Err_074 Assign^Err_075 expr^Err_076 (TO  /  DOWNTO^Err_077)^Err_078 expr^Err_079 DO^Err_080 stmt
withStmt        <-  WITH var^Err_081 (Comma var^Err_082  /  !DO %{Err_083} .)* DO^Err_084 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_085)?
simpleExpr      <-  Sign? term (AddOp term^Err_086)*
term            <-  factor (MultOp factor^Err_087)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr RPar)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator^Err_088  /  !RBrack %{Err_089} .)*  /  !RBrack %{Err_090} .)? RBrack^Err_091
memberDesignator <-  expr (DotDot expr^Err_092  /  !(RBrack  /  Comma) %{Err_093} .)?
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
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'pas', p)

util.testNo(dir .. '/test/no/', 'pas', p)

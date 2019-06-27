local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util = require'util'

--[[ 
	Inserted: 70 labels (70 correct)
]]

g = [[
program         <-  SKIP head decs block^Err_001 Dot^Err_002 !.
head            <-  PROGRAM Id^Err_003 (LPar ids^Err_004 RPar^Err_005)? Semi^Err_006
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL labels^Err_007 Semi^Err_008)?
labels          <-  label^Err_009 (Comma label^Err_010)*
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
newPointerType  <-  Pointer Id
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_021 ordinalType^Err_022 (Comma ordinalType^Err_023)* RBrack^Err_024 OF^Err_025 type^Err_026
recordType      <-  RECORD fieldList END^Err_027
setType         <-  SET OF^Err_028 ordinalType^Err_029
fileType        <-  FILE OF^Err_030 type^Err_031
ordinalType     <-  (newOrdinalType  /  Id)^Err_032
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec^Err_033 Semi^Err_034 (varDec Semi^Err_035)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_036)*
procDec         <-  procHeading Semi^Err_037 (decs block  /  Id)^Err_038
procHeading     <-  PROCEDURE Id^Err_039 formalParams?
funcDec         <-  funcHeading Semi^Err_040 (decs block  /  Id)^Err_041
funcHeading     <-  FUNCTION Id^Err_042 formalParams? Colon^Err_043 type^Err_044
formalParams    <-  LPar formalParamsSection^Err_045 (Semi formalParamsSection^Err_046)* RPar^Err_047
formalParamsSection <-  (VAR? ids Colon^Err_048 Id^Err_049  /  procHeading  /  funcHeading)^Err_050
block           <-  BEGIN stmts END^Err_051
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr
var             <-  Id (LBrack expr (Comma expr)* RBrack  /  Dot Id  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_052
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_053 THEN^Err_054 stmt (ELSE stmt)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_055 expr^Err_056
whileStmt       <-  WHILE expr^Err_057 DO^Err_058 stmt
forStmt         <-  FOR Id^Err_059 Assign^Err_060 expr^Err_061 (TO  /  DOWNTO)^Err_062 expr^Err_063 DO^Err_064 stmt
withStmt        <-  WITH var^Err_065 (Comma var^Err_066)* DO^Err_067 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_068)?
simpleExpr      <-  Sign? term (AddOp term^Err_069)*
term            <-  factor (MultOp factor^Err_070)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr RPar)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator)*)? RBrack
memberDesignator <-  expr (DotDot expr)?
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

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/'
util.testYes(dir, 'pas', p)

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/'
util.testNo(dir, 'pas', p)

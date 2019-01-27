local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local util require'util'

--[[
	Removed:
		- Err_024 (DotDot in rule subrangeType)
    - Err_056 (Assign in rule assignStmt)
    - Err_089 (params in rule funcCall)
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
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const^Err_037)*
varDecs         <-  (VAR varDec^Err_038 Semi^Err_039 (varDec Semi^Err_040)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_041)*
procDec         <-  procHeading Semi^Err_042 (decs block  /  Id)^Err_043
procHeading     <-  PROCEDURE Id^Err_044 formalParams?
funcDec         <-  funcHeading Semi^Err_045 (decs block  /  Id)^Err_046
funcHeading     <-  FUNCTION Id^Err_047 formalParams? Colon^Err_048 type^Err_049
formalParams    <-  LPar formalParamsSection^Err_050 (Semi formalParamsSection^Err_051)* RPar^Err_052
formalParamsSection <-  VAR? ids Colon^Err_053 Id^Err_054  /  procHeading  /  funcHeading
block           <-  BEGIN stmts END^Err_055
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr^Err_057
var             <-  Id (LBrack expr^Err_058 (Comma expr^Err_059)* RBrack^Err_060  /  Dot Id^Err_061  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param^Err_062)*)? RPar^Err_063
param           <-  expr (Colon expr)? (Colon expr^Err_064)?
gotoStmt        <-  GOTO label^Err_065
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_066 THEN^Err_067 stmt (ELSE stmt)?
caseStmt        <-  CASE expr^Err_068 OF^Err_069 caseListElement^Err_070 (Semi caseListElement)* Semi? END^Err_071
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_072 expr^Err_073
whileStmt       <-  WHILE expr^Err_074 DO^Err_075 stmt
forStmt         <-  FOR Id^Err_076 Assign^Err_077 expr^Err_078 (TO  /  DOWNTO)^Err_079 expr^Err_080 DO^Err_081 stmt
withStmt        <-  WITH var^Err_082 (Comma var^Err_083)* DO^Err_084 stmt
expr            <-  simpleExpr (RelOp simpleExpr)?
simpleExpr      <-  Sign? term (AddOp term^Err_085)*
term            <-  factor (MultOp factor^Err_086)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr^Err_087 RPar^Err_088)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator^Err_090)*)? RBrack^Err_091
memberDesignator <-  expr (DotDot expr^Err_092)?
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
AND       <- [Aa] [Nn] [Dd]               !BodyId
ARRAY       <- [Aa] [Rr] [Rr] [Aa] [Yy]           !BodyId
BEGIN       <- [Bb] [Ee] [Gg] [Ii] [Nn]           !BodyId
CASE      <- [Cc] [Aa] [Ss] [Ee]              !BodyId
CONST       <- [Cc] [Oo] [Nn] [Ss] [Tt]           !BodyId
DIV       <- [Dd] [Ii] [Vv]                 !BodyId
DO        <- [Dd] [Oo]                  !BodyId
DOWNTO      <- [Dd] [Oo] [Ww] [Nn] [Tt] [Oo]        !BodyId
ELSE      <- [Ee] [Ll] [Ss] [Ee]              !BodyId
END       <- [Ee] [Nn] [Dd]                 !BodyId
FILE      <- [Ff] [Ii] [Ll] [Ee]              !BodyId
FOR       <- [Ff] [Oo] [Rr]                 !BodyId
FUNCTION    <- [Ff] [Uu] [Nn] [Cc] [Tt] [Ii] [Oo] [Nn]    !BodyId
GOTO      <- [Gg] [Oo] [Tt] [Oo]              !BodyId
IF        <- [Ii] [Ff]                  !BodyId
IN        <- [Ii] [Nn]                  !BodyId
LABEL       <- [Ll] [Aa] [Bb] [Ee] [Ll]           !BodyId
MOD       <- [Mm] [Oo] [Dd]               !BodyId
NIL       <- [Nn] [Ii] [Ll]                 !BodyId
NOT       <- [Nn] [Oo] [Tt]                 !BodyId
OF        <- [Oo] [Ff]                  !BodyId
OR        <- [Oo] [Rr]                  !BodyId
PACKED      <- [Pp] [Aa] [Cc] [Kk] [Ee] [Dd]        !BodyId
PROCEDURE     <- [Pp] [Rr] [Oo] [Cc] [Ee] [Dd] [Uu] [Rr] [Ee] !BodyId
PROGRAM     <- [Pp] [Rr] [Oo] [Gg] [Rr] [Aa] [Mm]       !BodyId
RECORD      <- [Rr] [Ee] [Cc] [Oo] [Rr] [Dd]        !BodyId
REPEAT      <- [Rr] [Ee] [Pp] [Ee] [Aa] [Tt]        !BodyId
SET       <- [Ss] [Ee] [Tt]               !BodyId
THEN      <- [Tt] [Hh] [Ee] [Nn]              !BodyId
TO        <- [Tt] [Oo]                  !BodyId
TYPE      <- [Tt] [Yy] [Pp] [Ee]              !BodyId
UNTIL       <- [Uu] [Nn] [Tt] [Ii] [Ll]           !BodyId
VAR       <- [Vv] [Aa] [Rr]                 !BodyId
WHILE       <- [Ww] [Hh] [Ii] [Ll] [Ee]           !BodyId
WITH      <- [Ww] [Ii] [Tt] [Hh]              !BodyId
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/' 
util.testYes(dir, 'pas', p)

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/' 
util.testNo(dir, 'pas', p)
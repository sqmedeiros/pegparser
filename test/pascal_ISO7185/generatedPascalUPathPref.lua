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
	Inserted: 64 labels (64 correct)
]]

g = [[
program         <-  SKIP head^Err_001 decs block^Err_002 Dot^Err_003 !.
head            <-  PROGRAM^Err_004 Id^Err_005 (LPar ids^Err_006 RPar^Err_007)? Semi^Err_008
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL labels^Err_009 Semi^Err_010)?
labels          <-  label^Err_011 (Comma label^Err_012)*
label           <-  UInt
constDefs       <-  (CONST constDef^Err_013 Semi^Err_014 (constDef Semi^Err_015)*)?
constDef        <-  Id Eq^Err_016 const^Err_017
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE typeDef^Err_018 Semi^Err_019 (typeDef Semi^Err_020)*)?
typeDef         <-  Id Eq^Err_021 type^Err_022
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer Id^Err_023
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_024 ordinalType^Err_025 (Comma ordinalType^Err_026)* RBrack^Err_027 OF^Err_028 type^Err_029
recordType      <-  RECORD fieldList END^Err_030
setType         <-  SET OF^Err_031 ordinalType^Err_032
fileType        <-  FILE OF^Err_033 type^Err_034
ordinalType     <-  (newOrdinalType  /  Id)^Err_035
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id^Err_036 (Colon Id^Err_037)? OF^Err_038 variant^Err_039 (Semi variant)*
variant         <-  consts^Err_040 Colon^Err_041 LPar^Err_042 fieldList RPar^Err_043
consts          <-  const^Err_044 (Comma const^Err_045)*
varDecs         <-  (VAR varDec^Err_046 Semi^Err_047 (varDec Semi^Err_048)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_049)*
procDec         <-  procHeading Semi^Err_050 (decs block  /  Id)^Err_051
procHeading     <-  PROCEDURE^Err_052 Id^Err_053 formalParams?
funcDec         <-  funcHeading Semi^Err_054 (decs block  /  Id)^Err_055
funcHeading     <-  FUNCTION^Err_056 Id^Err_057 formalParams? Colon^Err_058 type^Err_059
formalParams    <-  LPar formalParamsSection^Err_060 (Semi formalParamsSection^Err_061)* RPar^Err_062
formalParamsSection <-  (VAR? ids Colon^Err_063 Id^Err_064  /  procHeading  /  funcHeading)^Err_065
block           <-  BEGIN^Err_066 stmts END^Err_067
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon^Err_068)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr
var             <-  Id (LBrack expr^Err_069 (Comma expr^Err_070)* RBrack^Err_071  /  Dot Id^Err_072  /  Pointer)*
procStmt        <-  Id^Err_073 params?
params          <-  LPar (param (Comma param^Err_074)*)? RPar
param           <-  expr (Colon expr)? (Colon expr^Err_075)?
gotoStmt        <-  GOTO^Err_076 label^Err_077
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  (ifStmt  /  caseStmt)^Err_078
ifStmt          <-  IF^Err_079 expr^Err_080 THEN^Err_081 stmt (ELSE stmt)?
caseStmt        <-  CASE^Err_082 expr^Err_083 OF^Err_084 caseListElement^Err_085 (Semi caseListElement)* Semi? END^Err_086
caseListElement <-  consts^Err_087 Colon^Err_088 stmt
repetitiveStmt  <-  (repeatStmt  /  whileStmt  /  forStmt)^Err_089
repeatStmt      <-  REPEAT^Err_090 stmts UNTIL^Err_091 expr^Err_092
whileStmt       <-  WHILE^Err_093 expr^Err_094 DO^Err_095 stmt
forStmt         <-  FOR^Err_096 Id^Err_097 Assign^Err_098 expr^Err_099 (TO  /  DOWNTO)^Err_100 expr^Err_101 DO^Err_102 stmt
withStmt        <-  WITH^Err_103 var^Err_104 (Comma var^Err_105)* DO^Err_106 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_107)?
simpleExpr      <-  Sign? term^Err_108 (AddOp term^Err_109)*
term            <-  factor^Err_110 (MultOp factor^Err_111)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr^Err_112 RPar^Err_113)^Err_114
unsignedConst   <-  (UNumber  /  String  /  Id  /  NIL)^Err_115
funcCall        <-  Id params
setConstructor  <-  LBrack^Err_116 (memberDesignator (Comma memberDesignator^Err_117)*)? RBrack^Err_118
memberDesignator <-  expr (DotDot expr^Err_119)?
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

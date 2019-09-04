local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'
local recovery = require 'recovery'
local lfs = require'lfs'
local re = require'relabel'
local ast = require'ast'
local util = require'util'

--[[
  	To be able to circumvent the limit imposed by MAXRULES,
  	changed label Err_011 to Err_010 in rule 'constDefs', 
  	and commented out rule Err_011. The recovery rules Err_010
  	and Err_011 have the same right-hand side.

	Removed:
		- Err_024 (DotDot in rule subrangeType)
		- Err_066 (Assign in rule assignStmt)
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
block           <-  BEGIN stmts END^Err_064
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon^Err_065)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr^Err_067
var             <-  Id (LBrack expr^Err_068 (Comma expr^Err_069)* RBrack^Err_070  /  Dot Id^Err_071  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param^Err_072)*)? RPar^Err_073
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
SPACE           <-  [ 	

]  /  COMMENT
SKIP            <-  ([ 	

]  /  COMMENT)*
Token           <-  WITH  /  WHILE  /  VAR  /  UReal  /  UNumber  /  UNTIL  /  UInt  /  TYPE  /  TO  /  THEN  /  String  /  Sign  /  Semi  /  SET  /  Reserved  /  RelOp  /  RPar  /  REPEAT  /  RECORD  /  RBrack  /  Pointer  /  PROGRAM  /  PROCEDURE  /  PACKED  /  OpenComment  /  OR  /  OF  /  NOT  /  NIL  /  MultOp  /  MOD  /  LPar  /  LBrack  /  LABEL  /  Id  /  IN  /  IF  /  GOTO  /  FUNCTION  /  FOR  /  FILE  /  Eq  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  DIV  /  Comma  /  Colon  /  CloseComment  /  CONST  /  COMMENT  /  CASE  /  BodyId  /  BEGIN  /  Assign  /  AddOp  /  ARRAY  /  AND
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!Dot EatToken)*
Err_002         <-  (!(!.) EatToken)*
Err_003         <-  (!(Semi  /  LPar) EatToken)*
Err_004         <-  (!RPar EatToken)*
Err_005         <-  (!Semi EatToken)*
Err_006         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_007         <-  (!(RPar  /  Comma  /  Colon) EatToken)*
Err_008         <-  (!Semi EatToken)*
Err_009         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_010         <-  (!(Semi  /  Comma) EatToken)*
Err_011         <-  (!Semi EatToken)*
Err_012         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_013         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_014         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_015         <-  (!Semi EatToken)*
Err_016         <-  (!Semi EatToken)*
Err_017         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_018         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_019         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_020         <-  (!Semi EatToken)*
Err_021         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_022         <-  (!RPar EatToken)*
Err_023         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_024         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_025         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_026         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_027         <-  (!(RBrack  /  Comma) EatToken)*
Err_028         <-  (!(RBrack  /  Comma) EatToken)*
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
Err_044         <-  (!(Comma  /  Colon) EatToken)*
Err_045         <-  (!Semi EatToken)*
Err_046         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_047         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_048         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_049         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_050         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_051         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_052         <-  (!Semi EatToken)*
Err_053         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_054         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_055         <-  (!Semi EatToken)*
Err_056         <-  (!(LPar  /  Colon) EatToken)*
Err_057         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_058         <-  (!(Semi  /  RPar) EatToken)*
Err_059         <-  (!(Semi  /  RPar) EatToken)*
Err_060         <-  (!(Semi  /  RPar) EatToken)*
Err_061         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_062         <-  (!Id EatToken)*
Err_063         <-  (!(Semi  /  RPar) EatToken)*
Err_064         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_065         <-  (!(WITH  /  WHILE  /  UNTIL  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_066         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_067         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_068         <-  (!(RBrack  /  Comma) EatToken)*
Err_069         <-  (!(RBrack  /  Comma) EatToken)*
Err_070         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_071         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_072         <-  (!(RPar  /  Comma) EatToken)*
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
Err_094         <-  (!(DO  /  Comma) EatToken)*
Err_095         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_096         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_097         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_098         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_099         <-  (!RPar EatToken)*
Err_100         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_101         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_102         <-  (!(RBrack  /  Comma) EatToken)*
Err_103         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_104         <-  (!(RBrack  /  Comma) EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/' 
util.testYes(dir, 'pas', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/' 
util.testNoRec(dir, 'pas', p)
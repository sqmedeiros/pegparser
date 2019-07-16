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
	Inserted: 72 labels (72 correct)
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
newPointerType  <-  Pointer Id
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_023 ordinalType^Err_024 (Comma ordinalType^Err_025)* RBrack^Err_026 OF^Err_027 type^Err_028
recordType      <-  RECORD fieldList END^Err_029
setType         <-  SET OF^Err_030 ordinalType^Err_031
fileType        <-  FILE OF^Err_032 type^Err_033
ordinalType     <-  (newOrdinalType  /  Id)^Err_034
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec^Err_035 Semi^Err_036 (varDec Semi^Err_037)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_038)*
procDec         <-  procHeading Semi^Err_039 (decs block  /  Id)^Err_040
procHeading     <-  PROCEDURE Id^Err_041 formalParams?
funcDec         <-  funcHeading Semi^Err_042 (decs block  /  Id)^Err_043
funcHeading     <-  FUNCTION Id^Err_044 formalParams? Colon^Err_045 type^Err_046
formalParams    <-  LPar formalParamsSection^Err_047 (Semi formalParamsSection^Err_048)* RPar^Err_049
formalParamsSection <-  (VAR? ids Colon^Err_050 Id^Err_051  /  procHeading  /  funcHeading)^Err_052
block           <-  BEGIN stmts END^Err_053
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr
var             <-  Id (LBrack expr (Comma expr)* RBrack  /  Dot Id  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_054
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_055 THEN^Err_056 stmt (ELSE stmt)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_057 expr^Err_058
whileStmt       <-  WHILE expr^Err_059 DO^Err_060 stmt
forStmt         <-  FOR Id^Err_061 Assign^Err_062 expr^Err_063 (TO  /  DOWNTO)^Err_064 expr^Err_065 DO^Err_066 stmt
withStmt        <-  WITH var^Err_067 (Comma var^Err_068)* DO^Err_069 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_070)?
simpleExpr      <-  Sign? term (AddOp term^Err_071)*
term            <-  factor (MultOp factor^Err_072)*
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
Token           <-  WITH  /  WHILE  /  VAR  /  UReal  /  UNumber  /  UNTIL  /  UInt  /  TYPE  /  TO  /  THEN  /  String  /  Sign  /  Semi  /  SET  /  Reserved  /  RelOp  /  RPar  /  REPEAT  /  RECORD  /  RBrack  /  Pointer  /  PROGRAM  /  PROCEDURE  /  PACKED  /  OpenComment  /  OR  /  OF  /  NOT  /  NIL  /  MultOp  /  MOD  /  LPar  /  LBrack  /  LABEL  /  Id  /  IN  /  IF  /  GOTO  /  FUNCTION  /  FOR  /  FILE  /  Eq  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  DIV  /  Comma  /  Colon  /  CloseComment  /  CONST  /  COMMENT  /  CASE  /  BodyId  /  BEGIN  /  Assign  /  AddOp  /  ARRAY  /  AND
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_002         <-  (!Dot EatToken)*
Err_003         <-  (!(!.) EatToken)*
Err_004         <-  (!Id EatToken)*
Err_005         <-  (!(Semi  /  LPar) EatToken)*
Err_006         <-  (!RPar EatToken)*
Err_007         <-  (!Semi EatToken)*
Err_008         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_009         <-  (!Semi EatToken)*
Err_010         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_011         <-  (!(Semi  /  Comma) EatToken)*
Err_012         <-  (!Semi EatToken)*
Err_013         <-  (!Semi EatToken)*
Err_014         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_015         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_016         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_017         <-  (!Semi EatToken)*
Err_018         <-  (!Semi EatToken)*
Err_019         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_020         <-  (!(VAR  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_021         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_022         <-  (!Semi EatToken)*
Err_023         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_024         <-  (!(RBrack  /  Comma) EatToken)*
Err_025         <-  (!RBrack EatToken)*
Err_026         <-  (!OF EatToken)*
Err_027         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_028         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_029         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_030         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_031         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_032         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_033         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_034         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_035         <-  (!Semi EatToken)*
Err_036         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_037         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_038         <-  (!BEGIN EatToken)*
Err_039         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_040         <-  (!Semi EatToken)*
Err_041         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_042         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_043         <-  (!Semi EatToken)*
Err_044         <-  (!(LPar  /  Colon) EatToken)*
Err_045         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_046         <-  (!(Semi  /  RPar) EatToken)*
Err_047         <-  (!(Semi  /  RPar) EatToken)*
Err_048         <-  (!RPar EatToken)*
Err_049         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_050         <-  (!Id EatToken)*
Err_051         <-  (!(Semi  /  RPar) EatToken)*
Err_052         <-  (!(Semi  /  RPar) EatToken)*
Err_053         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_054         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_055         <-  (!THEN EatToken)*
Err_056         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_057         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_058         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_059         <-  (!DO EatToken)*
Err_060         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_061         <-  (!Assign EatToken)*
Err_062         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_063         <-  (!(TO  /  DOWNTO) EatToken)*
Err_064         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_065         <-  (!DO EatToken)*
Err_066         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_067         <-  (!(DO  /  Comma) EatToken)*
Err_068         <-  (!DO EatToken)*
Err_069         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_070         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_071         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_072         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*	
]]


local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/' 
util.testYes(dir, 'pas', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/' 
util.testNoRec(dir, 'pas', p)

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
	Inserted: 80 labels (80 correct)
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
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec^Err_036 Semi^Err_037 (varDec Semi^Err_038)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi^Err_039)*
procDec         <-  procHeading Semi^Err_040 (decs block  /  Id)^Err_041
procHeading     <-  PROCEDURE Id^Err_042 formalParams?
funcDec         <-  funcHeading Semi^Err_043 (decs block  /  Id)^Err_044
funcHeading     <-  FUNCTION Id^Err_045 formalParams? Colon^Err_046 type^Err_047
formalParams    <-  LPar formalParamsSection^Err_048 (Semi formalParamsSection^Err_049)* RPar^Err_050
formalParamsSection <-  (VAR? ids Colon^Err_051 Id^Err_052  /  procHeading  /  funcHeading)^Err_053
block           <-  BEGIN stmts END^Err_054
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr
var             <-  Id (LBrack expr^Err_055 (Comma expr^Err_056)* RBrack^Err_057  /  Dot Id^Err_058  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_059
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_060 THEN^Err_061 stmt (ELSE stmt)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_062 expr^Err_063
whileStmt       <-  WHILE expr^Err_064 DO^Err_065 stmt
forStmt         <-  FOR Id^Err_066 Assign^Err_067 expr^Err_068 (TO  /  DOWNTO)^Err_069 expr^Err_070 DO^Err_071 stmt
withStmt        <-  WITH var^Err_072 (Comma var^Err_073)* DO^Err_074 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_075)?
simpleExpr      <-  Sign? term (AddOp term^Err_076)*
term            <-  factor (MultOp factor^Err_077)*
factor          <-  NOT* (funcCall  /  var  /  unsignedConst  /  setConstructor  /  LPar expr RPar)
unsignedConst   <-  UNumber  /  String  /  Id  /  NIL
funcCall        <-  Id params
setConstructor  <-  LBrack (memberDesignator (Comma memberDesignator^Err_078)*)? RBrack^Err_079
memberDesignator <-  expr (DotDot expr^Err_080)?
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
Err_012         <-  (!(Semi  /  Comma) EatToken)*
Err_013         <-  (!Semi EatToken)*
Err_014         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_015         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_016         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_017         <-  (!Semi EatToken)*
Err_018         <-  (!Semi EatToken)*
Err_019         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_020         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_021         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_022         <-  (!Semi EatToken)*
Err_023         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_024         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_025         <-  (!(RBrack  /  Comma) EatToken)*
Err_026         <-  (!(RBrack  /  Comma) EatToken)*
Err_027         <-  (!OF EatToken)*
Err_028         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_029         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_030         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_031         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_032         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_033         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_034         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_035         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_036         <-  (!Semi EatToken)*
Err_037         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_038         <-  (!(PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_039         <-  (!(PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_040         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_041         <-  (!Semi EatToken)*
Err_042         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_043         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  Id  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_044         <-  (!Semi EatToken)*
Err_045         <-  (!(LPar  /  Colon) EatToken)*
Err_046         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_047         <-  (!(Semi  /  RPar) EatToken)*
Err_048         <-  (!(Semi  /  RPar) EatToken)*
Err_049         <-  (!(Semi  /  RPar) EatToken)*
Err_050         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_051         <-  (!Id EatToken)*
Err_052         <-  (!(Semi  /  RPar) EatToken)*
Err_053         <-  (!(Semi  /  RPar) EatToken)*
Err_054         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_055         <-  (!(RBrack  /  Comma) EatToken)*
Err_056         <-  (!(RBrack  /  Comma) EatToken)*
Err_057         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_058         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  Pointer  /  OF  /  MultOp  /  LBrack  /  END  /  ELSE  /  DotDot  /  Dot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  Assign  /  AddOp) EatToken)*
Err_059         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_060         <-  (!THEN EatToken)*
Err_061         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_062         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_063         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_064         <-  (!DO EatToken)*
Err_065         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_066         <-  (!Assign EatToken)*
Err_067         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_068         <-  (!(TO  /  DOWNTO) EatToken)*
Err_069         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_070         <-  (!DO EatToken)*
Err_071         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_072         <-  (!(DO  /  Comma) EatToken)*
Err_073         <-  (!(DO  /  Comma) EatToken)*
Err_074         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_075         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_076         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_077         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_078         <-  (!(RBrack  /  Comma) EatToken)*
Err_079         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  MultOp  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*
Err_080         <-  (!(RBrack  /  Comma) EatToken)*
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/' 
util.testYes(dir, 'pas', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/' 
util.testNoRec(dir, 'pas', p)

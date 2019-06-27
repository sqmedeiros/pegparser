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
	Inserted: 60 labels (60 correct)
]]

g = [[
program         <-  SKIP head decs block Dot !.
head            <-  PROGRAM Id^Err_001 (LPar ids^Err_002 RPar^Err_003)? Semi^Err_004
decs            <-  labelDecs constDefs typeDefs varDecs procAndFuncDecs
ids             <-  Id (Comma Id)*
labelDecs       <-  (LABEL labels^Err_005 Semi^Err_006)?
labels          <-  label^Err_007 (Comma label^Err_008)*
label           <-  UInt
constDefs       <-  (CONST constDef^Err_009 Semi^Err_010 (constDef Semi^Err_011)*)?
constDef        <-  Id Eq^Err_012 const^Err_013
const           <-  Sign? (UNumber  /  Id)  /  String
typeDefs        <-  (TYPE typeDef^Err_014 Semi^Err_015 (typeDef Semi^Err_016)*)?
typeDef         <-  Id Eq^Err_017 type^Err_018
type            <-  newType  /  Id
newType         <-  newOrdinalType  /  newStructuredType  /  newPointerType
newOrdinalType  <-  enumType  /  subrangeType
newStructuredType <-  PACKED? unpackedStructuredType
newPointerType  <-  Pointer Id
enumType        <-  LPar ids RPar
subrangeType    <-  const DotDot const
unpackedStructuredType <-  arrayType  /  recordType  /  setType  /  fileType
arrayType       <-  ARRAY LBrack^Err_019 ordinalType^Err_020 (Comma ordinalType^Err_021)* RBrack^Err_022 OF^Err_023 type^Err_024
recordType      <-  RECORD fieldList END^Err_025
setType         <-  SET OF^Err_026 ordinalType^Err_027
fileType        <-  FILE OF^Err_028 type^Err_029
ordinalType     <-  (newOrdinalType  /  Id)^Err_030
fieldList       <-  ((fixedPart (Semi variantPart)?  /  variantPart) Semi?)?
fixedPart       <-  varDec (Semi varDec)*
variantPart     <-  CASE Id (Colon Id)? OF variant (Semi variant)*
variant         <-  consts Colon LPar fieldList RPar
consts          <-  const (Comma const)*
varDecs         <-  (VAR varDec Semi (varDec Semi)*)?
varDec          <-  ids Colon type
procAndFuncDecs <-  ((procDec  /  funcDec) Semi)*
procDec         <-  procHeading Semi (decs block  /  Id)
procHeading     <-  PROCEDURE Id^Err_031 formalParams?
funcDec         <-  funcHeading Semi (decs block  /  Id)
funcHeading     <-  FUNCTION Id^Err_032 formalParams? Colon^Err_033 type^Err_034
formalParams    <-  LPar formalParamsSection^Err_035 (Semi formalParamsSection^Err_036)* RPar^Err_037
formalParamsSection <-  (VAR? ids Colon^Err_038 Id^Err_039  /  procHeading  /  funcHeading)^Err_040
block           <-  BEGIN stmts END^Err_041
stmts           <-  stmt (Semi stmt)*
stmt            <-  (label Colon)? (simpleStmt  /  structuredStmt)?
simpleStmt      <-  assignStmt  /  procStmt  /  gotoStmt
assignStmt      <-  var Assign expr
var             <-  Id (LBrack expr (Comma expr)* RBrack  /  Dot Id  /  Pointer)*
procStmt        <-  Id params?
params          <-  LPar (param (Comma param)*)? RPar
param           <-  expr (Colon expr)? (Colon expr)?
gotoStmt        <-  GOTO label^Err_042
structuredStmt  <-  block  /  conditionalStmt  /  repetitiveStmt  /  withStmt
conditionalStmt <-  ifStmt  /  caseStmt
ifStmt          <-  IF expr^Err_043 THEN^Err_044 stmt (ELSE stmt)?
caseStmt        <-  CASE expr OF caseListElement (Semi caseListElement)* Semi? END
caseListElement <-  consts Colon stmt
repetitiveStmt  <-  repeatStmt  /  whileStmt  /  forStmt
repeatStmt      <-  REPEAT stmts UNTIL^Err_045 expr^Err_046
whileStmt       <-  WHILE expr^Err_047 DO^Err_048 stmt
forStmt         <-  FOR Id^Err_049 Assign^Err_050 expr^Err_051 (TO  /  DOWNTO)^Err_052 expr^Err_053 DO^Err_054 stmt
withStmt        <-  WITH var^Err_055 (Comma var^Err_056)* DO^Err_057 stmt
expr            <-  simpleExpr (RelOp simpleExpr^Err_058)?
simpleExpr      <-  Sign? term (AddOp term^Err_059)*
term            <-  factor (MultOp factor^Err_060)*
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
Err_001         <-  (!(Semi  /  LPar) EatToken)*
Err_002         <-  (!RPar EatToken)*
Err_003         <-  (!Semi EatToken)*
Err_004         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  LABEL  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_005         <-  (!Semi EatToken)*
Err_006         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  CONST  /  BEGIN) EatToken)*
Err_007         <-  (!(Semi  /  Comma) EatToken)*
Err_008         <-  (!Semi EatToken)*
Err_009         <-  (!Semi EatToken)*
Err_010         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_011         <-  (!(VAR  /  TYPE  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_012         <-  (!(UNumber  /  String  /  Sign  /  Id) EatToken)*
Err_013         <-  (!Semi EatToken)*
Err_014         <-  (!Semi EatToken)*
Err_015         <-  (!(VAR  /  PROCEDURE  /  Id  /  FUNCTION  /  BEGIN) EatToken)*
Err_016         <-  (!(VAR  /  PROCEDURE  /  FUNCTION  /  BEGIN) EatToken)*
Err_017         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_018         <-  (!Semi EatToken)*
Err_019         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_020         <-  (!(RBrack  /  Comma) EatToken)*
Err_021         <-  (!RBrack EatToken)*
Err_022         <-  (!OF EatToken)*
Err_023         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_024         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_025         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_026         <-  (!(UNumber  /  String  /  Sign  /  LPar  /  Id) EatToken)*
Err_027         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_028         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_029         <-  (!(Semi  /  RPar  /  END) EatToken)*
Err_030         <-  (!(Semi  /  RPar  /  RBrack  /  END  /  Comma) EatToken)*
Err_031         <-  (!(Semi  /  RPar  /  LPar) EatToken)*
Err_032         <-  (!(LPar  /  Colon) EatToken)*
Err_033         <-  (!(UNumber  /  String  /  Sign  /  SET  /  RECORD  /  Pointer  /  PACKED  /  LPar  /  Id  /  FILE  /  ARRAY) EatToken)*
Err_034         <-  (!(Semi  /  RPar) EatToken)*
Err_035         <-  (!(Semi  /  RPar) EatToken)*
Err_036         <-  (!RPar EatToken)*
Err_037         <-  (!(Semi  /  RPar  /  Colon) EatToken)*
Err_038         <-  (!Id EatToken)*
Err_039         <-  (!(Semi  /  RPar) EatToken)*
Err_040         <-  (!(Semi  /  RPar) EatToken)*
Err_041         <-  (!(UNTIL  /  Semi  /  END  /  ELSE  /  Dot) EatToken)*
Err_042         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_043         <-  (!THEN EatToken)*
Err_044         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_045         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_046         <-  (!(UNTIL  /  Semi  /  END  /  ELSE) EatToken)*
Err_047         <-  (!DO EatToken)*
Err_048         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_049         <-  (!Assign EatToken)*
Err_050         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_051         <-  (!(TO  /  DOWNTO) EatToken)*
Err_052         <-  (!(UNumber  /  String  /  Sign  /  NOT  /  NIL  /  LPar  /  LBrack  /  Id) EatToken)*
Err_053         <-  (!DO EatToken)*
Err_054         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_055         <-  (!(DO  /  Comma) EatToken)*
Err_056         <-  (!DO EatToken)*
Err_057         <-  (!(WITH  /  WHILE  /  UNTIL  /  UInt  /  Semi  /  REPEAT  /  Id  /  IF  /  GOTO  /  FOR  /  END  /  ELSE  /  CASE  /  BEGIN) EatToken)*
Err_058         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_059         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon) EatToken)*
Err_060         <-  (!(UNTIL  /  TO  /  THEN  /  Semi  /  RelOp  /  RPar  /  RBrack  /  OF  /  END  /  ELSE  /  DotDot  /  DOWNTO  /  DO  /  Comma  /  Colon  /  AddOp) EatToken)*	
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/yes/' 
util.testYes(dir, 'pas', p)

util.setVerbose(true)
print""
local dir = lfs.currentdir() .. '/test/pascal_ISO7185/test/no/' 
util.testNoRec(dir, 'pas', p)

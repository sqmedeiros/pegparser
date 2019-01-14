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
]]

local g, l = m.match(g)

print("Regular Annotation")
local glab = recovery.addlab(g, true, false)
print(pretty.printg(glab))
print("\n\n\n")


print("Conservative Annotation (Hard)")
local glab = recovery.addlab(g, true, true)
print(pretty.printg(glab))
print("\n\n\n")


print("Conservative Annotation (Soft)")
local glab = recovery.addlab(g, true, 'soft')
print(pretty.printg(glab))
print()

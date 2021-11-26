local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
graph           <-  (STRICT  /  !(GRAPH  /  DIGRAPH  /  !.) %{Err_001} EatToken Err_001_Rec)? (GRAPH  /  DIGRAPH^Err_002)^Err_003 (id  /  !('{'  /  !.) %{Err_004} EatToken Err_004_Rec)? '{'^Err_005 stmt_list '}'^Err_006
stmt_list       <-  (stmt ';'?)*
stmt            <-  id '=' id  /  edge_stmt  /  node_stmt  /  attr_stmt  /  subgraph
stmt            <-  id '=' id  /  edge_stmt  /  node_stmt  /  attr_stmt  /  subgraph
attr_stmt       <-  (GRAPH  /  NODE  /  EDGE) attr_list^Err_007
attr_list       <-  ('[' (a_list  /  !(']'  /  !.) %{Err_008} EatToken Err_008_Rec)? ']'^Err_009)+
a_list          <-  (id ('=' id^Err_010  /  !(']'  /  ','  /  !.) %{Err_011} EatToken Err_011_Rec)? (','  /  !(']'  /  !.) %{Err_012} EatToken Err_012_Rec)?)+
edge_stmt       <-  (node_id  /  subgraph) edgeRHS (attr_list  /  !('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  ';'  /  !.) %{Err_013} EatToken Err_013_Rec)?
edgeRHS         <-  (edgeop (node_id  /  subgraph^Err_014)^Err_015)+
edgeop          <-  '->'  /  '--'
node_stmt       <-  node_id attr_list?
node_id         <-  id port?
port            <-  ':' id (':' id^Err_016)?
subgraph        <-  (SUBGRAPH (id  /  !('{'  /  !.) %{Err_017} EatToken Err_017_Rec)?)? '{' stmt_list '}'
id              <-  ID  /  STRING  /  HTML_STRING  /  NUMBER
STRICT          <-  [Ss] [Tt] [Rr] [Ii] [Cc] [Tt]
GRAPH           <-  [Gg] [Rr] [Aa] [Pp] [Hh]
DIGRAPH         <-  [Dd] [Ii] [Gg] [Rr] [Aa] [Pp] [Hh]
NODE            <-  [Nn] [Oo] [Dd] [Ee]
EDGE            <-  [Ee] [Dd] [Gg] [Ee]
SUBGRAPH        <-  [Ss] [Uu] [Bb] [Gg] [Rr] [Aa] [Pp] [Hh]
NUMBER          <-  [0-9]+ ('.' !'.' [0-9]*)?
DIGIT           <-  [0-9]
STRING          <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
ID              <-  (LETTER  /  '_') (LETTER  /  DIGIT  /  '_')*
LETTER          <-  [a-zA-Z]
HTML_STRING     <-  '<' (TAG  /  ![<>] .)* '>'
TAG             <-  '<' (.*)? '>'
COMMENT         <-  '/*' (!'*/' .)* '*/'
LINE_COMMENT    <-  '//' (!('\r'? '\n') .)* '\r'? '\n'
PREPROC         <-  '#' !([\r\n]*)
NUMBER          <-  [0-9]+ ('.' !'.' [0-9]*)?
EOF             <-  !.
SPACE           <-  [ 	
]  /  COMMENT
SKIP            <-  ([ 	
]  /  COMMENT)*
Token           <-  '}'  /  '{'  /  TAG  /  SUBGRAPH  /  STRING  /  STRICT  /  PREPROC  /  NUMBER  /  NODE  /  LINE_COMMENT  /  LETTER  /  ID  /  HTML_STRING  /  GRAPH  /  EOF  /  EDGE  /  DIGRAPH  /  DIGIT  /  COMMENT  /  ']'  /  '['  /  '='  /  ';'  /  ':'  /  '->'  /  '--'  /  ','
EatToken        <-  (Token  /  (!SPACE .)+) SKIP
Err_001         <-  ''
Err_001_Rec     <-  (!STRICT !(GRAPH  /  DIGRAPH  /  !.) EatToken)?
Err_002         <-  (!('{'  /  STRING  /  NUMBER  /  ID  /  HTML_STRING) EatToken SKIP)*
Err_003         <-  (!('{'  /  STRING  /  NUMBER  /  ID  /  HTML_STRING) EatToken SKIP)*
Err_004         <-  ''
Err_004_Rec     <-  (!(STRING  /  NUMBER  /  ID  /  HTML_STRING) !('{'  /  !.) EatToken)?
Err_005         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE) EatToken SKIP)*
Err_006         <-  (!(!.) EatToken SKIP)*
Err_007         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  ';') EatToken SKIP)*
Err_008         <-  ''
Err_008_Rec     <-  (!(STRING  /  NUMBER  /  ID  /  HTML_STRING) !(']'  /  !.) EatToken)?
Err_009         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  ';') EatToken SKIP)*
Err_010         <-  (!(']'  /  ',') EatToken SKIP)*
Err_011         <-  ''
Err_011_Rec     <-  (!'=' !(']'  /  ','  /  !.) EatToken)?
Err_012         <-  ''
Err_012_Rec     <-  (!',' !(']'  /  !.) EatToken)?
Err_013         <-  ''
Err_013_Rec     <-  (!'[' !('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  ';'  /  !.) EatToken)?
Err_014         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  '['  /  ';') EatToken SKIP)*
Err_015         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  '['  /  ';') EatToken SKIP)*
Err_016         <-  (!('}'  /  '{'  /  SUBGRAPH  /  STRING  /  NUMBER  /  NODE  /  ID  /  HTML_STRING  /  GRAPH  /  EDGE  /  '['  /  ';'  /  '->'  /  '--') EatToken SKIP)*
Err_017         <-  ''
Err_017_Rec     <-  (!(STRING  /  NUMBER  /  ID  /  HTML_STRING) !('{'  /  !.) EatToken)?
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'dot', p)
util.setVerbose(true)
util.testNoRec(dir .. '/test/no/', 'dot', p)

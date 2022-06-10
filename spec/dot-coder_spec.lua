local Parser = require"parser"
local Coder = require"coder"
local Pretty = require'pretty'

describe("Testing #dotcoder", function()


    test("Example  based on DOT Grammar", function()
        local g = Parser.match[[
graph           <-  STRICT? (GRAPH  /  DIGRAPH) id? '{' stmt_list '}'
stmt_list       <-  (stmt ';'?)*
--stmt            <-  attr_stmt  /  !(edge_stmt  /  id '=' id) node_stmt  /  !(id '=' id  /  subgraph) edge_stmt  /  id '=' id  /  subgraph
stmt   <-   edge_stmt   /  attr_stmt   /  id '=' id   /  node_stmt   /  subgraph
attr_stmt       <-  (GRAPH  /  NODE  /  EDGE) attr_list
attr_list       <-  ('[' a_list? ']')+
a_list          <-  (id ('=' id)? ','?)+
edge_stmt       <-  (node_id  /  subgraph) edgeRHS attr_list?
edgeRHS         <-  (edgeop (node_id  /  subgraph))+
edgeop          <-  '->'  /  '--'
node_stmt       <-  node_id attr_list?
node_id         <-  id port?
port            <-  ':' id (':' id)?
subgraph        <-  (SUBGRAPH id?)? '{' stmt_list '}'
id              <-  ID  /  STRING  /  HTML_STRING  /  NUMBER
STRICT          <-  [Ss] [Tt] [Rr] [Ii] [Cc] [Tt]
GRAPH           <-  [Gg] [Rr] [Aa] [Pp] [Hh]
DIGRAPH         <-  [Dd] [Ii] [Gg] [Rr] [Aa] [Pp] [Hh]
NODE            <-  [Nn] [Oo] [Dd] [Ee]
EDGE            <-  [Ee] [Dd] [Gg] [Ee]
SUBGRAPH        <-  [Ss] [Uu] [Bb] [Gg] [Rr] [Aa] [Pp] [Hh]
NUMBER          <-  '-'? ('.' DIGIT+  /  DIGIT+ ('.' DIGIT*)?)
DIGIT           <-  [0-9]
STRING          <-  '"' (!'"' ('\\"'  /  .))* '"'
ID              <-  !SUBGRAPH LETTER (LETTER  /  DIGIT)*
LETTER          <-  [a-zA-Z_]
HTML_STRING     <-  '<' (TAG  /  ![<>] .)* '>'
TAG             <-  '<' (!'>' .)* '>'
COMMENT         <-  '/*' (!'*/' .)* '*/'
LINE_COMMENT    <-  '//' (!('\r'? '\n') .)* '\r'? '\n'
PREPROC         <-  '#' (![\r\n] .)*
WS              <-  [ \t\n\r]+
__IdBegin       <-  LETTER
__IdRest        <-  (LETTER  /  DIGIT)*
		]]

		assert(g)
		local pretty = Pretty.new()
		print(pretty:printg(g, nil, true))

		local lpegParser = Coder.makeg(g)
    
		
    end)


end)

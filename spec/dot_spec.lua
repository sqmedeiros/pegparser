local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkConversionToPeg (stringG, stringPeg, config)
	local g = Parser.match(stringG)
	assert.is_not_nil(g)
	
	config = config or {}
	
	local c2p = Cfg2Peg.new(g)
	c2p:setUsePrefix(config.prefix)
	c2p:setUseUnique(config.unique)
	c2p:convert(config.idRule, config.reserved)
	
	local peg = c2p.peg
    local pretty = Pretty.new()
    local equal = Util.sameWithoutSpace(pretty:printg(peg, nil, true), stringPeg)
    
    if not equal then
		print("---- Different ----\n")
		print(">>>> Generated PEG <<<<")
		print(pretty:printg(peg, nil, true))
		print("\n**** Expected PEG ****")
		print(stringPeg)
		print("")
    end
    
    assert.is_true(equal)
end


describe("Transforming a CFG into an equivalent PEG\n", function()

    local pretty = Pretty.new()


    test("Converting DOT grammar - Dealing with reserved words", function()
        local g = [[
graph   <-   STRICT? (GRAPH   /  DIGRAPH ) id? '{' stmt_list '}'
stmt_list   <-   (stmt ';'? )*
stmt   <-   node_stmt   /  edge_stmt   /  attr_stmt   /  id '=' id   /  subgraph
attr_stmt   <-   (GRAPH   /  NODE   /  EDGE ) attr_list
attr_list   <-   ('[' a_list? ']' )+
a_list   <-   (id ('=' id )? ','? )+
edge_stmt   <-   (node_id   /  subgraph ) edgeRHS attr_list?
edgeRHS   <-   (edgeop (node_id   /  subgraph ) )+
edgeop   <-   '->'   /  '--'
node_stmt   <-   node_id attr_list?
node_id   <-   id port?
port   <-   ':' id (':' id )?
subgraph   <-   (SUBGRAPH id? )? '{' stmt_list '}'
id   <-   ID   /  STRING   /  HTML_STRING   /  NUMBER
STRICT   <-   [Ss] [Tt] [Rr] [Ii] [Cc] [Tt]
GRAPH   <-   [Gg] [Rr] [Aa] [Pp] [Hh]
DIGRAPH   <-   [Dd] [Ii] [Gg] [Rr] [Aa] [Pp] [Hh]
NODE   <-   [Nn] [Oo] [Dd] [Ee]
EDGE   <-   [Ee] [Dd] [Gg] [Ee]
SUBGRAPH   <-   [Ss] [Uu] [Bb] [Gg] [Rr] [Aa] [Pp] [Hh]
NUMBER   <-   '-'? ('.' DIGIT+  /  DIGIT+ ('.' DIGIT*)?)
DIGIT   <-   [0-9]
STRING   <-   '"' ('\\"'  /  .)*? '"'
ID   <-   LETTER (LETTER  /  DIGIT)*
LETTER   <-   [a-zA-Z\u0080-\u00FF_]
HTML_STRING   <-   '<' (TAG  /  (![<>] .))* '>'
TAG   <-   '<' .*? '>'
COMMENT   <-   '/*' .*? '*/'
LINE_COMMENT   <-   '//' .*? '\r'? '\n'
PREPROC   <-   '#' (![\r\n] .)*
WS   <-   [ \t\n\r]+
]]

	local peg = [[
graph   <-   STRICT? (GRAPH   /  DIGRAPH ) id? '{' stmt_list '}'
stmt_list   <-   (stmt ';'? )*
stmt   <-   attr_stmt   /  node_stmt   /  edge_stmt   /    id '=' id   /  subgraph
attr_stmt   <-   (GRAPH   /  NODE   /  EDGE ) attr_list
attr_list   <-   ('[' a_list? ']' )+
a_list   <-   (id ('=' id )? ','? )+
edge_stmt   <-   (node_id   /  subgraph ) edgeRHS attr_list?
edgeRHS   <-   (edgeop (node_id   /  subgraph ) )+
edgeop   <-   '->'   /  '--'
node_stmt   <-   node_id attr_list?
node_id   <-   id port?
port   <-   ':' id (':' id )?
subgraph   <-   (SUBGRAPH id? )? '{' stmt_list '}'
id   <-   ID   /  STRING   /  HTML_STRING   /  NUMBER
STRICT   <-   [Ss] [Tt] [Rr] [Ii] [Cc] [Tt]
GRAPH   <-   [Gg] [Rr] [Aa] [Pp] [Hh]
DIGRAPH   <-   [Dd] [Ii] [Gg] [Rr] [Aa] [Pp] [Hh]
NODE   <-   [Nn] [Oo] [Dd] [Ee]
EDGE   <-   [Ee] [Dd] [Gg] [Ee]
SUBGRAPH   <-   [Ss] [Uu] [Bb] [Gg] [Rr] [Aa] [Pp] [Hh]
NUMBER   <-   '-'? ('.' DIGIT+  /  DIGIT+ ('.' DIGIT*)?)
DIGIT   <-   [0-9]
STRING   <-   '"' (!'"' ('\\"'  /  .))* '"'
ID   <-   LETTER (LETTER  /  DIGIT)*
LETTER   <-   [a-zA-Z\u0080-\u00FF_]
HTML_STRING   <-   '<' (TAG  /  ![<>] .)* '>'
TAG   <-   '<' (!'>' .)* '>'
COMMENT   <-   '/*' ( !'*/' .)* '*/'
LINE_COMMENT   <-   '//' (!('\r'? '\n') .)* '\r'? '\n'
PREPROC   <-   '#' (![\r\n] .)*
WS   <-   [ \t\n\r]+
]]
	checkConversionToPeg(g, peg, {unique = true})

    end)
end)

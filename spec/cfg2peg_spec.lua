local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkGPrint (g, s, withLex)
    assert.is_not_nil(g)
    assert.is_not_nil(s)
    local pretty = Pretty.new()
    local equal = Util.sameWithoutSpace(pretty:printg(g, nil, withLex), s)
    if not equal then
		print("Different\n\n       ")
		print(pretty:printg(g))
    end
    return equal
end


describe("Transforming a CFG into an equivalent PEG\n", function()

    local pretty = Pretty.new()

	test("Identifying the rule that matches an identifier", function()
		local g = Parser.match[[
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('Id')

        local peg = [[
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)

	test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = Parser.match[[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('Id')

        local peg = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)
	
	test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = Parser.match[[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		
		c2p:setPredUse(true)
		c2p:convert('Id')
		pretty = Pretty.new()
		pretty:printg(c2p.peg)

        local peg = [[
			a   <- 'a' / 'y'
            b   <- !('a''y') 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)

    test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = Parser.match[[
			s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y' / 'y''z'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('Id')

        local peg = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		--assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)

	test("Converting lazy repetitions", function()
        local g = Parser.match[[
            X <- '<p>' .*? '</p>'
            Y   <- ('a' / 'b')*? 'c'
            Z   <-  'a'?? ('a' / 'b')
            id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('id')

        local peg = [[
            X   <- '<p>' (!'</p>' .)* '</p>'
            Y   <- (!'c' ('a' / 'b'))* 'c'
            Z   <- (!('a' / 'b') 'a')? ('a' / 'b')
			id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)

    test("Converting DOT grammar", function()
        local g = Parser.match[[
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

        local c2p = Cfg2Peg.new(g)
		c2p:convert('ID')

        print(pretty:printg(c2p.peg, nil, true))
        local Coder = require"coder"
        local parser = Coder.makeg(c2p.peg)
        local input = "graph { }"
        assert.equal(parser:match(input), #input + 1)
    end)
end)

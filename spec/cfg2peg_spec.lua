local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkConversionToPeg (stringG, stringPeg, idRule, withLex, predUse)
	local g = Parser.match(stringG)
	assert.is_not_nil(g)
	
	local c2p = Cfg2Peg.new(g)
	c2p:setPredUse(predUse)
	c2p:convert(idRule)
	
	local peg = c2p.peg
    local pretty = Pretty.new()
    local equal = Util.sameWithoutSpace(pretty:printg(peg, nil, withLex), stringPeg)
    
    if not equal then
		print("---- Different ----\n")
		print(">>>> Generated PEG <<<<")
		print(pretty:printg(peg))
		print("\n**** Expected PEG ****")
		print(stringPeg)
		print("")
    end
    
    assert.is_true(equal)
end


describe("Transforming a CFG into an equivalent PEG\n", function()

    local pretty = Pretty.new()

	--[==[test("Identifying the rule that matches an identifier", function()
		local g = [[
			Id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
			Id  <- [a-z] [a-z0-9]*
        ]] 

		checkConversionToPeg(g, peg, 'Id', true)
	end)]==]

	test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]]

		checkConversionToPeg(g, peg, 'Id', true)
	end)
	
	--[==[test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
			a   <- 'a' / 'y'
            b   <- !('a''y') 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]]

		checkConversionToPeg(g, peg, 'Id', true, true)
	end)

    test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y' / 'y''z'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]]

		checkConversionToPeg(g, peg, 'Id', true)
	end)

	test("Converting lazy repetitions", function()
        local g = [[
            X <- '<p>' .*? '</p>'
            Y   <- ('a' / 'b')*? 'c'
            Z   <-  'a'?? ('a' / 'b')
            id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
            X   <- '<p>' (!'</p>' .)* '</p>'
            Y   <- (!'c' ('a' / 'b'))* 'c'
            Z   <- (!('a' / 'b') 'a')? ('a' / 'b')
			id  <- [a-z] [a-z0-9]*
        ]]

		checkConversionToPeg(g, peg, 'id', true)
	end)
	
	
	test("Not matching keywords as identifiers", function()
        local g = [[
            s <- 'there' 'are' 'AB'
            x <- 'x9' '3' y
            y <- ('bb' z)*
            z <- id
            id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
            s <- 'there' 'are' 'AB'
            x <- 'x9' '3' y
            y <- ('bb' z)*
            z <- id
            id  <- [a-z] [a-z0-9]*
        ]]

		checkConversionToPeg(g, peg, 'id', true)
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
    end)]==]
end)

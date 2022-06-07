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

	test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
		]]

        local peg = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
        ]]

		checkConversionToPeg(g, peg)
	end)
	
	test([[Checking if some of the non-disjoint alternatives is a prefix of the other ones]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
		]]

        local peg = [[
			a   <- 'a' / 'y'
            b   <- 'a''y' / 'a'
        ]]

		checkConversionToPeg(g, peg, {prefix = true})
	end)

    test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y' / 'y''z'
            b   <- 'a' / 'a''y'
		]]

        local peg = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a' / 'a''y'
        ]]

		checkConversionToPeg(g, peg, {unique = true})
	end)


    test([[Applying #here unique, prefix and unique+prefix]], function()
		local g = [[
			s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y' / 'y''z'
            b   <- 'a' / 'a''y'
		]]

        local pegUnique = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a' / 'a''y'
        ]]

        local pegPrefix = [[
            s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a''y' / 'a'
        ]]

        local pegUniquePrefix = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a''y' / 'a'
        ]]

        checkConversionToPeg(g, pegUnique, {unique = true})
        checkConversionToPeg(g, pegPrefix, {prefix = true})
        checkConversionToPeg(g, pegUniquePrefix, {unique = true, prefix = true})
	end)


	test("Converting lazy repetitionsss", function()
        
        -- converts only lazy repetitions in lexical rules
        local g = [[
			x <- '[' X+? ']'
            X <- '<p>' .*? '</p>'
            Y   <- ('a' / 'b')*? 'c'
            Z   <-  'a'?? ('a' / 'b')
		]]

        local peg = [[
			x <- '[' (X+)? ']'
            X   <- '<p>' (!'</p>' .)* '</p>'
            Y   <- (!'c' ('a' / 'b'))* 'c'
            Z   <- (!('a' / 'b') 'a')? ('a' / 'b')
        ]]

		checkConversionToPeg(g, peg)
	end)


	test("Identifying the rule that matches an identifier", function()
		local g = [[
			Id  <- [a-z] [a-z0-9]*
		]]

		-- I'm favoring readability here, so I used __IdRest directly instead of Cfg2Peg.IdRest
        local peg = [[
			Id  <- [a-z] [a-z0-9]*
			__IdBegin <- [a-z]
			__IdRest <- [a-z0-9]
        ]] 

		checkConversionToPeg(g, peg, { idRule = 'Id', reserved = true})
	end)
	
	
	test("Converting p* non-disjoint repetitions in syntactical rules", function()
		local g = [[
			s  <- 'id'* x
			x  <- 'id' 'bolo' / 'bola'
		]]

		-- When generating the predicate, we sort the symbols lexicographically
		-- Thus, the generated predicate is &('bola' / 'id')  instead of &('id' / 'bola')
        local peg = [[
			s  <- __rep_001 x
			x  <- 'id' 'bolo' / 'bola'
			__rep_001 <- 'id' __rep_001 / &('bola' / 'id')
		]]

		checkConversionToPeg(g, peg)
	end)
	
	test("Converting p+ non-disjoint repetitions in syntactical rules", function()
		local g = [[
			s  <- s1 s2
			s1 <-'a'*
			s2 <- x
			x  <- 'a'? 'b' 'c' / 'd'
		]]

		
        local peg = [[
			s  <- s1 s2
			s1 <- __rep_001
			s2 <- x
			x  <- 'a'? 'b' 'c' / 'd'
			__rep_001 <- 'a' __rep_001 / &('a' / 'b' / 'd')
		]]

		checkConversionToPeg(g, peg)
	end)
	
	test("Converting p? non-disjoint repetitions in syntactical rules", function()
		local g = [[
			s  <- s1 s2? s3
			s1 <- 'a'?
			s2 <- x
			s3 <- 'b'
			x  <- 'a'? 'b' 'c' / 'd'
		]]

		
        local peg = [[
			s  <- s1 __rep_001 s3
			s1 <- __rep_002
			s2 <- x
			s3 <- 'b'
			x  <- 'a'? 'b' 'c' / 'd'
			__rep_001 <- s2 &'b'  /  ''
			__rep_002 <- 'a' &('a' / 'b' / 'd')  /  ''
		]]

		checkConversionToPeg(g, peg)
	end)
	
    
	test([[Extra checks to not mismatch identifiers and reserved words]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		-- I'm favoring readability here, so I used __IdRest directly instead of Cfg2Peg.IdRest
        local peg = [[
			a   <-  ZLex_001 / ZLex_002
            b   <- ZLex_001 / ZLex_001 ZLex_002
			Id  <- !__Keywords [a-z] [a-z0-9]*
			__IdBegin <- [a-z]
			__IdRest <- [a-z0-9]
			ZLex_001 <- 'a' !__IdRest
			ZLex_002 <- 'y' !__IdRest
			__Keywords <- ZLex_001 / ZLex_002
        ]]

		checkConversionToPeg(g, peg, {idRule = 'Id', reserved = true})
	end)
	
	test("Not matching keywords as identifiers", function()
        local g = [[
            s <- 'there' 'AB'
            x <- 'x9' '3' y
            y <- ('bb' z)*
            z <- id
            Number <- ('x' / 'X') [0-9]+
            id  <- [a-z] [a-z0-9]*
		]]

        local peg = [[
            s <- ZLex_001 ZLex_002
            x <- ZLex_003  ZLex_004 y
            y <- (ZLex_005 z)*
            z <- id
            Number <- ('x' / 'X') [0-9]+ !__IdRest
            id  <- !__Keywords [a-z] [a-z0-9]*
            __IdBegin <- [a-z]
            __IdRest <- [a-z0-9]
            ZLex_001 <- 'there' !__IdRest
            ZLex_002 <- 'AB' !__IdRest
            ZLex_003 <- 'x9' !__IdRest
            ZLex_004 <- '3'
            ZLex_005 <- 'bb' !__IdRest
            __Keywords <- Number / ZLex_001 / ZLex_002 / ZLex_003 / ZLex_005
        ]]

		checkConversionToPeg(g, peg, {idRule = 'id', reserved = true})
	end)
	

    test("Converting DOT grammar - Not dealing with reserved words", function()
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

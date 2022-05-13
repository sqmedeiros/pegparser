local Parser = require"parser"
local Coder = require"coder"
local Pretty = require'pretty'

describe("Testing #coder", function()

	test("Simple grammar", function()
		local g = Parser.match[[
			s <- 'a'
		]]
		
		assert(g)
		
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("a"), 2)
		assert.equal(lpegParser:match("x"), nil)
		assert.equal(lpegParser:match(" a"), 3)
		assert.equal(lpegParser:match("  x"), nil)
		assert.equal(lpegParser:match("a  "), 4)
		assert.equal(lpegParser:match("a  b"), 4)
		assert.equal(lpegParser:match("x  "), nil)
	end)

	test("Grammar that uses a predefined rule (EOF)", function()
		local g = Parser.match[[
			s <- 'a' EOF
		]]

		assert(g)
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("a"), 2)
		assert.equal(lpegParser:match("x"), nil)
		assert.equal(lpegParser:match(" a"), 3)
		assert.equal(lpegParser:match("  x"), nil)
		assert.equal(lpegParser:match("a  "), 4)
		assert.equal(lpegParser:match("a  b"), nil)
		assert.equal(lpegParser:match("x  "), nil)
	end)

	test("Grammar with lexical and syntactical rules", function()
		local g = Parser.match[[
			s <- "a" B
			B <- "b" "c"
		]]
		
		assert(g)
		
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match(" a bc"), 6)
		assert.equal(lpegParser:match(" a b c"), nil)
		assert.equal(lpegParser:match("abc"), 4)
		assert.equal(lpegParser:match("a bc"), 5)
		assert.equal(lpegParser:match(" a  bc  "), 9)
	end)


	test("Grammar with balanced 0's and 1's)", function()

		local g = Parser.match[[
  			S <- "0" B / "1" A / ""   -- balanced strings
  			A <- "0" S / "1" A A      -- one more 0
  			B <- "1" S / "0" B B      -- one more 1
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("00011011"), 9)
		assert.equal(lpegParser:match("0 0011011"), 1)
		assert.equal(lpegParser:match(" 00011011"), 1)
		assert.equal(lpegParser:match("1000110101"), 11)
		assert.equal(lpegParser:match("10"), 3)
		assert.equal(lpegParser:match("011"), 3)
	end)

	test("Another grammar with balanced 0's and 1's", function()
		
		local g = Parser.match[[
  			S <- ("0" B / "1" A)*
  			A <- "0" / "1" A A
  			B <- "1" / "0" B B
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("00011011"),  9)
		assert.equal(lpegParser:match("000110110"), 9)
		assert.equal(lpegParser:match("011110110"), 3)
		assert.equal(lpegParser:match("000110010"), 1)
	end)

	test("Grammar with set and repetition expressions", function()
		
		local g = Parser.match[[
  			s <- 'a'? 'b'+ a
  			a <- [f-i]
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("abf"),  4)
		assert.equal(lpegParser:match("bg"), 3)
		assert.equal(lpegParser:match("f"), nil)
		assert.equal(lpegParser:match("abbg"), 5)
		assert.equal(lpegParser:match("abbj"), nil)
	end)


	test("Grammar with predicates", function()
		
		local g = Parser.match[[
  			s <- !'a' &[a-z] [a-e]
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match(""),  nil)
		assert.equal(lpegParser:match("a"), nil)
		assert.equal(lpegParser:match("c"), 2)
		assert.equal(lpegParser:match("C"), nil)
		assert.equal(lpegParser:match("x"), nil)
	end)


    test("Grammar with special chars \n, \t, \r \"", function()

		local g = Parser.match[[
            S  <- ID X Y / '\"' / '\\"'
            ID <- 'a' '\n' 'b'
            X  <- '\t'
            Y  <- '\r'
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
        s = "a\nb\t\r"
        assert.equal(lpegParser:match(s), #s + 1)
        s = '\"'
        assert.equal(lpegParser:match(s), #s + 1)
        s = '\\"'
        assert.equal(lpegParser:match(s), #s + 1)
	end)


    test("Grammar with comments", function()

		local g = Parser.match[[
            s  <- ('a' / 'b' / 'c')*
  			COMMENT <- ';' (!'\n' .)* '\n'
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
        s = "a ;first value\n   b  ;second value\n"
        assert.equal(lpegParser:match(s), #s + 1)
	end)

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
		
		-- From grammarinator/tests/test_126522630474033329934257061968943229555.dot
		-- Put !SUBGRAPH in rule ID
        s = [[
gRApH {
	x -- subgraph {} []
}
]]
        local r, lab, errpos = lpegParser:match(s)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(s), #s + 1)

		-- From gramm-yes/test_102732708493124451334731538444127072047.dot
		s = [[ dIGrAPh { gRaph [ <<><>	d><>><>>  ]   } ]]
	    s = [[ dIGrAPh { gRaph [ <<><>	d><><>  ]   }  ]]
		local r, lab, errpos = lpegParser:match(s)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(s), #s + 1)

		-- From gramm-yes/test_190150491296943988504710630270160722343.dot
		-- special symbol PAD
	    s = [[ GRaph {
	    "&}"  : <጑>    ->  ""   --  { SUBgrApH { SUBgrApH {  }  ->
	    C   --  {  }  ->  <>  : ""  ->  <>  : ""       noDE [ I6  = PAD   ]    ;  }
	    <<>𖽿<>>  = 105   ;  }  ->  ""      ; NOdE [ <>  <ᜍ>  = <<X>>   ]    ; {  }    }
]]

		local r, lab, errpos = lpegParser:match(s)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(s), #s + 1)

		-- From grammarinator/testsSimpleId/test_273338121150092584181509196004485960627.dot
		-- Generated a not valid HTML_STRING: <<V>><X.><]&.><><><Ty3></>>
		-- <<V>> only is a valid HTML_STRING
	    s = [[ sTRicT GrapH <<V>>  { {  }   ; sUbGraPh ""  {  }    } ]]

		local r, lab, errpos = lpegParser:match(s)
        print(r, lab, errpos)
        assert.equal(lpegParser:match(s), #s + 1)

    end)


end)

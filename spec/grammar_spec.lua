local Node = require"node"
local Grammar = require"grammar"

describe("Testing #grammar", function()
	test ("Testing auxiliary functions", function()
		assert.same(Grammar.getVarName(Node.var"a"), "a")
		assert.same(Grammar.getVarName"a", "a")
		assert.not_same(Grammar.getVarName"a", "ac")
		assert.not_same(Grammar.getVarName(Node.var"ac"), "a")
	
		assert.True(Grammar.isLexRule"A")
		assert.True(Grammar.isLexRule"B42")
		assert.False(Grammar.isLexRule"b42")
		assert.True(Grammar.isLexRule"XXX")
		assert.False(Grammar.isLexRule"__")
		assert.False(Grammar.isLexRule"42")
	
		-- the prefix "__Err" indicates an error rule
		assert.True(Grammar.isErrRule"Big__Err")
		assert.True(Grammar.isErrRule"__ErrBig")
		assert.False(Grammar.isErrRule"__errBig")
		assert.True(Grammar.isErrRule"__Err")
		assert.False(Grammar.isErrRule"Big_Err")
	end)


	test("Creating a simple grammar", function()
		local g = Grammar.new()
		g:addRule("s", Node.char"a")
		
		local ruleMap = {
			s = Node.char"a"
		}
		assert.same(g:getRules(), ruleMap)
		assert.same(g:getVars(), { "s" })
		      
		assert.same(g:getRHS"s", Node.char"a")
		
		assert.same(g:getStartRule(), "s")
		
		g:setStartRule("s")
		assert.same("s", g:getStartRule())
	end)
	
	
	test("Creating a grammar with several rules", function()
		local g = Grammar.new()
		local rhs = Node.con(Node.var"a", Node.var"b")
		g:addRule("s", rhs)
		g:addRule("a", Node.var"c")
		g:addRule("b", Node.char"a")
		g:addRule("c", Node.empty())
		
		local ruleMap = {
			s = rhs,
			a = Node.var"c",
			b = Node.char"a",
			c = Node.empty()
		}
		
		assert.same(g:getRules(), ruleMap)
		assert.same(g:getVars(), { "s", "a", "b", "c" })

		assert.same(g:getRHS"s", rhs)
		assert.same(g:getRHS"a", Node.var"c")
		assert.same(g:getRHS"b", Node.char"a")
		assert.same(g:getRHS"c", Node.empty())
		
		assert.same(g:getStartRule(), "s")
		
		g:setStartRule("b")
		assert.same("b", g:getStartRule())		
		         
	end)
	
	test("Handling lexer rules", function()	
		local g = Grammar.new()
		g:addRule("s", Node.var"A")
		g:addRule("A", Node.var"c")
		g:addRule("B", Node.char"a")
		g:addRule("c", Node.empty())
		g:addRule("D", Node.empty())
		
		assert.same(g:getTokens(), { A = 1, B = true, D = true })
		
		g:removeToken("B")
		assert.same(g:getTokens(), { A = true, D = true })
		
		g:removeToken("D")
		assert.same(g:getTokens(), {  A = true })
		
		g:removeToken("B")
		assert.same(g:getTokens(), {  A = true })
		
		g:removeToken("A")
		assert.same(g:getTokens(), { })
		
	end)
end)


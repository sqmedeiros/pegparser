local Node = require"node"
local Grammar = require"grammar"
local Pretty = require"pretty"

describe("Testing #pretty", function()
	
	test("Printing expressions", function()
        local pretty = Pretty.new()
        local exp
    
		-- Empty
        exp = Node.empty()
		assert.same("''", pretty:printp(exp))
		
		-- Any
        exp = Node.any()
		assert.same(".", pretty:printp(exp))
		
		-- Char
		exp = Node.char("'foo'")
		assert.same("'foo'", pretty:printp(exp))
		
        exp = Node.char('"foo"')
		assert.same('"foo"', pretty:printp(exp))
        
		-- Class/Set of Characteres
		exp = Node.set{"a-e", "0-9", 42}
		assert.same('[a-e0-942]', pretty:printp(exp))
		
    
		-- Var
		exp = Node.var("foo")
        assert.same('foo', pretty:printp(exp))
		
		-- And predicate
        local nodeAnd = Node.andd(Node.var"foo")
		exp = nodeAnd
        assert.same('&foo', pretty:printp(exp))
		
		-- Not predicate
		exp = Node.nott(Node.char"'foo'")
        assert.same("!'foo'", pretty:printp(exp))
		
		-- Concatetation
		local nodeCon = Node.con{Node.char"'foo'", Node.var"foo"}
        exp = nodeCon
		assert.same("'foo' foo", pretty:printp(exp))
		
		-- Choice
		local exp = Node.choice{nodeCon, nodeAnd}
		assert.same("'foo' foo  /  &foo", pretty:printp(exp))
		
		-- Optional: p?
		local nodeOpt = Node.opt(Node.var"foo")
		exp = nodeOpt
        assert.same("foo?", pretty:printp(exp))
		
		-- Zero or more: p*
		local nodeStar = Node.star(Node.char"'foo'")
        exp = nodeStar
		assert.same("'foo'*", pretty:printp(exp))
		
		-- One or more: p+
		local nodePlus = Node.plus(Node.var"foo")
        exp = nodePlus
        assert.same("foo+", pretty:printp(exp))
		
		-- Throw
		local nodeThrow = Node.throw"lua"
		exp = nodeThrow
		assert.same("%{lua}", pretty:printp(exp))
	end)
	
    --[==[
	test("Testing if an expression (without non-terminals) matches the empty string", function()
		local nodeEmpty = Node.empty()
		assert.True(nodeEmpty:matchEmpty())
		
		local nodeAny = Node.any()
		assert.False(nodeAny:matchEmpty())
		
		local nodeChar = Node.char("bola")
		assert.False(nodeChar:matchEmpty())

		local nodeSet = Node.set{"0-9"}
		assert.False(nodeSet:matchEmpty())
		
		local nodeAnd = Node.andd(nodeChar)
		assert.True(nodeAnd:matchEmpty())
		
		local nodeNot = Node.nott(nodeChar)
		assert.True(nodeNot:matchEmpty())
		
		local nodeCon = Node.con{nodeChar, nodeEmpty}
		assert.False(nodeCon:matchEmpty())
		
		nodeCon = Node.con{nodeEmpty, nodeChar}
		assert.False(nodeCon:matchEmpty())
		
		nodeCon = Node.con{nodeChar, nodeChar}
		assert.False(nodeCon:matchEmpty())
		
		nodeCon = Node.con{nodeNot, nodeAnd}
		assert.True(nodeCon:matchEmpty())
		
		local nodeChoice = Node.choice{nodeChar, nodeEmpty}
		assert.True(nodeChoice:matchEmpty())
		
		nodeChoice = Node.choice{nodeEmpty, nodeChar}
		assert.True(nodeChoice:matchEmpty())
		
		nodeChoice = Node.choice{nodeChar, nodeChar}
		assert.False(nodeChoice:matchEmpty())
		
		nodeChoice = Node.choice{nodeNot, nodeAnd}
		assert.True(nodeChoice:matchEmpty())
		
		local nodeStar = Node.star(nodeChar)
		assert.True(nodeStar:matchEmpty())
		
		local nodePlus = Node.plus(nodeChar)
		assert.False(nodePlus:matchEmpty())
		
		local nodeOpt = Node.opt(nodeChar)
		assert.True(nodeOpt:matchEmpty())
		
		local nodeThrow = Node.throw("foo")
		assert.True(nodeThrow:matchEmpty())
	end)
	
	test("Testing if a non-terminal matches the empty string", function()
		local g = Grammar.new()
		local rhs = Node.con{Node.var"a", Node.var"b"}
		g:addRule("s", rhs)
		g:addRule("a", Node.var"c")
		g:addRule("b", Node.char"a")
		g:addRule("c", Node.empty())
		
		assert.False(Node.var"s":matchEmpty(g))
		assert.True(Node.var"a":matchEmpty(g))
		assert.False(Node.var"b":matchEmpty(g))
		assert.True(Node.var"c":matchEmpty(g))
		
	end)
    ]==]
end)

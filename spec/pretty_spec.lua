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
		
        --[==[
		-- "a" A / B "B"
		local con1 = { tag = "con", v = { { tag = "char", v = "a" }, { tag = "var", v = "A" } } }
		local con2 = { tag = "con", v = { { tag = "var", v = "B" }, { tag = "char", v = "B" } } }  
		local choice = { tag = "choice", v = { con1, con2 } }  
		assert.same(Node.choice{Node.con{Node.char"a", Node.var"A"}, Node.con{Node.var"B", Node.char"B"}}, choice)
		
		-- Optional: p?
		local nodeOpt = { tag = "opt", v = nodeVar }
		assert.same(Node.opt(Node.var"foo"), nodeOpt)
		assert.same(Node.new("opt", Node.new("var", "foo")), nodeOpt)
		
		-- Zero or more: p*
		local nodeStar = { tag = "star", v = nodeChar }
		assert.same(Node.star(Node.char"'foo'"), nodeStar)
		assert.same(Node.new("star", Node.new("char", "'foo'")), nodeStar)
		
		-- One or more: p*
		local nodePlus = { tag = "plus", v = nodeVar }
		assert.same(Node.plus(Node.var"foo"), nodePlus)
		assert.same(Node.new("plus", Node.new("var", "foo")), nodePlus)
		
		-- Throw
		local nodeThrow = { tag = "throw", v = "lua" }
		assert.same(Node.throw"lua", nodeThrow)
		assert.same(Node.new("throw", "lua"), nodeThrow)
		
		-- Def
		local nodeDef = { tag = "def", v = "lua" }
		assert.same(Node.def"lua", nodeDef)
		assert.same(Node.new("def", "lua"), nodeDef)
		
		-- Captures
		local nodeConstCap = { tag = "constCap", v = nodeChar }
		assert.same(Node.constCap(nodeChar), nodeConstCap)
		assert.same(Node.new("constCap", nodeChar), nodeConstCap)
		
		local nodePosCap = { tag = "posCap" }
		assert.same(Node.posCap(), nodePosCap)
		assert.same(Node.new("posCap"), nodePosCap)

		local nodeSimpCap = { tag = "simpCap", v = nodeChar }
		assert.same(Node.simpCap(nodeChar), nodeSimpCap)
		assert.same(Node.new("simpCap", nodeChar), nodeSimpCap)

		local nodeTabCap = { tag = "tabCap", v = nodeChar }
		assert.same(Node.tabCap(nodeChar), nodeTabCap)
		assert.same(Node.new("tabCap", nodeChar), nodeTabCap)

		local nodeAnonCap = { tag = "anonCap", v = nodeChar }
		assert.same(Node.anonCap(nodeChar), nodeAnonCap)
		assert.same(Node.new("anonCap", nodeChar), nodeAnonCap)

		local nodeNamedCap = { tag = "namedCap", v = { "name", nodeChar } }
		assert.same(Node.namedCap("name", nodeChar), nodeNamedCap)
		assert.same(Node.new("namedCap", {"name", nodeChar}), nodeNamedCap)

		local nodeDiscardCap = { tag = "funCap", v = nodeChar }
		assert.same(Node.discardCap(nodeChar), nodeDiscardCap)
		assert.same(Node.new("funCap", nodeChar), nodeDiscardCap)
        
        ]==]
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

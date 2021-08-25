local node = require"node"

describe("Testing #node", function()
	
	test("Creating nodes", function()
		-- Empty
		local nodeEmpty = { tag = "empty" }
		assert.same(node.newEmpty(), nodeEmpty)
		assert.same(node.new"empty", nodeEmpty)
		
		-- Any
		local nodeAny = { tag = "any" }
		assert.same(node.newAny(), nodeAny)
		assert.same(node.new"any", nodeAny)
		
		-- Char
		local nodeChar = { tag = "char", p = "'foo'" }
		assert.same(node.newChar"'foo'", nodeChar)
		assert.same(node.new("char", "'foo'"), nodeChar)
		
		-- Class/Set of Characteres
		local nodeSet =  { tag = "set", p = { "a-e", "0-9", 42 } } 
		assert.same(node.newSet{"a-e", "0-9", 42}, nodeSet)
		assert.same(node.new("set", {"a-e", "0-9", 42}), nodeSet)
		
		-- Var
		local nodeVar = { tag = "var", p = "foo" }
		assert.same(node.newVar("foo"), nodeVar)
		assert.same(node.new("var", "foo"), nodeVar)
		
		-- And predicate
		local nodeAnd = { tag = "and", p = nodeVar }
		assert.same(node.newAnd(node.newVar"foo"), nodeAnd)
		assert.same(node.new("and", node.new("var", "foo")), nodeAnd)
		
		-- Not predicate
		local nodeNot = { tag = "not", p = nodeChar }
		assert.same(node.newNot(node.newChar"'foo'"), nodeNot)
		assert.same(node.new("not", node.new("char", "'foo'")), nodeNot)
		
		-- Concatetation
		local nodeCon = { tag = "con", p = { nodeChar, nodeVar } }
		local char = node.newChar
		local var = node.newVar
		assert.same(node.newCon(char"'foo'", var"foo"), nodeCon)
		assert.same(node.new("con", { char"'foo'", var"foo"} ), nodeCon)
		
		-- Choice
		local nodeChoice = { tag = "choice", p = { nodeSet, nodeAnd } }
		assert.same(node.newChoice(nodeSet, nodeAnd), nodeChoice)
		assert.same(node.new("choice", { nodeSet, nodeAnd } ), nodeChoice)
		
		-- "a" A / B "B"
		local con1 = { tag = "con", p = { { tag = "char", p = "a" }, { tag = "var", p = "A" } } }
		local con2 = { tag = "con", p = { { tag = "var", p = "B" }, { tag = "char", p = "B" } } }  
		local choice = { tag = "choice", p = { con1, con2 } }  
		assert.same(node.newChoice(node.newCon(char"a", var"A"), node.newCon(var"B", char"B")), choice)
		
		-- Optional: p?
		local nodeOpt = { tag = "opt", p = nodeVar }
		assert.same(node.newOpt(node.newVar"foo"), nodeOpt)
		assert.same(node.new("opt", node.new("var", "foo")), nodeOpt)
		
		-- Zero or more: p*
		local nodeStar = { tag = "star", p = nodeChar }
		assert.same(node.newStar(node.newChar"'foo'"), nodeStar)
		assert.same(node.new("star", node.new("char", "'foo'")), nodeStar)
		
		-- One or more: p*
		local nodePlus = { tag = "plus", p = nodeVar }
		assert.same(node.newPlus(node.newVar"foo"), nodePlus)
		assert.same(node.new("plus", node.new("var", "foo")), nodePlus)
		
		-- Throw
		local nodeThrow = { tag = "throw", p = "lua" }
		assert.same(node.newThrow"lua", nodeThrow)
		assert.same(node.new("throw", "lua"), nodeThrow)
		
		-- Def
		local nodeDef = { tag = "def", p = "lua" }
		assert.same(node.newDef"lua", nodeDef)
		assert.same(node.new("def", "lua"), nodeDef)
		
		-- Captures
		local nodeConstCap = { tag = "constCap", p = nodeChar }
		assert.same(node.newConstCap(nodeChar), nodeConstCap)
		assert.same(node.new("constCap", nodeChar), nodeConstCap)
		
		local nodePosCap = { tag = "posCap" }
		assert.same(node.newPosCap(), nodePosCap)
		assert.same(node.new("posCap"), nodePosCap)

		local nodeSimpCap = { tag = "simpCap", p = nodeChar }
		assert.same(node.newSimpCap(nodeChar), nodeSimpCap)
		assert.same(node.new("simpCap", nodeChar), nodeSimpCap)

		local nodeTabCap = { tag = "tabCap", p = nodeChar }
		assert.same(node.newTabCap(nodeChar), nodeTabCap)
		assert.same(node.new("tabCap", nodeChar), nodeTabCap)

		local nodeAnonCap = { tag = "anonCap", p = nodeChar }
		assert.same(node.newAnonCap(nodeChar), nodeAnonCap)
		assert.same(node.new("anonCap", nodeChar), nodeAnonCap)

		local nodeNameCap = { tag = "nameCap", p = nodeChar }
		assert.same(node.newNameCap(nodeChar), nodeNameCap)
		assert.same(node.new("nameCap", nodeChar), nodeNameCap)

		local nodeDiscardCap = { tag = "funCap", p = nodeChar }
		assert.same(node.newDiscardCap(nodeChar), nodeDiscardCap)
		assert.same(node.new("funCap", nodeChar), nodeDiscardCap)
		
	end)
	
end)

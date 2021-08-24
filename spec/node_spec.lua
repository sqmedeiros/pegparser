local node = require"node"

describe("Testing #node", function()
	
	test("Creating the non-recursive nodes", function()
		-- Empty
		local nodeEmpty = { tag = "empty" }
		assert.same(node.newEmpty(), nodeEmpty)
		assert.same(node.new"empty", nodeEmpty)
		
		-- Any
		local nodeAny = { tag = "any" }
		assert.same(node.newAny(), nodeAny)
		assert.same(node.new"any", nodeAny)
		
		-- Char
		local nodeChar = { tag = "char", p = "foo" }
		assert.same(node.newChar"foo", nodeChar)
		assert.same(node.new("char", "foo"), nodeChar)
		
		-- Class/Set of Characteres
		local nodeSet =  { tag = "set", p = { "a-e", "0-9", 42 } } 
		assert.same(node.newSet{"a-e", "0-9", 42}, nodeSet)
		assert.same(node.new("set", {"a-e", "0-9", 42}), nodeSet)
		
		-- Var
		local nodeVar = { tag = "var", p = "foo" }
		assert.same(node.newVar("foo"), nodeVar)
		assert.same(node.new('var', "foo"), nodeVar)
		
	end)
	
end)

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
		
		-- Choice 1
		exp = Node.choice{nodeCon, nodeAnd}
		assert.same("'foo' foo  /  &foo", pretty:printp(exp))
        
        -- Choice with throw
        exp = Node.choice{Node.var"foo", Node.throw"lua"}
		assert.same("foo^lua", pretty:printp(exp))
        
        -- Concatenation of choices 1
        exp = Node.con{Node.choice{Node.char"'a'", Node.any()}, Node.var"b" }
        assert.same("('a'  /  .) b", pretty:printp(exp))
        
        -- Concatenation of choices 2
        exp = Node.con{Node.var"b", Node.choice{Node.char"'a'", Node.any()} }
        assert.same("b ('a'  /  .)", pretty:printp(exp))
        
		-- Optional: p?
		exp = Node.opt(Node.var"foo")
        assert.same("foo?", pretty:printp(exp))
		
		-- Zero or more: p*
		exp = Node.star(Node.char"'foo'")
		assert.same("'foo'*", pretty:printp(exp))
		
		-- One or more: p+
		exp = Node.plus(Node.var"foo")
        assert.same("foo+", pretty:printp(exp))
		
		-- Throw
		exp = Node.throw"lua"
		assert.same("%{lua}", pretty:printp(exp))
	end)
	
    
	test("Printing a grammar", function()
		
		
	end)
end)
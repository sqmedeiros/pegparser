local set = require'set'

describe("Testing #set", function()
	
	test("Creating empty set", function()
		local s1 = set.new()
		assert.same(s1:getAll(), {})
	end)
		
	test("Creating set from a list", function()
		local t = { 10, 20, 30 }
		local s1 = set.new(t)
		assert.same(s1:sort(), t)
	end)
	
	test("Creating set from a table", function()
		local t = { a = 100, b = 20, c = 30 }
		
		-- value 'true' indicates we use the keys from 't' to populate the set
		local s1 = set.new(t, true)
		assert.same(s1:sort(), { "a", "b", "c"} )
		
		local t = { 10, 20, 30 }
		local s1 = set.new(t, true)
		assert.same(s1:sort(), { 1, 2, 3})
	end)
	
	test("Creating empty set and inserting elements", function()
		local s1 = set.new(t)
		
		local t = { "a", "b", "c" }
		for _, v in pairs(t) do
			s1:insert(v)
		end
		
		assert.same(s1:sort(), t)
	end)
	
	test("Testing the value returned by insert", function()
		local s1 = set.new(t)
		
		local t = { 1, 2, 3 }
		for _, v in pairs(t) do
			assert(s1:insert(v) == true)
		end
		
		for _, v in pairs(t) do
			assert(s1:insert(v) == false)
		end
		
		assert.same(s1:sort(), t)
	end)
	
	test("Testing remove", function()
		local t = { 1, 2, 3 }
		local s1 = set.new(t)
		
		for _, v in pairs(t) do
			assert(s1:remove(v) == true)
		end
		
		for _, v in pairs(t) do
			assert(s1:remove(v) == false)
		end
		
		assert.same(s1:sort(), {})
	end)
	
	test("Testing getEle", function()
		local t = { "a", "b", "c" }
		local s1 = set.new(t)

		assert.True(s1:getEle("a"))
		assert.True(s1:getEle("b"))
		assert.True(s1:getEle("c"))
		assert.Nil(s1:getEle("d"))
	end)

	test("Testing union/equal", function()
		local t = { 10, 20, 30 }
		local s1 = set.new(t)
		
		local s2 = set.new()
		for _, v in pairs(t) do
			local s3 = set.new( { v } )
			s2 = s2:union(s3)
		end
		
		assert.same(s1:sort(), s2:sort())
		assert.True(s1:equal(s2))
		
		s2 = s2:union(s1)
		assert.same(s1:sort(), s2:sort())
		assert.True(s1:equal(s2))
	end)
	
	test("Testing intersection", function()
		local s1 = set.new{"a", "e", "i", "o", "u"}
		local s2 = set.new{"a", "b", "c", "d", "e", "m", "o" }
		local s3 = s1:inter(s2)
		assert.True(s3:equal(set.new{"a", "e", "o"}))
		assert.True(s3:inter(s3):equal(s3))
		assert.True(s3:inter(set.new()):equal(set.new()))
	end)
	
	test("Testing subset", function()
		local s1 = set.new{"a", "e", "i", "o", "u"}
		local s2 = set.new{"a", "b", "c", "d", "e", "m", "o" }
		local s3 = s1:inter(s2)

		assert.True(s1:subset(s1))
		assert.False(s1:subset(s2))	
		assert.False(s1:subset(s3))

		assert.False(s2:subset(s1))
		assert.True(s2:subset(s2))
		assert.False(s2:subset(s3))

		assert.True(s3:subset(s1))
		assert.True(s3:subset(s2))
		assert.True(s3:subset(s3))
	end)
	
	test("Testing empty", function()
		assert.True(set.new():empty())
		
		local s1 = set.new{1, 2, 3}
		local s2 = set.new{4, 5, 6}
		assert.True(s1:inter(s2):empty())
	end)
	
	
	test("Testing disjoint", function()
		local s1 = set.new{1, 2, 3}
		local s2 = set.new{4, 5, 6}
		local s3 = set.new{2, 6}
		
		assert.False(s1:disjoint(s1))
		assert.True(s1:disjoint(s2))
		assert.False(s1:disjoint(s3))
		
		assert.True(s2:disjoint(s1))
		assert.False(s2:disjoint(s2))
		assert.False(s2:disjoint(s3))
		
		assert.False(s3:disjoint(s1))
		assert.False(s3:disjoint(s2))
		assert.False(s3:disjoint(s3))
	end)
	
	test("Testing diff", function()
		local s1 = set.new{1, 2, 3}
		local s2 = set.new{1, 2}
		local s3 = set.new{4, 5, 6}

		assert.same(s1:diff(s1), set.new{})
		assert.same(s1:diff(s2), set.new{3})
		assert.same(s1:diff(s3), s1)
	
		assert.same(s2:diff(s1), set.new{})
		assert.same(s2:diff(s2), set.new{})
		assert.same(s2:diff(s3), s2)
		
		assert.same(s3:diff(s1), s3)
		assert.same(s3:diff(s2), s3)
		assert.same(s3:diff(s3), set.new{})
	end)

	
	test("Testing getAll", function()
		local t = { 10, 20, 30 }
		local s1 = set.new(t)
		
		assert.True(s1:equal(set.new(s1:getAll(), true)))
	end)
	
	
	test("Testing tostring", function()
		local t = { 10, 20, 30 }
		local s1 = set.new(t)
		
		assert.equal(s1:tostring(), "{ 10, 20, 30 }")
	end)
	

end)

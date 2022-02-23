local UVerySimple = require"uniqueVerySimple"
local Parser = require"parser"
local Set = require"set"

local function sameListMap(list, map)
	local copyMap = {}
	for k, v in pairs(map) do
		copyMap[k] = v
	end

	for i, v in ipairs(list) do
		assert.True(map[v], "Absent key " .. tostring(v))
		copyMap[v] = nil
	end
	
	assert.True(next(copyMap) == nil)
end


describe("Testing #unique", function()
	
	test("Calculating unique tokens", function()
	  --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)

		local tabUnique = unique:uniqueTk()
		
		sameListMap({"'a'", "A", "'c'", "'d'", "'A'"}, tabUnique)
	end)
	
end)
			
describe("Testing #calcUniquePath", function()
	
	test("Calculating unique tokens", function()
	  --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)

		unique:calcUniquePath()
	end)
	
end)
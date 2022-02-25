local UVerySimple = require"uniqueVerySimple"
local Parser = require"parser"
local Set = require"set"
local Pretty = require"pretty"
local Util = require"util"

local pretty = Pretty.new()

local function checkPrint (s)
    local g, msg = Parser.match(s)
    assert.is_not_nil(g)
    local pretty = Pretty.new()
    return Util.sameWithoutSpace(pretty:printg(g), s)
end


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
	
	test("Grammar 1", function()
	  --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)
		unique:calcUniquePath()
        
        local g_unique = [[
			s <- 'a'_unique 'b' / A_unique / b   
			b <- 'b' / 'c'_unique / 'd'_unique / 'A'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
        
        local g_label = [[
			s <- 'a' 'b'_label / A / b   
			b <- 'b' / 'c' / 'd' / 'A'
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
	end)
    

    test("Grammar 2", function()
        --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
                s <- 'a' 'b' / 'c' 'd'
        ]]
        
        local unique = UVerySimple.new(g)
		unique:calcUniquePath()

        local g_unique = [[
            s <- 'a'_unique 'b'_unique / 'c'_unique 'd'_unique
        ]]
        assert.is_true(Util.checkProperty(g, g_unique, "unique"))
		
        local g_label = [[
            s <- 'a' 'b'_label / 'c' 'd'_label
        ]]
        assert.is_true(Util.checkProperty(g, g_label, "label"))
	end)

    
	
end)

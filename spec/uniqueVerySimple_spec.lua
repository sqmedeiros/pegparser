local UVerySimple = require"uniqueVerySimple"
local Parser = require"parser"
local Set = require"set"
local Pretty = require"pretty"
local Util = require"util"

local pretty = Pretty.new()


local function sameWithoutSpace (auto, manual)
    local sAuto = Util.removeSpace(auto)
    local sManual = Util.removeSpace(manual)
    return sAuto == sManual
end

local function checkPrint (s)
    local g, msg = Parser.match(s)
    assert.is_not_nil(g)
    local pretty = Pretty.new()
    return sameWithoutSpace(pretty:printg(g), s)
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
	
	test("Calculating unique tokens", function()
	  --The right-hand side of a lexical rule does not influence unique tokens
		local g = Parser.match[[
			s <- 'a' 'b' / A / b   
			A <- 'a' / 'c'        --lexical rule
			b <- 'b' / 'c' / 'd' / 'A']]
			
		local unique = UVerySimple.new(g)

		unique:calcUniquePath()
        pretty:setProperty("unique")
        local auto = pretty:printg(g)
        local g_prop_unique = [[
			s <- 'a'_unique 'b' / A_unique / b   
			b <- 'b' / 'c'_unique / 'd'_unique / 'A'_unique]]
        
        assert.is_true(sameWithoutSpace(auto, g_prop_unique))
        print"----\n"
        
        pretty:setProperty("label")
        local auto = pretty:printg(g)
        local g_prop_label = [[
			s <- 'a' 'b'_label / A / b   
			b <- 'b' / 'c' / 'd' / 'A']]
        
        assert.is_true(sameWithoutSpace(auto, g_prop_label))
            
        
	end)
	
end)

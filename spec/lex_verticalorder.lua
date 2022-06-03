local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkConversionToPeg (stringG, stringPeg, config)
	local g = Parser.match(stringG)
	assert.is_not_nil(g)
	
	config = config or {}
	
	local c2p = Cfg2Peg.new(g)
	c2p:setUsePrefix(config.prefix)
	c2p:setUseUnique(config.unique)
	c2p:convert(config.idRule, config.reserved)
	
	local peg = c2p.peg
    local pretty = Pretty.new()
    local equal = Util.sameWithoutSpace(pretty:printg(peg, nil, true), stringPeg)
    
    if not equal then
		print("---- Different ----\n")
		print(">>>> Generated PEG <<<<")
		print(pretty:printg(peg, nil, true))
		print("\n**** Expected PEG ****")
		print(stringPeg)
		print("")
    end
    
    assert.is_true(equal)
end


describe("Transforming a CFG into an equivalent PEG\n", function()

    local pretty = Pretty.new()

	test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a'Y
            Y   <- 'y'
            
		]]

        local peg = [[
			a   <- 'a' / 'y'
            b   <- 'a' / 'a'Y
            Y   <- 'y'
        ]]

		checkConversionToPeg(g, peg, {reserved = true})
	end)

  
end)

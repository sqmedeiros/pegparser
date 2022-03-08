local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'
local Pretty = require'pretty'
local Util = require'util'


local function checkGPrint (g, s, withLex)
    assert.is_not_nil(g)
    assert.is_not_nil(s)
    local pretty = Pretty.new()
    return Util.sameWithoutSpace(pretty:printg(g, nil, withLex), s)
end


describe("Transforming a CFG into an equivalent PEG\n", function()


	test("Identifying the rule that matches an identifier", function()
		local g = Parser.match[[
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('Id')

        local peg = [[
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)

    test([[Changing the order of alternatives, based on unique tokens,
           when the alternatives' FIRST set is not disjoint]], function()
		local g = Parser.match[[
			s   <-  a / 'a' 'b' / 'a' 'c'
			a   <- 'x' / 'a' / 'y' / 'y''z'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		c2p:convert('Id')

        local peg = [[
            s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'a' / 'y''z' / 'y'
            b   <- 'a' / 'a''y'
			Id  <- [a-z] [a-z0-9]*
        ]] ..
        Cfg2Peg.IdBegin .. [[ <- [a-z] ]] ..
        Cfg2Peg.IdRest  .. [[ <- [a-z0-9]* ]]

		assert.is_true(checkGPrint(c2p.peg, peg, true))
	end)


    
end)

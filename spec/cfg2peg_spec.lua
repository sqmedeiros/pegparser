local Cfg2Peg = require'cfg2peg'
local Parser = require'parser'

describe("Testing conflict in a choice", function()


	test("Grammar with choice", function()
		local g = Parser.match[[
			s   <- 'a' 'b' / 'a' 'c' / a
			a   <- 'x' / 'y' / 'a'
			id  <- [a-z] [a-z-0-9]*
		]]

		local c2p = Cfg2Peg.new(g)
		
		c2p:convert('id')

		--assert.same(objFst.FOLLOW, setFlw)
	end)
end)

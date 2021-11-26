local reorder = require"reorder"
local parser = require"parser"
local cfg2peg = require"cfg2peg"

describe("Testing #reorder", function()
	
	test("Grammar with simple disjoint and non-disjoint choices", function()
		local g = parser.match[[
			s   <- 'a' / 'b'
			a   <- 'a' / 'a' / 'c'
			B   <- 'a' / 'a']]
					
		local choiceS = cfg2peg.getChoiceAlternatives(g.prules['s'])
		local reo = reorder.new(g, choiceS)
		reo:sort()

		local choiceA = cfg2peg.getChoiceAlternatives(g.prules['a'])
		local reo = reorder.new(g, choiceA)
		reo:sort()
		
		local choiceB = cfg2peg.getChoiceAlternatives(g.prules['B'])
		local reo = reorder.new(g, choiceB)
		reo:sort()

	end)
end)

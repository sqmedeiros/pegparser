local Parser = require"parser"
local Coder = require"coder"
local Pretty = require'pretty'

describe("Testing #coder", function()
		test("Grammar that uses a predefined rule (EOF)", function()
		local g = Parser.match[[
			s <- 'a' EOF
		]]

		--assert(g)
		--local lpegParser = Coder.makeg(g)
		--assert.equal(lpegParser:match("a"), 2)
	end)
end)

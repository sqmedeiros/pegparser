local Parser = require"parser"
local Coder = require"coder"

describe("Testing #coder", function()

	test("Simple grammar", function()
		local g = Parser.match[[
			s <- "a"
		]]
		
		assert(g)
		
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("a"), 2)
		assert.equal(lpegParser:match("x"), nil)
		--assert.equal(lpegParser:match(" a"), 3)
		--assert.equal(lpegParser:match("  x"), nil)
		assert.equal(lpegParser:match("a  "), 4)
		--assert.equal(lpegParser:match("x  "), nil)
	end)
end)	

--[==[
  test("Grammar with syntax errors: checking the error label", function()

-- testing coder
local g = [[
  S <- "0" B / "1" A / ""   -- balanced strings
  A <- "0" S / "1" A A      -- one more 0
  B <- "1" S / "0" B B      -- one more 1
]]

local p = coder.makeg(m.match(g))
assert(p:match("00011011") == 9)

local g = [[
  S <- ("0" B / "1" A)*
  A <- "0" / "1" A A
  B <- "1" / "0" B B
]]

local tree, r = m.match(g)
print(pretty.printg(tree, r))
local p = coder.makeg(m.match(g))

assert(p:match("00011011") == 9)
assert(p:match("000110110") == 9)
assert(p:match("011110110") == 3)
print(p:match("000110010"))
assert(p:match("000110010") == 1)
]==]

local Parser = require"parser"
local Coder = require"coder"

describe("Testing #coder", function()

	test("Simple grammar", function()
		local g = Parser.match[[
			s <- 'a'
		]]
		
		assert(g)
		
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("a"), 2)
		assert.equal(lpegParser:match("x"), nil)
		assert.equal(lpegParser:match(" a"), 3)
		assert.equal(lpegParser:match("  x"), nil)
		assert.equal(lpegParser:match("a  "), 4)
		assert.equal(lpegParser:match("a  b"), 4)
		assert.equal(lpegParser:match("x  "), nil)
	end)

	test("Grammar that uses a predefined rule (EOF)", function()
		local g = Parser.match[[
			s <- 'a' EOF
		]]

		assert(g)
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("a"), 2)
		assert.equal(lpegParser:match("x"), nil)
		assert.equal(lpegParser:match(" a"), 3)
		assert.equal(lpegParser:match("  x"), nil)
		assert.equal(lpegParser:match("a  "), 4)
		assert.equal(lpegParser:match("a  b"), nil)
		assert.equal(lpegParser:match("x  "), nil)
	end)

	test("Grammar with lexical and syntactical rules", function()
		local g = Parser.match[[
			s <- "a" B
			B <- "b" "c"
		]]
		
		assert(g)
		
		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match(" a bc"), 6)
		assert.equal(lpegParser:match(" a b c"), nil)
		assert.equal(lpegParser:match("abc"), 4)
		assert.equal(lpegParser:match("a bc"), 5)
		assert.equal(lpegParser:match(" a  bc  "), 9)
	end)


	test("Grammar with balanced 0's and 1's)", function()

		local g = Parser.match[[
  			S <- "0" B / "1" A / ""   -- balanced strings
  			A <- "0" S / "1" A A      -- one more 0
  			B <- "1" S / "0" B B      -- one more 1
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("00011011"), 9)
		assert.equal(lpegParser:match("0 0011011"), 1)
		assert.equal(lpegParser:match(" 00011011"), 1)
		assert.equal(lpegParser:match("1000110101"), 11)
		assert.equal(lpegParser:match("10"), 3)
		assert.equal(lpegParser:match("011"), 3)
	end)

	test("Another grammar with balanced 0's and 1's", function()
		
		local g = Parser.match[[
  			S <- ("0" B / "1" A)*
  			A <- "0" / "1" A A
  			B <- "1" / "0" B B
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("00011011"),  9)
		assert.equal(lpegParser:match("000110110"), 9)
		assert.equal(lpegParser:match("011110110"), 3)
		assert.equal(lpegParser:match("000110010"), 1)
	end)

	test("Grammar with set and repetition expressions", function()
		
		local g = Parser.match[[
  			s <- 'a'? 'b'+ a
  			a <- [f-i]
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match("abf"),  4)
		assert.equal(lpegParser:match("bg"), 3)
		assert.equal(lpegParser:match("f"), nil)
		assert.equal(lpegParser:match("abbg"), 5)
		assert.equal(lpegParser:match("abbj"), nil)
	end)


	test("Grammar with predicates", function()
		
		local g = Parser.match[[
  			s <- !'a' &[a-z] [a-e]
		]]

		assert(g)

		local lpegParser = Coder.makeg(g)
		assert.equal(lpegParser:match(""),  nil)
		assert.equal(lpegParser:match("a"), nil)
		assert.equal(lpegParser:match("c"), 2)
		assert.equal(lpegParser:match("C"), nil)
		assert.equal(lpegParser:match("x"), nil)
	end)

end)

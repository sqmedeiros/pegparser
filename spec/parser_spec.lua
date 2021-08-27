local Parser = require'parser'
local ErrMsg = require'syntax_errors'


local function assertlab (g, lab)
	local r, msg, pos = Parser.match(g)
	local errMsg = ErrMsg[lab]
	assert.is_not_nil(errMsg, "InvalidLabel '" .. lab .. "'")
	assert.is_nil(r)
	assert.True(string.find(msg, errMsg, 1, true), "Expected label '" .. lab .. "'")
end


describe("Testing #parser", function()
	
	test("Grammar with syntax errors: checking the error label", function()
		
		assertlab([[a <- 'b'  3 ]], 'Extra')

		assertlab([[]], 'Rule')

		assertlab([[a <- ]], 'ExpRule')

		assertlab([[a ]], 'Arrow')

		assertlab([[a <- 'b' / 3]], 'SeqExp')

		assertlab([[a <- 'b'& ]], 'AndPred')

		assertlab([[a <- ! ]], 'NotPred')

		assertlab([[a <- () ]], 'ExpPri')

		assertlab([[a <- ( 'b' ]], 'RParPri')

		assertlab([[a <- ( 'b" ]], 'SingQuote')

		assertlab([[a <- ( "b' ]], 'DoubQuote')

		assertlab([[a <- []], 'EmptyClass')

		assertlab([[a <- [a-z]], 'RBraClass')

		assertlab([[a <- %{ } ]], 'NameThrow')

		assertlab([[a <- %{ ops ]], 'RCurThrow')
	end)

	test("Grammar with undefined nonterminal", function()
	
		local r, msg = pcall(Parser.match, [[a <- 'a' b]])

		assert(not r and string.find(msg, "'b' was not defined", 1, true))
	end)

--[==[
print(pretty.printg(m.match[[a <- 'b'*]]))

local r, l, pos =  m.match[[a <- 'b' / 'c'  d <- 'a'^bola]]
print(pretty.printg(r, l))

local r, l, pos =  m.match[[a <- 'bc' 'd' 'c' [a-zA-Z0-9_] ]]
print(pretty.printg(r, l))


local r, l, pos = m.match([[a <- 'b' ('c' / 'd') / 'e']])
print(pretty.printg(r, l))

local r, l, pos = m.match([[new <- 'x' ('c' / 'd') / 'e' %{Nada}]])
print(pretty.printg(r, l))

local r, l, pos = m.match([[
Start <- X ('c' / 'd') / 'e' %{Nada}
X     <- &'a' !'b' {.} {} {| [a-z]* |} Z
Z     <- 'a'? 'b'* 'c'+]])
print(pretty.printg(r, l))
]==]

end)

local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'
local coder = require 'coder'
local first = require 'first'


local function assertlab (g, lab)
	local r, msg, pos = m.match(g)
	local errMsg = errinfo[lab]
	assert(errMsg, "InvalidLabel '" .. lab .. "'")
	if r then pretty.printg(r, msg) end
	assert(string.find(msg, errMsg, 1, true), "Expected label '" .. lab .. "'")
end

--testing labels
io.write("Testing labels... ")

assertlab([[a <- 'b'  3 ]], 'Extra')

assertlab([[]], 'Rule')

assertlab([[a <- ]], 'ExpRule')

assertlab([[a ]], 'Arrow')

assertlab([[a <- 'b' / 3]], 'SeqExp')

assertlab([[a <- 'b'& ]], 'AndPred')

assertlab([[a <- ! ]], 'NotPred')

assertlab([[a <- () ]], 'ExpPri')

assertlab([[a <- ( 'b' ]], 'RParPri')

assertlab([[hei <- {| |} ]], 'ExpTabCap')

assertlab([[hei <- {: :} ]], 'ExpAnonCap')

assertlab([[hei <- {| 'b'* } ]], 'RCurTabCap')

assertlab([[hei <- {: 'b'* } ]], 'RCurNameCap')

assertlab([[hei <- { 'b']], 'RCurCap')

assertlab([[hei <- { ]], 'RCurCap')

assertlab([[a <- ( 'b" ]], 'SingQuote')

assertlab([[a <- ( "b' ]], 'DoubQuote')

assertlab([[a <- []], 'EmptyClass')

assertlab([[a <- [a-z]], 'RBraClass')

assertlab([[a <- %{ } ]], 'NameThrow')

assertlab([[a <- %{ ops ]], 'RCurThrow')

print("Ok")


--testing undefined nonterminal
local r, msg = pcall(m.match, [[a <- 'a' b]])

print(r, msg)
assert(not r and string.find(msg, "'b' was not defined", 1, true))


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





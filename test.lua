local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'

local function assertlab (g, lab)
	local r, msg, pos = m.match(g)
	local errMsg = errinfo[lab]
	assert(errMsg, "InvalidLabel '" .. lab .. "'")
	assert(string.find(msg, errMsg, 1, true), "Expected label '" .. lab .. "'")
end

assertlab([[a <- 'b' 3]], 'Extra')

assertlab([[]], 'Rule')

assertlab([[a <- ]], 'ExpRule')

assertlab([[a ]], 'Arrow')

assertlab([[a <- 'b' / 3]], 'SeqExp')

assertlab([[a <- 'b'& ]], 'AndPred')

assertlab([[a <- ! ]], 'NotPred')

assertlab([[a <- () ]], 'ExpPri')

assertlab([[a <- ( 'b' ]], 'RParPri')

assertlab([[hei <- {| |} ]], 'ExpTabCap')

assertlab([[hei <- {| 'b'* } ]], 'RCurTabCap')

assertlab([[hei <- { 'b']], 'RCurCap')

assertlab([[hei <- { ]], 'RCurCap')

assertlab([[a <- ( 'b" ]], 'SingQuote')

assertlab([[a <- ( "b' ]], 'DoubQuote')

assertlab([[a <- [a-z]], 'RBraClass')

assertlab([[a <- %{ } ]], 'NameThrow')

assertlab([[a <- %{ ops ]], 'RCurThrow')


print(pretty.printg(m.match[[a <- 'b']]))

local r, l, pos =  m.match[[a <- 'b' / 'c'  d <- 'a'^bola]]
print(pretty.printg(r))

local r, l, pos =  m.match[[a <- 'bc' 'd' 'c' [a-zA-Z0-9_] ]]
print(pretty.printg(r))


local r, l, pos = m.match([[a <- 'b' ('c' / 'd') / 'e']])
print(pretty.printg(r))

local r, l, pos = m.match([[new <- 'x' ('c' / 'd') / 'e' %{Nada}]])
print(pretty.printg(r))

local r, l, pos = m.match([[
Start <- X ('c' / 'd') / 'e' %{Nada}
X     <- &'a' !'b' {.} {} {| [a-z]* |} Z
Z     <- 'a'? 'b'* 'c'+]])
print(pretty.printg(r))


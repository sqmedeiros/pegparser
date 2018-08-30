local m = require 'init'
local errinfo = require 'syntax_errors'
local pretty = require 'pretty'

local function assertlab (g, lab)
	local r, msg, pos = m.match(g)
	assert(string.find(msg, errinfo[lab], 1, true))
end

assertlab([[a <- 'b' 3]], 'Extra')

assertlab([[]], 'Rule')

assertlab([[a <- ]], 'ExpRule')

assertlab([[a ]], 'Arrow')

assertlab([[a <- 'b' / 3]], 'SeqExp')

assertlab([[a <- 'b'& ]], 'AndPred')

assertlab([[a <- ! ]], 'NotPred')


local r, l, pos =  m.match[[a <- 'b' / 'c'  d <- 'a'^bola]]
print(r, l, pos)

for k, v in pairs(r) do
	print("ei", k, v)
end

local r, l, pos =  m.match[[a <- 'bc' 'd' 'c' [a-zA-Z0-9_] ]]
print("vamos", r, l, pos)

for k, v in pairs(r) do
	print("ei", k, v)
end

local t = m.match([[a <- 'b' ('c' / 'd') / 'e']]



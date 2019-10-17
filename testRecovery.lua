local m = require'pegparser.parser'
local errinfo = require'pegparser.syntax_errors'
local pretty = require'pegparser.pretty'
local coder = require'pegparser.coder'
local recovery = require'pegparser.recovery'


local function assertlab (g, lab)
	local r, msg, pos = m.match(g)
	local errMsg = errinfo[lab]
	assert(errMsg, "InvalidLabel '" .. lab .. "'")
	if r then pretty.printg(r, msg) end
	assert(string.find(msg, errMsg, 1, true), "Expected label '" .. lab .. "'")
end


local r, l, pos =  m.match[[a <- 'b' / 'c'  'd']]
print(pretty.printg(r, l)) 

local glab = recovery.addlab(r, l)
print(pretty.printg(glab, l))



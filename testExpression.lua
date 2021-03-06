local m = require'pegparser.parser'
local recovery = require'pegparser.recovery'
local pretty = require'pegparser.pretty'
local coder = require'pegparser.coder'

local function assertErr (p, s, lab)
	local r, l, pos = p:match(s)
	assert(not r, "Did not fail: r = " .. tostring(r))
	if lab then
		assert(l == lab, "Expected label '" .. tostring(lab) .. "' but got " .. tostring(l))
	end
end

local function assertOk(p, s)
	local r, l, pos = p:match(s)
	assert(r, 'Failed: label = ' .. tostring(l) .. ', pos = ' .. tostring(pos))
	assert(r == #s + 1, "Matched until " .. r)
end


local tree, rules =  m.match[[
S           <- (Expression !'=' / Assignment)*  !.
Assignment  <- Name '=' Expression
Expression  <- Term ('+' Term)*
Term        <- Factor ('*' Factor)*
Factor      <- '(' Expression ')'  /  Name  /  Number
Name        <- [a-z]+
Number      <- [1-9][0-9]*]]

print(pretty.printg(tree, rules), '\n')

local treerec, rulesrec = recovery.addlab(tree, rules, false, true)
print(pretty.printg(treerec, rulesrec), '\n')


local tree, rules =  m.match[[
S           <- (Assignment / Expression)*  !.
Assignment  <- Name '=' Expression
Expression  <- Term ('+' Term)*
Term        <- Factor ('*' Factor)*
Factor      <- '(' Expression ')'  /  Name  /  Number
Name        <- [a-z]+
Number      <- [1-9][0-9]*]]

print(pretty.printg(tree, rules), '\n')

local treerec, rulesrec = recovery.addlab(tree, rules, false, true)
print(pretty.printg(treerec, rulesrec), '\n')


local p = coder.makeg(treerec, rulesrec)

-- Valid programs
assertOk(p, "af=2")
assertOk(p, "test = (42)")
assertOk(p, "ok")
assertOk(p, "1 + 22 + (42*abc)")
assertOk(p, "a = 2\nb = 43")

-- Invalid programs
assertErr(p, "(3")
assertErr(p, "(3", "Err_006")




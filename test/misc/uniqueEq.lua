local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

-- should annotate both 'b' and 'c', 'f' and 'g'
local s = [[
	exp             <- SKIP ('A' 'b' 'c' 'd' 'f' / 'A' 'b' 'c' 'e' 'g')
]]


print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
print(pretty.printg(gupath, true, 'unique'), '\n')
print(pretty.printg(gupath, true, 'uniqueEq'), '\n')
print("End UPath\n")


g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

--util.testYes(dir .. '/test/yes/', 'titan', p)

--util.testNo(dir .. '/test/no/', 'titan', p)


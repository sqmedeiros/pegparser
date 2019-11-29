local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

-- should annotate 'C', but not 'A' and 'B'
local s = [[
	exp             <- SKIP ('A' ('if' 'A' / 'if' 'B' / 'if' 'C' / 'while' 'G') / 'A' fator / 'J' id)
  fator           <- id 'if' 'bola' 'H' / id 'bola'
	id              <- 'id'
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


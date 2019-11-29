local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
  inicio         <-  SKIP ('A' regra1  'x' /  'A' regra2  /  'A' 'id' / regra3)* !.
  regra1         <-  'a' 'b' 'y' / 'a' 'c' / 'd' 'a'
  regra2         <-  'G' 'H'
	regra3         <- regra1
]]


print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
print(pretty.printg(gupath, true, 'unique'), '\n')
print("End UPath\n")

g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

--util.testYes(dir .. '/test/yes/', 'titan', p)

--util.testNo(dir .. '/test/no/', 'titan', p)


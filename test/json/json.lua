local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require'pegparser.util'

local s = [[
	json  <-  value EOF
  obj   <- '{' pair (',' pair)* '}'  
         / '{' '}'
  pair  <- STRING ':' value
  arr   <- '[' value (',' value)* ']'
         / '[' ']'
  value <-
     STRING
   / NUMBER
   / obj
   / arr
   / 'true'
   / 'false'
   / 'null'

  STRING         <-  '"' (!'"' .)* '"'  /  "'" (!"'" .)* "'"
  NUMBER          <- [0-9]+ ('.'!'.' [0-9]*)?
  EOF            <- !.
 ]]


print("Unique Path (UPath)")
g = m.match(s)
local gupath = recovery.putlabels(g, 'upath', true)
print(pretty.printg(gupath, true), '\n')
--print(pretty.printg(gupath, true, 'unique'), '\n')
--print(pretty.printg(gupath, true, 'uniqueEq'), '\n')
pretty.printToFile(g, nil, 'json', 'rec')

print("End UPath\n")


g = m.match(s)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

--util.testYes(dir .. '/test/yes/', 'titan', p)

--util.testNo(dir .. '/test/no/', 'titan', p)

--util.testNoRecDist(dir .. '/test/no/', 'titan', p)


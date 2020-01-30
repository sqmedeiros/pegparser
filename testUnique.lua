local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local recovery = require 'pegparser.recovery'
local util = require 'pegparser.util'


local function autoLab (s)
	local g = m.match(s)
	local gupath = recovery.putlabels(g, 'upath', false)
	return pretty.printg(gupath, true, nil, "notLex")
end

local function assertEqual (manual, auto)	
	assert(util.removeSpace(manual) == util.removeSpace(auto),
         'Not equal!\nManual:\n' .. manual .. '\n' .. 'Auto:\n' .. auto)
end


local s = [[
s <- 'a' 'b' / 'c' 'd'
]]

local manualLab = [[
s <- ('a' 'b'^Err_001 / 'c' 'd'^Err_002)^Err_003
]]

assertEqual(manualLab, autoLab(s))


s = [[
s <- ('a' 'b' / 'a' 'c')*
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c'^Err_001)*
]]

assertEqual(manualLab, autoLab(s))


s = [[
  inicio         <-  SKIP ('A' regra1  'x' /  'A' regra2  /  'A' 'id' / regra3)* !.
  regra1         <-  'a' 'b' 'y' / 'a' 'c' / 'd' 'a'
  regra2         <-  'G' 'H'
	regra3         <- regra1
]]

manualLab = [[
  inicio         <-  SKIP ('A' regra1  'x'^Err_001 /  'A' regra2  /  'A' 'id'^Err_002 / regra3)* !.
  regra1         <-  'a' 'b' 'y'^Err_003 / 'a' 'c'^Err_004 / 'd' 'a'^Err_005
  regra2         <-  'G' 'H'^Err_006
	regra3         <- regra1
]]

assertEqual(manualLab, autoLab(s))


-- The algorithm must not annotate 'else'
-- In case the algorithm tries to annotate symbols with the same prefix
-- and it can annotate, in the first alternative, symbols '(', exp, ')', cmd
s = [[
	s    <- 'if' '(' exp ')' cmd 'else' cmd  /  'if' '(' exp ')' cmd
  exp  <- '0' / '1'
  cmd  <- 'print'
]]

manualLab = [[
	s    <- ('if' '(' exp ')' cmd 'else' cmd^Err_001  /  'if' '('^Err_002 exp^Err_003 ')'^Err_004 cmd^Err_005)
  exp  <- '0' / '1'
  cmd  <- 'print'
]]

assertEqual(manualLab, autoLab(s))






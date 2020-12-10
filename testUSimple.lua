local m = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'
local recovery = require 'pegparser.recovery'
local util = require 'pegparser.util'


local function autoLab (s)
  local g = m.match(s)
  local gupath = recovery.putlabels(g, 'usimple', false)
  return pretty.printg(gupath, true, nil, "notLex")
end

local function assertEqual (manual, auto)
	print("Auto")
  assert(util.removeSpace(manual) == util.removeSpace(auto),
         'Not equal!\nManual:\n' .. manual .. '\n' .. 'Auto:\n' .. auto)
end


-- The matching of the start rule must succeed.
local s = [[
s <- 'a' 'b'
]]

local manualLab = [[
s <- 'a' 'b'^Err_001
]]

assertEqual(manualLab, autoLab(s))

-- The alternatives of this choice are disjoint.
-- The choice must succeed, since that the start rule
-- must succeed.
-- After matching a symbol in the FIRST set of the the first
-- alternative the matching of first alternative must succeed.
-- As the choice must succeed, the last alternative must succeed
-- when we try to match it.
s = [[
s <- 'a' 'b' / 'c' 'd'
]]

manualLab = [[
s <- 'a' 'b'^Err_001 / 'c' 'd'^Err_002
]]

assertEqual(manualLab, autoLab(s))



-- The alternatives of this choice are not disjoint.
-- Given that the start rule must succeed, the choice
-- must succeed. Thus, the last alternative of this
-- choice must succeed.
s = [[
s <- 'a' 'b' / 'a' 'c'
]]

manualLab = [[
s <- 'a' 'b' / 'a' 'c'
]]

assertEqual(manualLab, autoLab(s))


-- The alternatives of the choice in the start rule are disjoint.
-- This choice must succeed, so we can annotate the whole choice as
-- also as its second alternative.
-- The choice in rule x is disjoint, but we can not annotate,
-- because it is used in the first alternative of rule s where
-- the context is not unique (the parser can backtrack after failing
-- to match x here)
s = [[
s <- x 'b' / 'c' 'd'
x <- 'a' / 'A'
]]

manualLab = [[
s <- x 'b' / 'c' 'd'^Err_001
x <- 'a' / 'A'
]]

assertEqual(manualLab, autoLab(s))


s = [[
s <- (x  / y)*
x <- 'a' 'b'
y <- 'a' 'c' 'd'
]]

manualLab = [[
s <- (x  / y)*
x <- 'a' 'b'
y <- 'a' 'c' 'd'^Err_001
]]

assertEqual(manualLab, autoLab(s))

s = [[
program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* 
toplevelfunc    <-  localopt 'function' 'name' '(' ')' 'return' 'end'
toplevelvar     <-  localopt 'name' '=' 'x'
toplevelrecord  <-  'record' 'name' '{' '}' 'end'
localopt        <-  'local'?
import          <-  'local' 'name' '=' 'import' ('(' 'string' ')'  /  'string')
foreign         <-  'local' 'name' '=' 'foreign' 'import' ('(' 'string' ')'  /  'string')
]]

manualLab = [[
program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign)* 
toplevelfunc    <-  localopt 'function' 'name'^Err_001 '('^Err_002 ')'^Err_003 'return'^Err_004 'end'^Err_005
toplevelvar     <-  localopt 'name' '=' 'x'
toplevelrecord  <-  'record' 'name'^Err_006 '{'^Err_007 '}'^Err_008 'end'^Err_009
localopt        <-  'local'?
import          <-  'local' 'name' '=' 'import' ('(' 'string' ')'  /  'string')
foreign         <-  'local' 'name' '=' 'foreign' 'import'^Err_010 ('(' 'string'^Err_011 ')'^Err_012  /  'string'^Err_013)^Err_014
]]
assertEqual(manualLab, autoLab(s))


-- The start rule must succeed, so we should only
-- leave the repetition when it is possible to match
-- the a symbol that must follow it.
s = [[
s <- ('a' 'b' / 'a' 'c')*
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c')*
]]

assertEqual(manualLab, autoLab(s))


-- The start rule must succeed, so after matching the
-- repeitition as also 'a'? we must match a symbol that
-- follows these expressions
s = [[
s <- ('a' 'b' / 'a' 'c')* 'd'?
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c')* 'd'?
]]

assertEqual(manualLab, autoLab(s))


-- Similar to the previous example,
-- but there is an intersection between
-- FIRST('a''b' / 'a''c') and FIRST('a'?)
s = [[
s <- ('a' 'b' / 'a' 'c')* 'a'?
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c')* 'a'?
]]

assertEqual(manualLab, autoLab(s))


-- Lexical rules start in uppercase.
-- The current algorithm does not annotate lexical rules,
-- thus 'assertEqual' does not check them.
-- We should not list the lexical rules in 'manualLab'.
s = [[
s <- A 'b' / A 'c'
A <- 'a'
]]

manualLab = [[
s <- A 'b' / A 'c'
]]

assertEqual(manualLab, autoLab(s))


-- Assumes the FIRST set of a lexical rule A is disjoint
-- from all FIRST sets which do not contain A
s = [[
s <- (A 'b' / B 'c')
A <- 'a'
B <- 'a'
]]

manualLab = [[
s <- A 'b'^Err_001 / B 'c'^Err_002
]]

assertEqual(manualLab, autoLab(s))


-- FIRST(A) is different from FIRST('a')
s = [[
s <- A 'b' / 'a' 'c'
A <- 'a'
]]

manualLab = [[
s <- A 'b'^Err_001 / 'a' 'c'^Err_002
]]

assertEqual(manualLab, autoLab(s))


s = [[
  inicio         <-  ('A' regra1  'x' /  'A' regra2  /  'A' 'id' / regra3)* !.
  regra1         <-  'a' 'b' 'y' / 'a' 'c' / 'd' 'a'
  regra2         <-  'G' 'H'
  regra3         <-  regra1
]]

manualLab = [[
  inicio         <-  ('A' regra1  'x' /  'A' regra2  /  'A' 'id' / regra3 )* !.
  regra1         <-  'a' 'b' 'y'^Err_001 / 'a' 'c' / 'd' 'a'^Err_002
  regra2         <-  'G' 'H'^Err_003
  regra3         <- regra1
]]

assertEqual(manualLab, autoLab(s))


s = [[
	s <- 'a' 'b' 'c' / 'a' 'b' 'd'
]]

manualLab = [[
	s <- 'a' 'b' 'c' / 'a' 'b' 'd'
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
  s    <- 'if' '(' exp ')' cmd 'else' cmd^Err_001  /  'if' '(' exp ')' cmd
  exp  <- '0' / '1'
  cmd  <- 'print'
]]

assertEqual(manualLab, autoLab(s))



-- Annottating a choice with more than two alternatives. It should annotate the last alternative
s = [[
	s  <- 'a' / 'b' / 'y'
]]

manualLab = [[
	s  <- 'a' / 'b' / 'y'
]]

assertEqual(manualLab, autoLab(s))


s = [[
	s  <- a / b
  a  <- 'a' c / 'z' c
  b  <- 'a' c 'k' / 'x' 'f'
  c  <- 'd' 'e'
]]

manualLab = [[
	s  <- a / b
  a  <- 'a' c / 'z' c^Err_001
  b  <- 'a' c 'k' / 'x' 'f'^Err_002
  c  <- 'd' 'e'^Err_003
]]

assertEqual(manualLab, autoLab(s))

s = [[
	s  <- a / b / 'y'
  a  <- 'a' c / 'z' c
  b  <- 'a' c 'k' / 'x' 'f'
  c  <- 'd' 'e'
]]

manualLab = [[
	s  <- a / b / 'y'
  a  <- 'a' c / 'z' c^Err_001
  b  <- 'a' c 'k' / 'x' 'f'^Err_002
  c  <- 'd' 'e'^Err_003
]]

--TODO: Review ord to annotate the last alternative of a choice with more than two alternatives
--TODO: update manualLab
assertEqual(manualLab, autoLab(s))



s = [[
  s    <- 'a' x  /  'b' x
  x  <- 'print'
]]

manualLab = [[
  s    <- 'a' x^Err_001  /  'b' x^Err_002
  x  <- 'print'
]]

assertEqual(manualLab, autoLab(s))


s = [[
  s    <- 'a'* x  /  'b' x
  x  <- 'print'
]]

manualLab = [[
  s    <- 'a'* x  /  'b' x^Err_001
  x  <- 'print'
]]

assertEqual(manualLab, autoLab(s))


s = [[
  s    <- 'a'* x  /  'a'* y
  x  <- 'print'
  y  <- 'read'
]]

manualLab = [[
  s    <- 'a'* x  /  'a'* y
  x  <- 'print'
  y  <- 'read'
]]

assertEqual(manualLab, autoLab(s))


s = [[
  s    <- 'a' s 'a'  / 'b' s 'b' / ''
]]

manualLab = [[
    s    <- 'a' s 'a'  /  'b' s 'b' / ''
]]

assertEqual(manualLab, autoLab(s))



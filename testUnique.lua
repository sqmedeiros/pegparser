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
	print("Auto")
  assert(util.removeSpace(manual) == util.removeSpace(auto),
         'Not equal!\nManual:\n' .. manual .. '\n' .. 'Auto:\n' .. auto)
end


-- The matching of the start rule must succeed.
local s = [[
s <- 'a'
]]

local manualLab = [[
s <- 'a'^Err_001
]]


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
s <- ('a' 'b'^Err_001 / 'c'^Err_002 'd'^Err_003)^Err_004
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
s <- ('a' 'b' / 'a'^Err_001 'c'^Err_002)^Err_003
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
s <- (x 'b'^Err_001 / 'c'^Err_002 'd'^Err_003)^Err_004
x <- 'a' / 'A'
]]

assertEqual(manualLab, autoLab(s))

s = [[
s <- (x  / y)*
x <- 'a' 'b'
y <- 'a' 'c' 'd'
]]

manualLab = [[
s <- (x  / y / !(!.) %{Err_001} .)*
x <- 'a' 'b'
y <- 'a' 'c'^Err_002 'd'^Err_003
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
program         <-  (toplevelfunc  /  toplevelvar  /  toplevelrecord  /  import  /  foreign / !(!.) %{Err_001} .)* 
toplevelfunc    <-  localopt 'function' 'name'^Err_002 '('^Err_003 ')'^Err_004 'return'^Err_005 'end'^Err_006
toplevelvar     <-  localopt 'name' '=' 'x'
toplevelrecord  <-  'record' 'name'^Err_007 '{'^Err_008 '}'^Err_009 'end'^Err_010
localopt        <-  'local'?
import          <-  'local' 'name' '=' 'import' ('(' 'string'^Err_011 ')'^Err_012  /  'string'^Err_013)^Err_014
foreign         <-  'local' 'name'^Err_015 '='^Err_016 'foreign'^Err_017 'import'^Err_018 ('(' 'string'^Err_019 ')'^Err_020  /  'string'^Err_021)^Err_022
]]

assertEqual(manualLab, autoLab(s))


-- The start rule must succeed, so we should only
-- leave the repetition when it is possible to match
-- the a symbol that must follow it.
-- TODO: Currently I am putting an extra '.' after
-- throwing a label in a repetition because an expression
-- as !. %{Err_001} may succeed withtout consuming the input,
-- which leads LPegLabel to complain about a repetition
-- matching an empty expression
s = [[
s <- ('a' 'b' / 'a' 'c')*
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c'^Err_001 / !(!.) %{Err_002} .)*
]]

assertEqual(manualLab, autoLab(s))


-- The start rule must succeed, so after matching the
-- repeitition as also 'a'? we must match a symbol that
-- follows these expressions
s = [[
s <- ('a' 'b' / 'a' 'c')* 'd'?
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c'^Err_001 / !('d' / !.) %{Err_002} .)* ('d' / !(!.) %{Err_003} .)?
]]

assertEqual(manualLab, autoLab(s))


-- Similar to the previous example,
-- but there is an intersection between
-- FIRST('a''b' / 'a''c') and FIRST('a'?)
s = [[
s <- ('a' 'b' / 'a' 'c')* 'a'?
]]

manualLab = [[
s <- ('a' 'b' / 'a' 'c' / !('a' / !.) %{Err_001} .)* ('a' / !(!.) %{Err_002} .)?
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
s <- (A 'b' / A^Err_001 'c'^Err_002)^Err_003
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
s <- (A 'b'^Err_001 / B^Err_002 'c'^Err_003)^Err_004
]]

assertEqual(manualLab, autoLab(s))


-- FIRST(A) is different from FIRST('a')
s = [[
s <- A 'b' / 'a' 'c'
A <- 'a'
]]

manualLab = [[
s <- (A 'b'^Err_001 / 'a'^Err_002 'c'^Err_003)^Err_004
]]

assertEqual(manualLab, autoLab(s))


s = [[
  inicio         <-  ('A' regra1  'x' /  'A' regra2  /  'A' 'id' / regra3)* !.
  regra1         <-  'a' 'b' 'y' / 'a' 'c' / 'd' 'a'
  regra2         <-  'G' 'H'
  regra3         <-  regra1
]]

manualLab = [[
  inicio         <-  ('A' regra1  'x'^Err_001 /  'A' regra2  /  'A' 'id'^Err_002 / regra3 / !(!.) %{Err_003} .)* !.
  regra1         <-  'a' 'b' 'y'^Err_004 / 'a' 'c'^Err_005 / 'd' 'a'^Err_006
  regra2         <-  'G' 'H'^Err_007
  regra3         <- regra1
]]

assertEqual(manualLab, autoLab(s))


s = [[
	s <- 'a' 'b' 'c' / 'a' 'b' 'd'
]]

manualLab = [[
	s <- ('a' 'b'^Err_001 'c' / 'a'^Err_002 'b'^Err_003 'd'^Err_004)^Err_005
]]

--TODO: fix this case (should annotate 'b' in first alternative)
--assertEqual(manualLab, autoLab(s))


-- The algorithm must not annotate 'else'
-- In case the algorithm tries to annotate symbols with the same prefix
-- and it can annotate, in the first alternative, symbols '(', exp, ')', cmd
s = [[
  s    <- 'if' '(' exp ')' cmd 'else' cmd  /  'if' '(' exp ')' cmd
  exp  <- '0' / '1'
  cmd  <- 'print'
]]

manualLab = [[
  s    <- ('if' '('^Err_001 exp^Err_002 ')'^Err_003 cmd^Err_004 'else' cmd^Err_005  /  'if' '('^Err_006 exp^Err_007 ')'^Err_008 cmd^Err_009)^Err_010
  exp  <- ('0' / '1')^Err_011
  cmd  <- 'print'^Err_012
]]

-- TODO: Review isPrefixUniqueEq to annotate '(' in the first alternative
--assertEqual(manualLab, autoLab(s))

s = [[
	s  <- 'a' / 'b'
]]

manualLab = [[
	s  <- ('a' / 'b' / 'y'^Err_001)^Err_002
]]

--TODO: Review ord to annotate the last alternative of a choice with more than two alternatives
--assertEqual(manualLab, autoLab(s))


s = [[
	s  <- a / b
  a  <- 'a' c / 'z' c
  b  <- 'a' c 'k' / 'x' 'f'
  c  <- 'd' 'e'
]]

manualLab = [[
	s  <- (a / b^Err_001)^Err_002
  a  <- 'a' c / 'z' c^Err_003
  b  <- ('a' c^Err_004 'k'^Err_005 / 'x'^Err_006 'f'^Err_007)^Err_008
  c  <- 'd' 'e'^Err_009
]]

assertEqual(manualLab, autoLab(s))

s = [[
	s  <- a / b / 'y'
  a  <- 'a' c / 'z' c
  b  <- 'a' c 'k' / 'x' 'f'
  c  <- 'd' 'e'
]]

manualLab = [[
	s  <- (a / b^Err_001)^Err_002
  a  <- 'a' c / 'z' c^Err_003
  b  <- ('a' c^Err_004 'k'^Err_005 / 'x'^Err_006 'f'^Err_007)^Err_008
  c  <- 'd' 'e'^Err_009
]]

--TODO: Review ord to annotate the last alternative of a choice with more than two alternatives
--TODO: update manualLab
--assertEqual(manualLab, autoLab(s))



s = [[
  s    <- 'a' x  /  'b' x
  x  <- 'print'
]]

manualLab = [[
  s    <- ('a' x^Err_001  /  'b'^Err_002 x^Err_003)^Err_004
  x  <- 'print'^Err_005
]]

assertEqual(manualLab, autoLab(s))


s = [[
  s    <- 'a'* x  /  'b' x
  x  <- 'print'
]]

manualLab = [[
  s    <- ('a'* x  /  'b'^Err_001 x^Err_002)^Err_003
  x  <- 'print'
]]

assertEqual(manualLab, autoLab(s))


s = [[
  s    <- 'a'* x  /  'a'* y
  x  <- 'print'
  y  <- 'read'
]]

manualLab = [[
  s    <- ('a'* x  /  ('a' / !'read' %{Err_001} .)* y^Err_002)^Err_003
  x  <- 'print'
  y  <- 'read'^Err_004
]]

assertEqual(manualLab, autoLab(s))





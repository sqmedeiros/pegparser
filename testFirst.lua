local parser = require'pegparser.parser'
local first = require'pegparser.first'
local pretty = require'pegparser.pretty'

local empty = first.empty
local any = first.any

-- testing FIRST and FOLLOW
-- Rules starting with an uppercase letter (A, Start, START) are lexical rules.
-- The FIRST set of a lexical rule A is A itself (__A more currently).


local function assertequal_aux (v, pre, comp)
	for k, _ in pairs (pre) do
		assert(comp[k], '"' .. v .. '": missing "' .. k .. '" in computed set.')
	end
	for k, _ in pairs (comp) do
		assert(pre[k], '"' .. v .. '": missing "' .. k .. '" in predefined set.')
	end
end

local function assertequal (pre, comp)
	local auxk = nil
	comp['SKIP'] = nil
	comp['SPACE'] = nil
	for k, v in pairs (pre) do
		assertequal_aux(k, v, comp[k])
		auxk = next(comp, auxk)
	end
	local x = next(comp, auxk)
	assert(x == nil, x)
end

local function makeset (l)
	local t = {}
	for _, v in ipairs(l) do
		t[v] = true	
	end
	return t
end

local g = [[
	s <- (a / b)* 'c'
	a <- 'a'
  b <- 'b' 
]]

local prefst = {
  s = makeset{'a', 'b', 'c'},
	a = makeset{'a'},
	b = makeset{'b'}
}
local preflw = {
	s = makeset{'$'},
	a = makeset{'a',  'b', 'c'},
	b = makeset{'a', 'b', 'c'}
}

local peg = parser.match(g)
local fst = first.calcFst(peg)
local flw = first.calcFlw(peg)


assertequal(prefst, fst)
assertequal(preflw, flw)


local g = [[
	s <- ('o' a / 'u' b)* (c / d)* 'c' e f g
	a <- 'a'?
  b <- 'b'? 'x' 
  c <- 'k'+ 'z'  
	d <- 'd'
	e <- !'e' 'g'
  f <- &'f' 'g'  
  g <- &'e' !'f'  
]]


local prefst = {
  s = makeset{'o', 'u', 'k', 'd', 'c'},
	a = makeset{empty, 'a'},
	b = makeset{'b', 'x'},
	c = makeset{'k'},
	d = makeset{'d'},
	e = makeset{'g'},
	f = makeset{'g'},
	g = makeset{empty}
}

local preflw = {
  s = makeset{'$'},
	a = makeset{'o', 'u', 'k', 'd', 'c'},
	b = makeset{'o', 'u', 'k', 'd', 'c'},
	c = makeset{'k', 'd', 'c'},
	d = makeset{'k', 'd', 'c'},
	e = makeset{'g'},
	f = makeset{'$'},
	g = makeset{'$'}
}


local peg = parser.match(g)
local fst = first.calcFst(peg)
local flw = first.calcFlw(peg)

assertequal(prefst, fst)
assertequal(preflw, flw)


local g = [[
	s <- a^bola / b
	a <- 'a' %{Erro}
  b <- 'b'? 'x'? ('y'+)^Erro2 
]]

local prefst = {
  s = makeset{'a', 'b', 'x', 'y', empty},
	a = makeset{'a'},
	b = makeset{'b', 'x', 'y', empty},
}

local preflw = {
  s = makeset{'$'},
	a = makeset{'$'},
	b = makeset{'$'},
}


local peg = parser.match(g)
local fst = first.calcFst(peg)
local flw = first.calcFlw(peg)

assertequal(prefst, fst)
assertequal(preflw, flw)


local g = [[
	s <- a s b / ([a-cd] / c)* 
	a <- .   
  b <- ('x' / d)*
	c <- 'f'? 'y'+
	d <- 'd' / c
]]

local prefst = {
  s = makeset{any, 'a', 'b', 'c', 'd', 'f', 'y', empty},
	a = makeset{any},
	b = makeset{'x', 'd', 'f', 'y', empty},
	c = makeset{'f', 'y'},
	d = makeset{'d', 'f', 'y'},
}

local preflw = {
  s = makeset{'$', 'x', 'd', 'f', 'y'},
	a = makeset{any, 'a', 'b', 'c', 'd', 'f', 'y', '$', 'x'},
	b = makeset{'$', 'x', 'd', 'f', 'y'},
	c = makeset{'a', 'b', 'c', 'd', 'f', 'y', '$', 'x'},
	d = makeset{'$', 'x', 'd', 'f', 'y'},
}


local peg = parser.match(g)
local fst = first.calcFst(peg)
local flw = first.calcFlw(peg)

assertequal(prefst, fst)
assertequal(preflw, flw)

print("+")

local g = [[
	s <- A
	A <- 'a'   
  B <- 'a'
	C <- A
	D <- B
	c <- A
	d <- B
]]

local prefst = {
  s = makeset{'__A'},
	A = makeset{'__A'},
	B = makeset{'__B'},
	C = makeset{'__C'},
	D = makeset{'__D'},
	c = makeset{'__A'},
	d = makeset{'__B'},
}

local preflw = {
  s = makeset{'$'},
	A = makeset{'$'},
	B = makeset{},
	C = makeset{},
	D = makeset{},
	c = makeset{},
	d = makeset{},
}


local peg = parser.match(g)
local fst = first.calcFst(peg)
local flw = first.calcFlw(peg)

assert(first.disjoint(fst['s'], fst['A']) == false)
assert(first.disjoint(fst['s'], fst['C']) == true)
assert(first.disjoint(fst['A'], fst['B']) == true)
assert(first.disjoint(fst['A'], fst['C']) == true)
assert(first.disjoint(fst['A'], fst['c']) == false)
assert(first.disjoint(fst['C'], fst['D']) == true)
assert(first.disjoint(fst['C'], fst['c']) == true)
assert(first.disjoint(fst['D'], fst['d']) == true)

assertequal(prefst, fst)
assertequal(preflw, flw)

print("Ok")



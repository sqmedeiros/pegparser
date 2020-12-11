local parser = require'pegparser.parser'
local first = require'pegparser.first'

local disjoint = first.disjoint
local calck = first.calck
local calcfirst = first.calcfirst
local union = first.union
local getName = first.getName
local isLastAlternativeAux

local fst, flw
local ON = 'on'
local PAUSE = 'pause'
local OFF = 'off'


local function updateCountTk (v, t)
	if not t[v] then
		t[v] = 1
	else
		t[v] = t[v] + 1
	end
end


local function countTk (p, t)
	if p.tag == 'char' then
		updateCountTk(p.p1, t)
	elseif p.tag == 'set' then
		for i, v in pairs(p.l) do
			updateCountTk(v, t)
		end
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		updateCountTk(p.p1, t)
	elseif p.tag == 'con' or p.tag == 'ord' then
		countTk(p.p1, t)
		countTk(p.p2, t)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		countTk(p.p1, t)
	elseif p.tag == 'and' or p.tag == 'not' then
		--does not count tokens inside a predicate
		return
	end
end


local function printUnique (t)
	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end
	table.sort(l)
	io.write("Unique tokens (# " .. #l .. "): ")
	io.write(table.concat(l, ', '))
	io.write('\n')
end


local function setlabel (p, upath)
	if upath == ON and not parser.matchEmpty(p) then
		p.label = true
	end
end

local function updateUPath (p, upath)
	if p.unique then
		return ON
	elseif upath == PAUSE and not parser.matchEmpty(p) then
		return ON
	else
		return upath
	end
end


local function uniqueTk (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			countTk(g.prules[v], t)
		end
	end

	print("Uunique")
	local cont = {}
	local unique = {}
	for k, v in pairs(t) do
		print(k, " = ", v)
		unique[k] = (v == 1) or nil
		if not cont[v] then
			cont[v] = 1
		else
			cont[v] = cont[v] + 1
		end
	end
	
	--[==[
	for i = 1, 10 do
		print("Token ", i, " = ", cont[i])
	end
	]==]

	unique['SKIP'] = nil 
	printUnique(unique)
	return unique
end


local function addUsage(g, p)
	if not g.varUsage[p.p1] then
		g.varUsage[p.p1] = {}
	end
	table.insert(g.varUsage[p.p1], p)
end


local function countUsage(g, p)
	local tag = p.tag
	if tag == 'empty' or tag == 'char' or tag == 'set' or
     tag == 'any' or tag == 'throw' or tag == 'def' then
		return
	elseif tag == 'var' and parser.isLexRule(p.p1) then
		return
	elseif tag == 'var' then
		addUsage(g, p)
	elseif tag == 'not' or tag == 'and' or tag == 'star' or
         tag == 'opt' or tag == 'plus' then
		countUsage(g, p.p1)
	elseif tag == 'con' or tag == 'ord' then
		countUsage(g, p.p1)
		countUsage(g, p.p2)
	else
		print(p)
		error("Unknown tag", p.tag)
	end

end

local function varUsage (g)
	g.varUsage = {}
	for i, v in ipairs(g.plist) do
		if not g.varUsage[v] then
			g.varUsage[v] = {}
		end
		countUsage(g, g.prules[v])
	end
end

local function printVarUsage (g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			print("Usage", v, #g.varUsage[v])
		end
	end
end

local function setUnique (p, unique)
	p.unique = unique
end

local function setUniqueTk (g, p)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		setUnique(p, g.uniqueTk[p.p1])
	elseif p.tag == 'ord' or p.tag == 'con' then
		setUniqueTk(g, p.p1)
		setUniqueTk(g, p.p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		setUniqueTk(g, p.p1)
	end
end

local function calcUPathChoice (first1, first2, upath)
	if disjoint(first1, first2) and (upath == ON or upath == PAUSE) then
		return PAUSE
	else
		return OFF
	end
end

local function uniquePath (g, p, upath, flw)
	if p.tag == 'char' or p.tag == 'var' then
		setlabel(p, upath)
		return updateUPath(p, upath)
	elseif p.tag == 'con' then
		upath = uniquePath(g, p.p1, upath, calck(g, p.p2, flw))
		return uniquePath(g, p.p2, upath, flw)
	elseif p.tag == 'ord' then
		setlabel(p, upath)
		local upathP1 = calcUPathChoice(calcfirst(g, p.p1), calck(g, p.p2, flw), upath)
    uniquePath(g, p.p1, upathP1, flw)
		uniquePath(g, p.p2, upath, flw)
		--could remove this line and return the previous call to 'uniquePath'
		return updateUPath(p, upath)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		local upathP1 = calcUPathChoice(calcfirst(g, p.p1), flw, upath)
		uniquePath(g, p.p1, upathP1, flw)
		return upath
	end
end


local function calcUniquePath (g, upathStart)
	g.uniqueVar = {}
	for i, v in ipairs(g.plist) do
		g.uniqueVar[v] = OFF
	end

	if upathStart then
		g.uniqueVar[g.plist[1]] = ON
	end

	fst = first.calcFst(g)
	flw = first.calcFlw(g)	

	g.notDisjointFirst = first.notDisjointFirst(g)

	g.uniqueTk = uniqueTk(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			setUniqueTk(g, g.prules[v])
		end
	end

	varUsage(g)
	for i, v in ipairs(g.plist) do		
		if not parser.isLexRule(v) then
			uniquePath(g, g.prules[v], g.uniqueVar[v], flw[v])
		end
	end
	

	--[==[io.write("Unique vars: ")
	for i, v in ipairs(g.plist) do
		if g.uniqueVar[v].upath then
			io.write(v .. '(' .. tostring(g.uniqueVar[v].upath) .. ';' .. tostring(g.uniqueVar[v].seq) .. ')' .. ', ')
		end
	end
	io.write('\n')
  ]==]

end


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
}

local parser = require'parser'
local first = require'first'

local disjoint = first.disjoint
local calck = first.calck
local calcfirst = first.calcfirst

local changeUnique = false


local function matchUnique (g, p)
	if p.tag == 'char' then
		return g.unique[p.p1]
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		return g.unique[p.p1]
	elseif p.unique and not parser.matchEmpty(p) then
		return true
	elseif p.tag == 'con' then
		return matchUnique(g, p.p1) or matchUnique(g, p.p2)
	elseif p.tag == 'ord' then
		return matchUnique(g, p.p1) and matchUnique(g, p.p2)
	elseif p.tag == 'plus' then
		return matchUnique(g, p.p1)
	else
		return false
	end
end


local function matchUPath (p)
	if p.tag == 'char' or p.tag == 'var' then
		return p.unique
	elseif p.tag == 'con' then
		return p.unique
	elseif p.tag == 'ord' then
		return p.unique
	elseif p.tag == 'plus' then
		return p.unique
	else
		return false
	end
end


local function updateCountTk (p, t)
	local v = p.p1
	if not t[v] then
		t[v] = 1
	else
		t[v] = t[v] + 1
	end
end


local function countTk (p, t)
	if p.tag == 'char' then
		updateCountTk(p, t)
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		updateCountTk(p, t)
	elseif p.tag == 'con' or p.tag == 'ord' then
		countTk(p.p1, t)
		countTk(p.p2, t)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		countTk(p.p1, t)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		countTk(p.p1, t)
	elseif p.tag == 'nameCap' then
		countTk(p.p2, t)
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


local function uniqueTk (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			countTk(g.prules[v], t)
		end
	end

	local unique = {}
	for k, v in pairs(t) do
		unique[k] = (v == 1) or nil
	end
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
     tag == 'any' or tag == 'throw' or tag == 'posCap' or
     tag == 'def' then
		return
	elseif tag == 'var' and parser.isLexRule(p.p1) then
		return
	elseif tag == 'var' then
		addUsage(g, p)
	elseif tag == 'not' or tag == 'and' or tag == 'star' or
         tag == 'opt' or tag == 'plus' or tag == 'simpCap' or
         tag == 'tabCap' or tag == 'anonCap' then
		countUsage(g, p.p1)
	elseif tag == 'con' or tag == 'ord' then
		countUsage(g, p.p1)
		countUsage(g, p.p2)
	elseif tag == 'nameCap' then
		countUsage(p.p2)
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


local function uniqueUsage (g, p)
	for k, v in pairs(g.varUsage[p.p1]) do
		if not v.unique then
			return false
		end
	end
	print("Unique usage", p.p1)
	return true
end


local function setUnique (p, v)
	if not v then
		return
	end
	if not p.unique then
		changeUnique = true
	end
	p.unique = true
end


local function uniquePath (g, p, uPath, flw)
	if p.tag == 'char' then
		setUnique(p, uPath or g.uniqueTk[p.p1])
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		setUnique(p, uPath or g.uniqueTk[p.p1])
	elseif p.tag == 'var' and uPath then
		print("unique var ", p.p1)
		setUnique(p, true)
		g.uniqueVar[p.p1] = uniqueUsage(g, p)
	elseif p.tag == 'con' then
		uniquePath(g, p.p1, uPath, calck(g, p.p2, flw))
		uPath = uPath or p.p1.unique
		uniquePath(g, p.p2, uPath, flw)
		setUnique(p, uPath or p.p2.unique)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		uniquePath(g, p.p1, flagDisjoint and uPath, flw)
		uniquePath(g, p.p2, uPath, flw)
		setUnique(p, uPath or (p.p1.unique and p.p2.unique))
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		uniquePath(g, p.p1, flagDisjoint and uPath, flw)
		if p.tag == 'plus' then
			setUnique(p, uPath or p.p1.unique)
		else
			setUnique(p, uPath)
		end
	end
end


local function insideLoop (g, p, loop, seq)
	 if p.tag == 'var' and not parser.isLexRule(p.p1) and loop and not seq then
		g.loopVar[p.p1] = true
	elseif p.tag == 'con' then
		insideLoop(g, p.p1, loop, seq)
		insideLoop(g, p.p2, loop, seq or not parser.matchEmpty(p.p1))
	elseif p.tag == 'ord' then
		insideLoop(g, p.p1, loop, seq)
		insideLoop(g, p.p2, loop, seq)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		insideLoop(g, p.p1, true, false)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		insideLoop(g, p.p1, loop, seq)
	elseif p.tag == 'nameCap' then
		insideLoop(g, p.p2, loop, seq)
	elseif p.tag == 'and' or p.tag == 'not' then
		insideLoop(g, p.p1, loop, seq)
	end

end


local function calcUniquePath (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	g.uniqueTk = uniqueTk(g)
	g.uniqueVar = {}
	g.uniqueVar[g.plist[1]] = true
	varUsage(g)
	changeUnique = true
	while changeUnique do
		changeUnique = false
		for i, v in ipairs(g.plist) do
			if not parser.isLexRule(v) then
				uniquePath(g, g.prules[v], g.uniqueVar[v], flw[v])
			end
		end
	end

	g.loopVar = {}
	for i, v in ipairs(g.plist) do
		insideLoop(g, g.prules[v], false, false)
	end
	io.write("insideLoop: ")
	for i, v in ipairs(g.plist) do
		if g.loopVar[v] then
			io.write(v .. ', ')
		end
	end
	io.write('\n')
end


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
	matchUnique = matchUnique,
	matchUPath = matchUPath
}

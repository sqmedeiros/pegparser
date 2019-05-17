local parser = require'parser'
local first = require'first'

local disjoint = first.disjoint
local calck = first.calck
local calcfirst = first.calcfirst

local changeUnique = false

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


local function uniqueTk (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			countTk(g.prules[v], t)
		end
	end

	t['SKIP'] = true

	local unique = {}
	for k, v in pairs(t) do
		unique[k] = v == 1
		if v == 1 then
			print("unique", k)
		end
	end
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


local function calcUniquePath (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	g.uniqueTk = uniqueTk(g)
	g.uniqueVar = {}
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
end


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
}

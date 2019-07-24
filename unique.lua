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
	
	for i = 1, 10 do
		print("Token ", i, " = ", cont[i])
	end

	unique['SKIP'] = nil 
	printUnique(unique)
	return unique
end


local function belongRHSFirst (g, p, rhs)
	if rhs.tag == 'char' then
		return p == rhs
	elseif rhs.tag == 'var' and parser.isLexRule(p.p1) then 
		return p == rhs
	elseif rhs.tag == 'var' and p.tag == 'var' then
		return not disjoint(calcfirst(g, p), calcfirst(g, rhs))
	elseif rhs.tag == 'con' then
		if belongRHSFirst(g, p, rhs.p1) then
			return true
		end
		return parser.matchEmpty(rhs.p1) and belongRHSFirst(g, p, rhs.p2) 
	elseif rhs == 'ord' then
		return belongRHSFirst(g, p, rhs.p1) or belongRHSFirst(g, p, rhs.p2)
	elseif rhs.tag == 'star' or rhs.tag == 'plus' or rhs.tag == 'opt' then
		return belongRHSFirst(g, p, rhs.p1)
	else
		return false
	end
end


local function isPrefixUniqueVar (g, p)
	local s = p.p1

	print("symPref", s, p, p.p1)
	local pref = g.symPref[s][p]
	--local flw = g.symFlw[s][p]
	--print(s, " pref := ", table.concat(first.sortset(pref), ", "), " flw := ", table.concat(first.sortset(flw), ", "))
	local res = true
	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) then
				--res = 'next'
				--if not disjoint(flw, g.symFlw[s][k]) then
					return false
				--end
			end
		end
	end

	print("analisar ", p.p1)
	local tk = calcfirst(g, p)
	local rhs = g.prules[p.p1]
	for k1, v1 in pairs(tk) do
		print("k1, v1", k1, v1)
		if k1 ~= '__empty' then
			if string.sub(k1, 1, 2) ~= '__' then k1 = '__' .. k1 else k1 = string.sub(k1, 3) end
			for k2, v2 in pairs(g.symPref[k1]) do
				if not belongRHSFirst(g, k2, rhs) then
					if not disjoint(pref, v2) then
						return false
					end
				end
			end
		end
	end
	print("vai ser true", p.p1)
	
	--return false
	return res
end


local function isPrefixUnique (g, p)
	local s = p.p1
	if p.tag == 'char' then
		s = '__' .. s
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		s = p.p1
	--elseif p.tag == 'var' then
	--	return isPrefixUniqueVar(g, p.p1)	
	--	s = p.p1
	else
		return false
	end

	print("symPref", s, p, p.p1)
	local pref = g.symPref[s][p]
	--local flw = g.symFlw[s][p]
	--print(s, " pref := ", table.concat(first.sortset(pref), ", "), " flw := ", table.concat(first.sortset(flw), ", "))
	local res = true
	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) then
				--res = 'next'
				--if not disjoint(flw, g.symFlw[s][k]) then
					return false
				--end
			end
		end
	end

	--return false
	return res
end


local function setNextUnique (p)
	if p.tag == 'char' or p.tag == 'var' then
		p.unique = true
	elseif p.tag == 'ord' then
		p.unique = true
	elseif p.tag == 'con' then
		setNextUnique(p.p1)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		p.unique = true
		setNextUnique(p.p1)
	end
end

local function lastSymCon (p)
	if p.tag == 'con' then
		return p.p2
	else
		return p
	end
end

local function uniquePrefixAux (g, p)
	if p.tag == 'char' or p.tag == 'var' then
		--assert(not p.unique or (p.unique == true and isPrefixUnique(g, p) == true))
		--if p.p1 == '=' then
		--	print("here __= ", isPrefixUnique(g, p))
		--end
		p.unique = p.unique or (isPrefixUnique(g, p) == true)
	elseif p.tag == 'con' then
		uniquePrefixAux(g, p.p1)
		local res = isPrefixUnique(g, lastSymCon(p.p1))
		if res == 'next' then
			local x = lastSymCon(p.p1)
			print("Nextt", x.tag, x.p1)
			setNextUnique(p.p2)
		end
		uniquePrefixAux(g, p.p2)
	elseif p.tag == 'ord' then
		uniquePrefixAux(g, p.p1)
		uniquePrefixAux(g, p.p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		uniquePrefixAux(g, p.p1)
	end
end


local function uniquePrefix (g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			uniquePrefixAux(g, g.prules[v])
		end
	end
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
	elseif p.tag == 'var' then
		--print("p.p1", p.p1, #g.varUsage[p.p1])
		if matchUnique(g, g.prules[p.p1]) and #g.varUsage[p.p1] == 1 then
		--if matchUnique(g, g.prules[p.p1]) then
			print("unique var2 ", p.p1)
			setUnique(p, true)
		end
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
	first.calcTail(g)
	first.calcPrefix(g)
	first.calcLocalFollow(g)
	uniquePrefix(g)
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


	io.write("Unique vars: ")
	for i, v in ipairs(g.plist) do
		if g.uniqueVar[v] then
			io.write(v .. ', ')
		end
	end
	io.write('\n')

end


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
	matchUnique = matchUnique,
	matchUPath = matchUPath,
}

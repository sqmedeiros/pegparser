local parser = require'pegparser.parser'
local first = require'pegparser.first'

local disjoint = first.disjoint
local calck = first.calck
local calcfirst = first.calcfirst
local union = first.union
local isLastAlternativeAux

local changeUnique = false
local fst, flw

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


local function matchUniqueEq (p)
	if (p.tag == 'char' or p.tag == 'var') and not parser.matchEmpty(p) then
		return p.uniqueEq
	elseif p.tag == 'con' then
		return matchUniqueEq(p.p2)
	elseif p.tag == 'ord' then
		return matchUniqueEq(p.p1) and matchUniqueEq(p.p2)
	elseif p.tag == 'plus' then
		return matchUniqueEq(p.p1)
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

	--[==[print("analisar ", p.p1)
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
	]==]
	print("vai ser true", p.p1)
	
	--return false
	return res
end


local function isPrefUniVarAux2 (g, p, pref)
	local s = p.p1
	if p.tag == 'char' then
		s = '__' .. s
	end

	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) and not isLastAlternative(g, p, g.symPref[s]) then
				return false
			end
		end
	end

	print("passou dois")
	return true
end

local function isPrefUniVarAux (g, p, pref)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		return isPrefUniVarAux2(g, p, pref)
	elseif p.tag == 'var' then
		--io.write("isPrefUniVarAux " .. p.p1 .. ": ")
		--for k, v in pairs(fst) do
		--	io.write(k .. ', ')
		--end
		--io.write('\n')
		--return false
		return isPrefUniVarAux(g, g.prules[p.p1], pref)
	elseif p.tag == 'con' then
		local res = isPrefUniVarAux(g, p.p1, pref)
		if res and parser.matchEmpty(p.p1) then
			res = isPrefUniVarAux(g, p.p2, pref)
		end
		return res 
	elseif p.tag == 'ord' then
		return isPrefUniVarAux(g, p.p1, pref) and isPrefUniVarAux(g, p.p2, pref)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		return isPrefUniVarAux(g, p.p1, pref)	
	else
		print("falseee", p.tag, p.p1, p)
		return false
	end
end

local function getSymbolsFirst (g, p)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		return { [p] = true }
	elseif p.tag == 'var' then
		return getSymbolsFirst(g, g.prules[p.p1])
	elseif p.tag == 'con' then
		local t = getSymbolsFirst(g, p.p1)
		if parser.matchEmpty(p.p1) then
			t = union(t, getSymbolsFirst(g, p.p2))
		end
		return t
	elseif p.tag == 'ord' then
		return union(getSymbolsFirst(g, p.p1), getSymbolsFirst(g, p.p2))
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		return getSymbolsFirst(g, p.p1)
	else
		return {} 
	end
end

local function isPrefSymUnique (g, t, pref)
	for p, _ in pairs(t) do
		local s = p.p1
		if p.tag == 'char' then
			s = '__' .. s
		end
		for k, v in pairs(g.symPref[s]) do
			if not t[k] then
				if not disjoint(pref, v) and not isLastAlternative(g, p, g.symPref[s]) then
					return false
				end
			end
		end
	end
	return true
end

local function isPrefUniVar (g, p)
	local s = p.p1

	--print("symPrefUniVar", s, g.symRule[p])
	local pref = g.symPref[s][p]
	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) then
				return false
			end
		end
	end

	local t = getSymbolsFirst(g, g.prules[p.p1])
	--[==[print("passou um")
	io.write("symbols: ")
	for k, v in pairs(t) do
		io.write('(' .. k.p1 .. ',' .. g.symRule[k] .. '); ')
	end
	io.write("\n")
	]==]
	--local res = isPrefUniVarAux(g, g.prules[p.p1], pref)

	local res = isPrefSymUnique(g, t, pref)
	if res then
		print("passou três", s, g.symRule[p])
	end
	return res
end


local function hasSym (p, v)
	if p.tag == 'char' or p.tag == 'var' then
		return p == v
	elseif p.tag == 'con' or p.tag == 'ord' then
		return hasSym(p.p1, v, opt) or hasSym(p.p2, v, opt)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		return hasSym(p.p1, v, opt)
	else
		return false
	end
end


local function isLastAlternativeAux (p, e, found)
	if p.tag == 'char' or p.tag == 'var' then
		if p.p1 == e.p1 and found and p ~= e then
			return false
		else
			return true
		end
	elseif p.tag == 'ord' then
		if not isLastAlternativeAux(p.p1, e, found) then
			return false
		else
			return isLastAlternativeAux(p.p2, e, found or hasSym(p.p1, e))
		end
	elseif p.tag == 'con' then
		return isLastAlternativeAux(p.p1, e, found) and isLastAlternativeAux(p.p1, e, found)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		return isLastAlternativeAux(p.p1, e, found)
	else
		return true
	end
end


function isLastAlternative (g, p, t)
	--print("lastAlt", p.p1)
	for k, v in pairs(t) do
		if k ~= p and g.symRule[p] ~= g.symRule[k] then
			--print(g.symRule[p], g.symRule[k])
			return false
		end
	end

	local res = isLastAlternativeAux(g.prules[g.symRule[p]], p, false)
	--print("lastAlt", p.p1, res)
	return res
end


local function isPrefixUniqueEq (g, p)
	local s = p.p1
	if p.tag == 'char' then
		s = '__' .. s
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		s = p.p1
	else
		return false
	end

	local pref = g.symPref[s][p]
	local prefEq = {}
	local nPrefEq = 0

	for k, v in pairs(g.symPref[s]) do
		if first.issubset(v, pref) then
			prefEq[k] = true
			nPrefEq = nPrefEq + 1
		elseif not disjoint(pref, v) then
			return false
		end
	end

	-- the prefix set of p is unique
	if nPrefEq == 1 then
		return true
	end

	local flw = g.symFlw[s][p]
	local flwEq = {}
	local nFlwEq = 0

	for k, _ in pairs(prefEq) do
		if not first.issubset(g.symFlw[s][k], flw) then
			return false
		end
	end

	return true
end


local function isPrefixUniqueFlw (g, p, pflw)
	local s = p.p1
	if p.tag == 'char' then
		s = '__' .. s
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		s = p.p1
	else
		return false
	end

	local pref = g.symPref[s][p]
	local prefEq = {}
	local nPrefEq = 0

	local prefInt = {}

	for k, v in pairs(g.symPref[s]) do
		if k ~= p and first.issubset(v, pref) then
			prefEq[k] = true
			nPrefEq = nPrefEq + 1
		end
		if k ~= p and not disjoint(pref, v) then
			table.insert(prefInt, k)
		end
	end

	--print("UniqueFlw", s, "pref = ", table.concat(first.sortset(g.symPref[s][p]), ", "), "flw = ", table.concat(first.sortset(g.symFlw[s][p]), ", "), "nInt = ", #prefInt, "nEq = ", nPrefEq)

	if #prefInt > 0 then
		-- flw sets share some symbol?
		--[=[table.insert(prefInt, p)
		for i = 1, #prefInt do
			local flw1 = g.symFlw[s][prefInt[i]]
			for j = i + 1, #prefInt do
				if not disjoint(flw1, g.symFlw[s][prefInt[j]]) then
					return
				end
			end
		end]=]
		for i = 1, #prefInt do
			if not disjoint(g.symFlw[s][p], g.symFlw[s][prefInt[i]]) then
				return
			end
		end

		if pflw then
			pflw.unique = true
		else
			print("UniqueFlw", s, "rule = ", g.symRule[p], "pref = ", table.concat(first.sortset(g.symPref[s][p]), ", "), "flw = ", table.concat(first.sortset(g.symFlw[s][p]), ", "), "nInt = ", #prefInt, "nEq = ", nPrefEq, "pflw = ", pflw)
		end
		return
	end

	-- all prefixes which are not disjoint are a p's prefix subset
	local flw = g.symFlw[s][p]
	for k, _ in pairs(prefEq) do
		if not disjoint(flw, g.symFlw[s][k]) then
			return
		end
	end
	if pflw then
		print("foi true22")
		pflw.unique = true
	end
end


local function isPrefixUnique (g, p, pflw)
	local s = p.p1
	if p.tag == 'char' then
		s = '__' .. s
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		s = p.p1
	elseif p.tag == 'var' and matchUPath(g.prules[p.p1]) and isLastAlternative(g, p, g.symPref[p.p1]) then
		return true 
	--elseif p.tag == 'var' then
		--return isPrefixUniqueVar(g, p.p1)	
		--s = p.p1
	elseif p.tag == 'var' and isPrefUniVar(g, p) then
		return true 
	else
		return false
	end

	local pref = g.symPref[s][p]
	--local flw = g.symFlw[s][p]
	--print(s, " pref := ", table.concat(first.sortset(pref), ", "), " flw := ", table.concat(first.sortset(flw), ", "))

	for k, v in pairs(g.symPref[s]) do
		--print("isUnique", p, k == p)
		if k ~= p then
			if not disjoint(pref, v) and not isLastAlternative(g, p, g.symPref[s]) then
				return false
			end
		end
	end

	return true
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

local function uniquePrefixAux (g, p, pflw)
	if p.tag == 'char' or p.tag == 'var' then
		--assert(not p.unique or (p.unique == true and isPrefixUnique(g, p) == true))
		--if p.p1 == '=' then
		--	print("here __= ", isPrefixUnique(g, p))
		--end
		local res1 = isPrefixUnique(g, p, pflw)
		local res2
		if not res1 then
			res2 = isPrefixUniqueEq(g, p)
		end
		isPrefixUniqueFlw(g, p, pflw)
		--print("preUnique ", res1, "prefUniqueEq", res2)
		p.unique = p.unique or (res1)
		p.uniqueEq = p.uniqueEq or res2
	elseif p.tag == 'con' then
		uniquePrefixAux(g, p.p1, p.p2)
		--local res = isPrefixUnique(g, lastSymCon(p.p1))
		--if res == 'next' then
		--	local x = lastSymCon(p.p1)
		--	print("Nextt", x.tag, x.p1)
		--	setNextUnique(p.p2)
		--end
		uniquePrefixAux(g, p.p2, pflw)
	elseif p.tag == 'ord' then
		uniquePrefixAux(g, p.p1, pflw)
		uniquePrefixAux(g, p.p2, pflw)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		uniquePrefixAux(g, p.p1, pflw)
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
		--if matchUnique(g, g.prules[p.p1]) and #g.varUsage[p.p1] == 1 then
		if matchUPath(g.prules[p.p1]) and #g.varUsage[p.p1] == 1 then
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
		if p.tag == 'star' or p.tag == 'plus' then
			flw = union(calcfirst(g, p.p1), flw)
		end
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
		if not g.loopVar[p.p1] then
			g.loopVar[p.p1] = true
			insideLoop(g, g.prules[p.p1], loop, seq)
		end
	elseif p.tag == 'con' then
		insideLoop(g, p.p1, loop, seq)
		insideLoop(g, p.p2, loop, seq or not parser.matchEmpty(p.p1))
	elseif p.tag == 'ord' then
		insideLoop(g, p.p1, loop, seq)
		insideLoop(g, p.p2, loop, seq)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		insideLoop(g, p.p1, true, false)
	elseif p.tag == 'and' or p.tag == 'not' then
		insideLoop(g, p.p1, loop, seq)
	end

end


local function calcUniquePath (g)
	fst = first.calcFst(g)
	flw = first.calcFlw(g)	
	g.uniqueTk = uniqueTk(g)
	g.uniqueVar = {}
	g.uniqueVar[g.plist[1]] = true
	varUsage(g)
	first.calcTail(g)
	first.calcPrefix(g)
	first.calcLocalFollow(g)
	changeUnique = true
	while changeUnique do
		changeUnique = false
		uniquePrefix(g)
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

	io.write("matchUPath: ")
	for i, v in ipairs(g.plist) do
		if matchUPath(g.prules[v]) then
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
	matchUniqueEq = matchUniqueEq,
}

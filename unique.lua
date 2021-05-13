local parser = require'pegparser.parser'
local first = require'pegparser.first'

local disjoint = first.disjoint
local calck = first.calck
local calcfirst = first.calcfirst
local union = first.union
local getName = first.getName
local isLastAlternativeAux

local changeUnique = false
local fst, flw


-- Assumes concatenation is left associative
local function lastSymCon (p)
	if p.tag == 'con' then
		return p.p2
	else
		return p
	end
end

-- Assumes choice is right associative
local function lastAltChoice (p)
	if p.p2.tag == 'ord' then
		return lastAltChoice(p.p2)
	else
		return p.p2
	end
end



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
	if p.tag == 'char' then
		return p.unique
	elseif p.tag == 'var' then
		return p.unique and not parser.matchEmpty(p)
	elseif p.tag == 'con' then
		return matchUPath(p.p1) or matchUPath(p.p2)
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


local function setLabel (p, flw)
	--print("setLabel", p, p.p1, p.kind, p.unique)
	if p.tag == 'var' and parser.matchEmpty(p) then
		return
	end
	if not p.label then
		changeUnique = true
	end
	p.label = true
	p.flw = flw
end


local function setUnique (p, unique, seq, flw)
	if not unique then
		return
	end
	--print("setUnique", p, p.p1, p.kind, p.unique, 'seq = ', seq)
	if not p.unique then
		changeUnique = true
	end
	p.unique = true
	p.seq = seq
	if unique and seq then
		setLabel(p, flw)
	end
end


local function uniqueTk (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			countTk(g.prules[v], t)
		end
	end

	local cont = {}
	local unique = {}
	for k, v in pairs(t) do
		--print(k, " = ", v)
		unique[k] = (v == 1) or nil
		if not cont[v] then
			cont[v] = 1
		else
			cont[v] = cont[v] + 1
		end
	end
	
	--[=[for i = 1, 10 do
		print("Token ", i, " = ", cont[i])
	end]=]

	unique['SKIP'] = nil 
	--printUnique(unique)
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


local function uniqueUsage (g, p)
	local upath, seq = true, true
	for k, v in pairs(g.varUsage[p.p1]) do
		--print(k, v, v.unique, v.uniqueEq, v.seq)
		upath = upath and (v.unique or v.uniqueEq)
		seq = seq and v.seq
	end
	return { upath = upath, seq = seq }
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


local function notDisjointPref (g, p, s)
	local inter = {}
	local sub = {}
	local pref = g.symPref[getName(p)][p]
	
	--print("notDisjointPref s ", s, g.symPref[s])
	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) then
				inter[k] = true
			end
			if first.issubset(v, pref) then
				sub[k] = true
			end
		end
	end

	return inter, sub
end


local function notDisjointPrefSyn (g, p)
	local inter, sub = notDisjointPref(g, p, getName(p))
	local s = getName(p)

	for k, v in pairs(g.notDisjointFirst[s]) do
		if v == 'token' then
			k = '__' .. k
		end
		local interk, subk = notDisjointPref(g, p, k)
		inter = union(inter, interk)
		sub = union(sub, subk)
	end

	local symfirst = getSymbolsFirst(g, g.prules[p.p1])
	for k, v in pairs(symfirst) do
		inter[k] = nil
		sub[k] = nil
	end

	return inter, sub
end


local function isDisjointLast (g, p, s)
	local pref = g.symPref[getName(p)][p]
	local inter = {}
	for k, v in pairs(g.symPref[s]) do
		if k ~= p then
			if not disjoint(pref, v) then
				inter[k] = true
				print("inter = true", s, p)
			end
		end
	end

	print("isDisjointLast", p, s, next(inter))
	return isLastAlternative(g, p, inter)
end


local function isLastAlternativeAux (p, last, set)
	if p.tag == 'char' or p.tag == 'var' then
		if set[p] then
			return p
		else
			return last
		end
	elseif p.tag == 'ord' then
		last = isLastAlternativeAux(p.p1, last, set)
		return isLastAlternativeAux(p.p2, last, set)
	elseif p.tag == 'con' then
		last = isLastAlternativeAux(p.p1, last, set)
		return isLastAlternativeAux(p.p2, last, set)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		return isLastAlternativeAux(p.p1, last, set)
	else
		return last
	end
end


function isLastAlternative (g, p, t)
	for k, v in pairs(t) do
		if k ~= p and g.symRule[p] ~= g.symRule[k] then
			return false
		end
	end

	local aux = t[p]
	t[p] = true
	local res = isLastAlternativeAux(g.prules[g.symRule[p]], nil, t)
	t[p] = aux
	return res == p
end


local function isPrefixUniqueEq (g, p, inter, sub)
	--[==[local flw = g.symFlw[s][p]
	local flwEq = {}
	local nFlwEq = 0

	for k, _ in pairs(prefEq) do
		if not first.issubset(g.symFlw[s][k], flw) then
			return false
		end
	end]==]

	--[==[if p.previousEq then
		local namePrev = getName(p.previousEq)
		print("previousEq: ", p.p1, ", rule: ", g.symRule[p], ", prev: ", namePrev, p, p.previousEq)
		for k, v in pairs(g.symPref[namePrev][p.previousEq]) do
			io.write(k .. ' ; ')
		end
		io.write('\n')
	end]==]
	for k, _ in pairs(inter) do
		if not sub[k] then
			-- test if 'k' is also preceded by 'previousEq'
			--print("Nao foi sub", k, k.p1, g.symRule[k])
			local t = { [k] = true }
			if not isLastAlternative(g, p, t) then
				return false
			end
		end 
	end
	
	--print("foi uniqueEq", p.p1, g.symRule[p], seq)
	--for k, v in pairs(g.symPref[getName(p)][p]) do
	--		io.write(k .. ' ; ')
	--end
	--io.write('\n')

	if not seq then
		return
	end

	p.uniqueEq = true
	-- TODO: review the following line, it crashes the C parser (annotates rule assignment_operator)
	--p.seq = seq 
	if p.tag == 'var' then
		--print("Mais um: prefixUniqueEq uniqueUsage", p.p1, p)
		g.uniqueVar[p.p1] = uniqueUsage(g, p)
	end
end


-- returns two sets: inter and sub.
-- inter has symbols whose prefixes have elements in commom with p
-- sub has the symbols whose prefixes are a subset of p's prefix
local function getPrefInterSub (g, p)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		return notDisjointPref(g, p, getName(p))
	else
		return notDisjointPrefSyn(g, p)
	end
end


local function isPrefixUnique (g, p)
	local inter, sub = getPrefInterSub(g, p)

	--print("isPrefixUnique", next(inter), next(sub))

	-- prefix is unique
	local unique = next(inter) == nil

	-- prefix is not unique, but appears last
	if not unique then
		unique = isLastAlternative(g, p, inter)
	end

	return unique, isPrefixUniqueEq(g, p, inter, sub)
end


local function isPrefixUniqueFlw (g, p)

	local inter, sub = getPrefInterSub(g, p)

	local s = getName(p)
	local flwInt = {}
	--print("isPrefixUniqueFlw s = ", s, g.symRule[p])
	for k, _ in pairs(inter) do
		if not disjoint(g.symFlw[s][p], g.symFlw[getName(k)][k]) then
			flwInt[k] = true
			--print("colide flw", k.p1, k, g.symRule[k])
		end
	end
	if next(flwInt) ~= nil then
		--print("teve colisao")
	else
		return true
	end

	return isLastAlternative(g, p, flwInt)
end


local function uniquePrefixAux (g, p)
	if p.tag == 'char' or p.tag == 'var' then
		--assert(not p.unique or (p.unique == true and isPrefixUnique(g, p) == true))
		--print("uniquePrefixAux", p.p1, p, isPrefixUnique(g, p))
		setUnique(p, p.unique or isPrefixUnique(g, p))
	elseif p.tag == 'con' then
		uniquePrefixAux(g, p.p1)
		if not p.p2.unique then
			local last = lastSymCon(p.p1)
			if (last.tag == 'char' or  last.tag == 'var') and isPrefixUniqueFlw(g, last) then
				setUnique(p.p2, true)
			end
		end
		uniquePrefixAux(g, p.p2)
	elseif p.tag == 'ord' then
		uniquePrefixAux(g, p.p1)
		uniquePrefixAux(g, p.p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		--uniquePrefixAux(g, p.p1, pflw, true)
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


local function uniquePath (g, p, uPath, flw, seq)
	if p.tag == 'char' then
		setUnique(p, uPath, seq, flw)
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		setUnique(p, uPath, seq, flw)
	elseif p.tag == 'var' and uPath then
		setUnique(p, uPath, seq, flw)
		g.uniqueVar[p.p1] = uniqueUsage(g, p)
	elseif p.tag == 'con' then
		uniquePath(g, p.p1, uPath, calck(g, p.p2, flw), seq)
		uPath = uPath or p.p1.unique
		local p1 = lastSymCon(p.p1)
		if not uPath then
			-- it seems this condition has verty little impact
			if p1.tag == 'var' and not parser.isLexRule(p1.p1) and matchUPath(g.prules[p1.p1]) and isDisjointLast(g, p1, getName(p1)) then
				--print("Vai ser agora", p1.p1, g.symRule[p1])
				uPath = true
				setUnique(p1, uPath, seq, flw)
				setUnique(p.p1, uPath, seq, flw)
			end
		end
		if p1.uniqueEq then
			--print("upathEq", p1.p1)
			p.p2.previousEq = p1
		end
		seq = seq or (p.p1.unique and not parser.matchEmpty(p.p1))
		uniquePath(g, p.p2, uPath, flw, seq)
		uPath = uPath or p.p2.unique
		setUnique(p, uPath, seq, flw)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		uniquePath(g, p.p1, flagDisjoint and uPath, flw, false)
		if seq then
			local p2 = lastAltChoice(p)
			p2.lastAlt = true
		end
		uniquePath(g, p.p2, uPath, flw, p.p2.lastAlt)
		--uniquePath(g, p.p2, uPath, flw, seq and p.p2.tag ~= 'ord')
		setUnique(p, uPath or (p.p1.unique and p.p2.unique), seq, flw)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		if p.tag == 'star' or p.tag == 'plus' then
			--flw = union(calcfirst(g, p.p1), flw)
		end
		uniquePath(g, p.p1, flagDisjoint and uPath, flw, false)
		if p.tag == 'plus' then
			setUnique(p, uPath or p.p1.unique, seq, flw)
		else
			setUnique(p, uPath, seq, flw)
		end
	end
end


local function calcUniquePath (g)
	g.uniqueVar = {}
	for i, v in ipairs(g.plist) do
		g.uniqueVar[v] = {}
	end

	g.uniqueVar[g.plist[1]] = { upath = true, seq = true }

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
	first.calcTail(g)
	first.calcPrefix(g)
	first.calcLocalFollow(g)
	changeUnique = true
	uniquePrefix(g)
	while changeUnique do
		changeUnique = false
		for i, v in ipairs(g.plist) do		
			if not parser.isLexRule(v) then
				uniquePath(g, g.prules[v], g.uniqueVar[v].upath, flw[v], g.uniqueVar[v].seq)
			end
		end
	end
	

	--[==[io.write("Unique vars: ")
	for i, v in ipairs(g.plist) do
		if g.uniqueVar[v].upath then
			io.write(v .. '(' .. tostring(g.uniqueVar[v].upath) .. ';' .. tostring(g.uniqueVar[v].seq) .. ')' .. ', ')
		end
	end
	io.write('\n')

	io.write("matchUPath: ")
	for i, v in ipairs(g.plist) do
		if matchUPath(g.prules[v]) then
			io.write(v .. ', ')
		end
	end
	io.write('\n')]==]

end


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
	matchUnique = matchUnique,
	matchUPath = matchUPath,
	matchUniqueEq = matchUniqueEq,
}

local parser = require'parser'
local first = require'first'
local unique = require'unique'

local newOrd = parser.newOrd
local newThrow = parser.newThrow
local newSeq = parser.newSeq
local newNot = parser.newNot
local newNode = parser.newNode
local newAny = parser.newAny
local newVar = parser.newVar
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local set2choice = first.set2choice
local matchEmpty = parser.matchEmpty
local calck = first.calck
local ierr
local gerr
local flagRecovery
local banned
local visited

-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+

local function adderror (p, flw)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if flagRecovery then
		local pred = newNot(set2choice(flw))
		local seq = newNode('var', 'EatToken')
		gerr[s] = newNode('star', newSeq(pred, seq))
	end
	return newOrd(p, newThrow(s))
end


local function markerror (p, flw)
	p.throw = flw or true
	return p
end


local function makeFailure (f, s)
	return { f = f, s = s }
end


local function banSeq (g, p, notll1, seq)
	if p.tag == 'var' then
		if not g.lex[p.p1] and not first.issubset(notll1, visited[p.p1]) then
			visited[p.p1] = first.union(visited[p.p1], notll1)
			p.ban = true
			print("Bani ", p.p1)
 			if not g.lex[p.p1] and not seq then
				print("Recursive", p.p1, g.prules[p.p1].tag)
				banSeq(g, g.prules[p.p1], first.inter(first.calck(g, p, {}), notll1), seq)
			end
		end
	elseif p.tag == 'ord' then
		banSeq(g, p.p1, notll1, seq)
		banSeq(g, p.p2, notll1, seq)
	elseif p.tag == 'con' then
		if not first.disjoint(notll1, first.calck(g, p, {})) then
			p.ban = true
			banSeq(g, p.p1, notll1, seq)
			banSeq(g, p.p2, notll1, seq or not matchEmpty(p.p1))
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
	 --algorithm works, but it is always supplying 'false' to 'seq' here
		banSeq(g, p.p1, notll1) 
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		banSeq(g, p.p1, notll1, seq)
	elseif p.tag == 'nameCap' then
		banSeq(g, p.p2, notll1, seq)
	end
end


local function notannotateAltSeq (g, p, flw, flag, notll1)
	if p.tag == 'var' then
		if flag and not g.lex[p.p1] then
			print("cheguei aqui notannotate")
			banSeq(g, p, notll1, false)
		end
	elseif p.tag == 'ord' then
		local k = calck(g, p.p2, flw)
		local firstp1 = calcfirst(g, p.p1)
		if not disjoint(firstp1, k) then
			io.write("Not disjoint :")
			local set = first.inter(firstp1, k)
			for k, v in pairs(set) do
				io.write(k .. ", ")
			end
			io.write('\n')
			banSeq(g, p.p1, first.inter(firstp1, k), false)
		else
			notannotateAltSeq(g, p.p1, flw, flag, notll1)
		end
		notannotateAltSeq(g, p.p2, flw, flag, notll1)
	elseif p.tag == 'con' then
		notannotateAltSeq(g, p.p1, calck(g, p.p2, flw), flag, notll1)
		notannotateAltSeq(g, p.p2, flw, flag, notll1)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local firstp1 = calcfirst(g, p.p1)
		if not disjoint(firstp1, flw) then
			banSeq(g, p.p1, first.inter(firstp1, flw), false)
		else
			notannotateAltSeq(g, p.p1, flw, flag, notll1)
		end
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotateAltSeq(g, p.p1, flw, flag, notll1)
	elseif p.tag == 'nameCap' then
		notannotateAltSeq(g, p.p2, flw, flag, notll1)
	end
end



local function notannotate (g, p, flw, flag)
	if p.tag == 'var' then
		if flag and not banned[p.p1] and not g.lex[p.p1] then
			banned[p.p1] = true
		end
	elseif p.tag == 'ord' then
		local k = calck(g, p.p2, flw)
		flag = flag or not disjoint(calcfirst(g, p.p1), k)
		--if p.p1.p1 == 'function_def' and p.p2.p1 == 'decl' then
		--	print("tamos aqui: flag ", flag)
		--end
		notannotate(g, p.p1, flw, flag)
		notannotate(g, p.p2, flw, flag)
	elseif p.tag == 'con' then
		notannotate(g, p.p1, calck(g, p.p2, flw), flag)
		notannotate(g, p.p2, flw, flag)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		flag = flag or not disjoint(calcfirst(g, p.p1), flw)
		notannotate(g, p.p1, flw, flag)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotate(g, p.p1, flw, flag)
	elseif p.tag == 'nameCap' then
		notannotate(g, p.p2, flw, flag)
	end
end


local function getLexRules (g, withSkip)
	local t = {}
	for k, _ in pairs(g.lex) do
		if (k ~= 'SKIP' and k ~= 'SPACE') or ((k == 'SKIP' or k == 'SPACE') and withSkip) then
			t['__' .. k] = true
		end
	end
	return t
end

local function addrecrules (g)
	for j = 1, ierr - 1 do
  	local s = 'Err_' .. string.format("%03d", j)
		g.prules[s] = gerr[s]
		table.insert(g.plist, s)
	end
end

local function labelgrammar_aux (p)
	if p.throw then
		print("adding error ", ierr)
		return adderror(p, p.throw)
	else
		return p
	end
end

local function labelgrammar (g, p)
	if p.tag == 'char' or p.tag == 'var' or p.tag == 'any' then
		return labelgrammar_aux(p)
	elseif p.tag == 'ord' then
		local p1 = labelgrammar(g, p.p1)
		local p2 = labelgrammar(g, p.p2)
		return labelgrammar_aux(newNode(p, p1, p2))
	elseif p.tag == 'con' then
		local p1 = labelgrammar(g, p.p1)
		local p2 = labelgrammar(g, p.p2)
		return newNode(p, p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = labelgrammar(g, p.p1)
		return labelgrammar_aux(newNode(p, p1))
	else
		return p	
	end
end



local function addlab_aux (g, p, seq, flw)
	--if p.ban then
	--	print("addlab_aux ban ", p.p1, p.tag)
	--end
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and not p.ban then
    --return adderror(p, flw)
    return markerror(p, flw)
	elseif p.tag == 'con' and not p.ban then
		local newseq = seq or not matchEmpty(p.p1)
		--return newSeq(addlab_aux(g, p.p1, seq, calck(g, p.p2, flw)), addlab_aux(g, p.p2, newseq, flw))
		return newSeq(addlab_aux(g, p.p1, seq, calck(g, p.p2, flw)), addlab_aux(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    if flagDisjoint then
      p1 = addlab_aux(g, p.p1, false, flw)
    end
		local p2 = addlab_aux(g, p.p2, false, flw)
		if seq and not matchEmpty(p) then
			--return adderror(newOrd(p1, p2), flw)
			return markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw) then
		local newp
    if false then
      local p1 = addlab_aux(g, p.p1, false, flw)
      local s = 'Err_' .. string.format("%03d", ierr) .. '_Flw'
      gerr[s] = set2choice(flw)
      newp = newSeq(newNot(newVar(s)), adderror(p1, flw))
    else
      newp = addlab_aux(g, p.p1, false, flw)
    end
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq then
				--return adderror(newNode('plus', newp), flw)
				return markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function addlab (g, rec, flagBanned)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	flagRecovery = rec
	
	local newg = parser.initgrammar()
	
	banned = {}  -- map with non-terminals that we mut not annotate
	gerr = {}
	ierr = 1

	if flagBanned then
		if flagBanned == 'alt' or flagBanned == 'altseq' then
			visited = {}
			for i, v in ipairs(g.plist) do
				visited[v] = {}
			end
			for i, v in ipairs(g.plist) do
				if not g.lex[v] then
					notannotateAltSeq(g, g.prules[v], flw[v], false, v)
				end
			end
		else
			for i, v in ipairs(g.plist) do
				if not v.lex then
					notannotate(g, g.prules[v], flw[v], false)
				end
			end
		end
	end

	local s = first.sortset(banned)
	io.write("Banned (" .. #s .. "): ")
	for i, v in ipairs(s) do
		io.write(v .. ', ')
	end
	io.write"\n"

	for i, v in ipairs(g.plist) do
		if not g.lex[v] and (not flagBanned or not banned[v]) then
			newg.prules[v] = addlab_aux(g, g.prules[v], false, flw[v])
		else
			newg.prules[v] = g.prules[v]
		end
		newg.plist[i] = v
	end

	if flagRecovery then
		local unpack = unpack or table.unpack
		local t = getLexRules(g)
		for k, v in pairs(g.tokens) do
			t[k] = v
		end
		local p = first.set2choice(t)
		newg.prules['Token'] = p
		table.insert(newg.plist, 'Token')
		

		-- (!FOLLOW(p) eatToken space)*
		-- eatToken  <-  token / (!space .)+
		local tk = newNode('var', 'Token')
		local notspace = newNot(newNode('var', 'SPACE'))
		local eatToken = newOrd(tk, newNode('plus', newSeq(notspace, newAny())))
		newg.prules['EatToken'] = newSeq(eatToken, newNode('var', 'SKIP'))
		table.insert(newg.plist, 'EatToken')

		addrecrules(newg)
	end
		
	return newg
end


local function annotateBan (g, rec, flagBanned)
	local newg = addlab(g, rec, flagBanned)
	for i, v in ipairs(newg.plist) do
		if not g.lex[v] then
			newg.prules[v] = labelgrammar(newg, newg.prules[v])
		else
			newg.prules[v] = newg.prules[v]
		end
		newg.plist[i] = v
	end

	return newg 
end


local function matchUnique (p, tu)
	if p.tag == 'char' then
		return tu[p.p1]
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		return tu[p.p1]
	elseif p.tag == 'con' then
		return matchUnique(p.p1, tu) or matchUnique(p.p2, tu)
	elseif p.tag == 'ord' then
		return matchUnique(p.p1, tu) and matchUnique(p.p2, tu)
	elseif p.tag == 'plus' then
		return matchUnique(p.p1, tu)
	else
		return false
	end
end


local function annotateUniqueAux (g, p, seq, afterU, tu, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and afterU then
    --return adderror(p, nil)
		return markerror(p, nil)
	elseif p.tag == 'con' then
		local p1 = annotateUniqueAux(g, p.p1, seq, afterU, tu, calck(g, p.p2, flw))
		local p2 = annotateUniqueAux(g, p.p2, seq or not matchEmpty(p1), afterU or matchUnique(p.p1, tu), tu, flw)
		return newSeq(p1, p2)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, tu, flw)
		local p2 = annotateUniqueAux(g, p.p2, false, afterU, tu, flw)
		if seq and afterU and not matchEmpty(p) then
			--return adderror(newOrd(p1, p2), nil)
			return markerror(newNode(p, p1, p2), nil)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		local newp = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, tu, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq and afterU then
				--return adderror(newNode('plus', newp), nil)
				return markerror(newNode(p, newp), nil)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
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



local function annotateUnique (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	local tu = unique.uniqueTk(g)
	flagRecovery = false
	ierr = 1
	local newg = parser.initgrammar()
	for i, v in ipairs(g.plist) do
		if not g.lex[v] then
			newg.prules[v] = annotateUniqueAux(g, g.prules[v], false, false, tu, flw[v])
		else
			newg.prules[v] = g.prules[v]
		end
		newg.plist[i] = v
	end

	for i, v in ipairs(g.plist) do
		if not g.lex[v] then
			newg.prules[v] = labelgrammar(newg, newg.prules[v])
		else
			newg.prules[v] = newg.prules[v]
		end
		newg.plist[i] = v
	end

	return newg
end


local function annotateUniqueAlt (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	local tu = unique.uniqueTk(g)
	flagRecovery = false
	ierr = 400
	local newg = parser.initgrammar()
	for i, v in ipairs(g.plist) do
		if not g.lex[v] then
			newg.prules[v] = annotateUniqueAux(g, g.prules[v], false, false, tu, flw[v])
		else
			newg.prules[v] = g.prules[v]
		end
		newg.plist[i] = v
	end

	print("ierr = ", ierr)
	newg.init = g.init
	local galt = addlab(newg, false, 'alt')
	--local galt = newg
	print("ierr = ", ierr)
	ierr = 500
	for i, v in ipairs(galt.plist) do
		if not g.lex[v] then
			galt.prules[v] = labelgrammar(galt, galt.prules[v])
		else
			galt.prules[v] = galt.prules[v]
		end
		galt.plist[i] = v
	end

	return galt
	
end



local function annotateUPathAux (g, p, afterU, flw)
		if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and afterU then
    return adderror(p, nil)
	elseif p.tag == 'con' then
		local p1 = annotateUPathAux(g, p.p1, afterU, calck(g, p.p2, flw))
		local p2 = annotateUPathAux(g, p.p2, afterU or matchUPath(p.p1), flw)
		return newSeq(p1, p2)
	elseif p.tag == 'ord' then
		local p1 = annotateUPathAux(g, p.p1, false, flw)
		local p2 = annotateUPathAux(g, p.p2, false, flw)
		if afterU and not matchEmpty(p) then
			return adderror(newOrd(p1, p2), nil)
		else
      return newOrd(p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw)  then
		local newp = annotateUPathAux(g, p.p1, false, flw)
    if p.tag == 'star' then
			return newNode('star', newp)
		elseif p.tag == 'opt' then
			return newNode('opt', newp)
    else --plus
      if afterU then
				return adderror(newNode('plus', newp), nil)
			else
				return newNode('plus', newp)
			end
		end
	else
		return p
	end
end


local function annotateUPath (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	unique.calcUniquePath(g)
	flagRecovery = false
	ierr = 1
	local newg = parser.initgrammar()
	for i, v in ipairs(g.plist) do
		if not g.lex[v] then
			newg.prules[v] = annotateUPathAux(g, g.prules[v], g.uniqueVar[v], flw[v])
			--newg.prules[v] = annotateUPathAux(g, g.prules[v], false, flw[v])
		else
			newg.prules[v] = g.prules[v]
		end
		newg.plist[i] = v
	end

	return newg
end




return {
	addlab = addlab,
	annotateBan = annotateBan,
	annotateUnique = annotateUnique,
	annotateUniqueAlt = annotateUniqueAlt,
	annotateUPath = annotateUPath,
}

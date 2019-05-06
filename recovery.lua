local parser = require'parser'
local first = require'first'

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
		if first.issubset(notll1, first.calck(g, p, {})) then
			p.ban = true
			banSeq(g, p.p1, notll1, seq)
      -- Versao 1 (parece errada)
			banSeq(g, p.p2, notll1, seq or matchEmpty(p.p1))
      -- Versao 2 (parece a correta)
			--banSeq(g, p.p2, notll1, seq or not matchEmpty(p.p1))
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		banSeq(g, p.p1, notll1, seq)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		banSeq(g, p.p1, notll1, seq)
	elseif p.tag == 'nameCap' then
		banSeq(g, p.p2, notll1, seq)
	end
end


local function notannotateAltSeq (g, p, flw, flag, notll1)
	if p.tag == 'var' then
		if flag and not g.lex[p.p1] then
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


local function ban (g, p, notll1)
	if p.tag == 'var' then
		if not g.lex[p.p1] and not first.issubset(notll1, visited[p.p1]) then
			visited[p.p1] = first.union(visited[p.p1], notll1)
			p.ban = true
			print("Bani ", p.p1)
 			if not g.lex[p.p1] then
				print("Recursive", p.p1, g.prules[p.p1].tag)
				ban(g, g.prules[p.p1], first.inter(first.calck(g, p, {}), notll1))
			end
		end
	elseif p.tag == 'ord' then
		ban(g, p.p1, notll1)
		ban(g, p.p2, notll1)
	elseif p.tag == 'con' then
		--if first.issubset(notll1, first.calck(g, p, {})) then
		if not first.disjoint(notll1, first.calck(g, p, {})) then
			p.ban = true
			ban(g, p.p1, notll1)
			--Versao alt
			--if matchEmpty(p.p1) then
			--	ban(g, p.p2, notll1)
			--end	
			-- Versao alt2
			ban(g, p.p2, notll1)
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		ban(g, p.p1, notll1)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		ban(g, p.p1, notll1)
	elseif p.tag == 'nameCap' then
		ban(g, p.p2, notll1)
	end
end


local function notannotateAlt (g, p, flw, flag, notll1)
	if p.tag == 'var' then
		if flag then
			ban(g, p, notll1)
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
			ban(g, p.p1, first.inter(firstp1, k))
		else
			notannotateAlt(g, p.p1, flw, flag, notll1)
		end
		notannotateAlt(g, p.p2, flw, flag, notll1)
	elseif p.tag == 'con' then
		notannotateAlt(g, p.p1, calck(g, p.p2, flw), flag, notll1)
		notannotateAlt(g, p.p2, flw, flag, notll1)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local firstp1 = calcfirst(g, p.p1)
		if not disjoint(firstp1, flw) then
			ban(g, p.p1, first.inter(firstp1, flw))
		else
			notannotateAlt(g, p.p1, flw, flag, notll1)
		end
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotateAlt(g, p.p1, flw, flag, notll1)
	elseif p.tag == 'nameCap' then
		notannotateAlt(g, p.p2, flw, flag, notll1)
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


local function addlab_aux (g, p, seq, flw)
	--if p.ban then
	--	print("addlab_aux ban ", p.p1, p.tag)
	--end
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and not p.ban then
		--print("adicionei ", p.p1)
    return adderror(p, flw)
	elseif p.tag == 'con' and not p.ban then
		local newseq = seq or not matchEmpty(p.p1)
		return newSeq(addlab_aux(g, p.p1, seq, calck(g, p.p2, flw)), addlab_aux(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    if flagDisjoint then
      p1 = addlab_aux(g, p.p1, false, flw)
    end
		local p2 = addlab_aux(g, p.p2, false, flw)
		if seq and not matchEmpty(p) then
			return adderror(newOrd(p1, p2), flw)	
		else
      return newOrd(p1, p2)
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
    if p.tag == 'star' then
			return newNode('star', newp)
		elseif p.tag == 'opt' then
			return newNode('opt', newp)
    else --plus
      if seq then
				return adderror(newNode('plus', newp), flw)
			else
				return newNode('plus', newp)
			end
		end
	else
		return p
	end
end

local function addrecrules (g)
	for j = 1, ierr - 1 do
  	local s = 'Err_' .. string.format("%03d", j)
		g.prules[s] = gerr[s]
		table.insert(g.plist, s)
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
					if flagBanned == 'alt' then
						notannotateAlt(g, g.prules[v], flw[v], false, v)
					else
						notannotateAltSeq(g, g.prules[v], flw[v], false, v)
					end
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


return {
	addlab = addlab,
}

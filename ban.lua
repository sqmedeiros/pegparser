local parser = require'parser'
local first = require'first'
local unique = require'unique'
local pretty = require'pretty'
local label = require'label'

local newSeq = parser.newSeq
local newNot = parser.newNot
local newNode = parser.newNode
local newVar = parser.newVar
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local matchEmpty = parser.matchEmpty
local calck = first.calck
local banned
local visited


--[==[
local function annotateBan (g, rec, flagBanned)
	banOpt = true
	if true then
		unique.calcUniquePath(g)
	end
	local newg = addlab(g, rec, flagBanned)
	print("Grammar after Ban")
	print(pretty.printg(newg, true, 'ban'), '\n')
	print("End Ban")
	for i, v in ipairs(newg.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = labelgrammar(newg, newg.prules[v])
		else
			newg.prules[v] = newg.prules[v]
		end
		newg.plist[i] = v
	end

	return newg 
end



local function consumeUnique (p)
	if p.unique then
		return true
	elseif p.tag == 'con' then
		return consumeUnique(p.p1) or consumeUnique(p.p2)
	elseif p.tag == 'ord' then
		return consumeUnique(p.p1) and consumeUnique(p.p2)
	elseif p.tag == 'plus' then
		return consumeUnique(p.p1)
	else
		return false
	end
end


local function banSeqAux (g, p, notll1, seq, stopUnq)
	if p.tag == 'var' then
		if not parser.isLexRule(p.p1) and not first.issubset(notll1, visited[p.p1]) then
			visited[p.p1] = first.union(visited[p.p1], notll1)
			p.ban = true
			print("Bani Aux", p.p1)
			print("Recursive Aux", p.p1, g.prules[p.p1].tag)
			banSeqAux(g, g.prules[p.p1], first.inter(first.calck(g, p, {}), notll1), seq, stopUnq)
		end
	elseif p.tag == 'ord' then
		banSeqAux(g, p.p1, notll1, seq, stopUnq)
		banSeqAux(g, p.p2, notll1, seq, stopUnq)
	elseif p.tag == 'con' then
		p.ban = true
		banSeqAux(g, p.p1, notll1, seq, stopUnq)
		print("consumeUnique ", consumeUnique(p.p1))
		if not stopUnq or not consumeUnique(p.p1) then
			banSeqAux(g, p.p2, notll1, seq or not matchEmpty(p.p1), stopUnq)
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
	 --algorithm worked, but it is always supplying 'false' to 'seq' here
		banSeqAux(g, p.p1, notll1, seq, stopUnq)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		banSeqAux(g, p.p1, notll1, seq, stopUnq)
	elseif p.tag == 'nameCap' then
		banSeqAux(g, p.p2, notll1, seq, stopUnq)
	end
end


local function banSeq (g, p, notll1, seq, ban, afterU)
	print('banSeq', p.tag, seq, ban)
	if p.tag == 'char' then
		if ban and not afterU then
			print("Bani ", p.tag, p.p1)
			p.ban = true
		end
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		if ban and not afterU then
			print("Bani ", p.tag, p.p1)
			p.ban = true
		end
	elseif p.tag == 'var' then
 		if ban and not afterU then
      if not p.ban or not first.issubset(notll1, visited[p.p1]) then
				p.ban = true
				visited[p.p1] = first.union(visited[p.p1], notll1)
				--print("Bani ", p.p1)
				print("Recursive", p.p1, g.prules[p.p1].tag, seq)
				banSeq(g, g.prules[p.p1], first.inter(first.calck(g, p, {}), notll1), seq, true, false)
			end
		end
	elseif p.tag == 'ord' then
		if ban then
			p.ban = true
		end
		banSeq(g, p.p1, notll1, seq, ban, false)
		banSeq(g, p.p2, notll1, seq, ban, false)
	elseif p.tag == 'con' then
		--[=[if ban then
			banSeq(g, p.p1, notll1, seq, true)
			banSeq(g, p.p2, notll1, seq, true)
		elseif not seq and not first.disjoint(notll1, first.calck(g, p.p1, {})) then
			banSeq(g, p.p1, notll1, true, true)
			banSeq(g, p.p2, notll1, true, true)
		elseif not seq and matchEmpty(p.p1) and not first.disjoint(notll1, first.calck(g, p.p2, {})) then
			banSeq(g, p.p1, notll1, seq, false)
			banSeq(g, p.p2, notll1, seq, true)
		else --not ban, not seq
			banSeq(g, p.p1, notll1, seq, false)
			banSeq(g, p.p2, notll1, seq or matchEmpty(p.p1), false)
		end]=]
		banSeq(g, p.p1, notll1, seq, true, afterU)
		banSeq(g, p.p2, notll1, seq, true, afterU or consumeUnique(p.p1))
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
	 --algorithm worked, but it was always supplying 'false' to 'seq' here
		if ban and not afterU then p.ban = true end
		banSeq(g, p.p1, notll1, seq, ban, false)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		banSeq(g, p.p1, notll1, seq, ban, afterU)
	elseif p.tag == 'nameCap' then
		banSeq(g, p.p2, notll1, seq, ban, afterU)
	end
end


local function notannotateAltSeq (g, p, flw, stopUnq)
	if p.tag == 'ord' then
		local k = calck(g, p.p2, flw)
		local firstp1 = calcfirst(g, p.p1)
		if not disjoint(firstp1, k) then
			io.write("Not disjoint :")
			local set = first.inter(firstp1, k)
			for k, v in pairs(set) do
				io.write(k .. ", ")
			end
			io.write('\n')
			banSeq(g, p.p1, first.inter(firstp1, k), true, true)
		else
			notannotateAltSeq(g, p.p1, flw, stopUnq)
		end
		notannotateAltSeq(g, p.p2, flw, stopUnq)
	elseif p.tag == 'con' then
		notannotateAltSeq(g, p.p1, calck(g, p.p2, flw), stopUnq)
		notannotateAltSeq(g, p.p2, flw, stopUnq)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local firstp1 = calcfirst(g, p.p1)
		if not disjoint(firstp1, flw) then
			io.write("Not disjoint star: " .. tostring(p.p1.tag) .. ', ' .. tostring(p.p1.p1))
			local set = first.inter(firstp1, flw)
			for k, v in pairs(set) do
				io.write(k .. ", ")
			end
			io.write('\n')
			banSeq(g, p.p1, first.inter(firstp1, flw), true, true) 
		else
			notannotateAltSeq(g, p.p1, flw, stopUnq)
		end
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotateAltSeq(g, p.p1, flw, stopUnq)
	elseif p.tag == 'nameCap' then
		notannotateAltSeq(g, p.p2, flw, stopUnq)
	end
end



local function notannotate (g, p, flw, flag)
	if p.tag == 'var' then
		if flag and not banned[p.p1] and not parser.isLexRule(p.p1) then
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

]==]



-- Deep Algorithm ------------------------------------------------------------


local function deep_ban(g, p, k, flag, memo)
	if p.tag == 'var' then
		if flag and not parser.isLexRule(p.p1) and not (k and disjoint(calcfirst(g,p), k)) then
			banned[p.p1] = true
			if not memo[p.p1] then
				memo[p.p1] = true
				deep_ban(g, g.prules[p.p1], k, true, memo)
			end
		end
	elseif p.tag == 'ord' then
		deep_ban(g, p.p1, k, flag, memo)
		deep_ban(g, p.p2, k, flag, memo)
	elseif p.tag == 'con' then
		flag = flag and not (k and disjoint(calcfirst(g,p), k))
		deep_ban(g, p.p1, nil, flag, memo)
		deep_ban(g, p.p2, nil, flag, memo)
	elseif p.tag == 'star' then
		deep_ban(g, p.p1, k, flag, memo)
	end
end

local function notannotate_deep(g, p, flw, flag, k)
	if p.tag == 'var' then
		if flag and not parser.isLexRule(p.p1) and not (k and disjoint(calcfirst(g,p), k)) then
			banned[p.p1] = true
			deep_ban(g, g.prules[p.p1], k, true, {[p.p1] = true})
		end
	elseif p.tag == 'ord' then
		if flag then
			notannotate_deep(g, p.p1, flw, flag, k)
			notannotate_deep(g, p.p2, flw, flag, k)
		else
			k = calck(g, p.p2, flw)
			--k = first.intersection(calcfirst(g,p.p1), calck(g, p.p2, flw))
			notannotate_deep(g, p.p1, flw, not disjoint(calcfirst(g,p.p1), k), k)
			notannotate_deep(g, p.p2, flw, false)
		end
	elseif p.tag == 'con' then
		flag = flag and not (k and disjoint(calcfirst(g,p.p1), k))
		notannotate_deep(g, p.p1, calck(g, p.p2, flw), flag, k)
		notannotate_deep(g, p.p2, flw, flag)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		flag = flag or not disjoint(calcfirst(g, p.p1), flw)
		notannotate_deep(g, p.p1, flw, flag, k)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotate_deep(g, p.p1, flw, flag, k)
	elseif p.tag == 'nameCap' then
		notannotate_deep(g, p.p2, flw, flag, k)
	end
end




------------------------------------------------------------------------------
local function addlab (g, p, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and not p.ban then
    return label.markerror(p, flw)
	elseif p.tag == 'con' then
		local newseq = seq or not matchEmpty(p.p1)
		--return newSeq(addlab(g, p.p1, seq, calck(g, p.p2, flw)), addlab(g, p.p2, newseq, flw))
		return newNode(p, addlab(g, p.p1, seq, calck(g, p.p2, flw)), addlab(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    if flagDisjoint then
      p1 = addlab(g, p.p1, false, flw)
    end
		local p2 = addlab(g, p.p2, false, flw)
		if seq and not matchEmpty(p) and not p.ban then
			return label.markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw) and not p.ban then
		local newp = addlab(g, p.p1, false, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq then
				return label.markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function ban_aux (g, f, flw)
  for i, v in ipairs(g.plist) do
    if not parser.isLexRule(v) then
      f(g, g.prules[v], flw[v], false)
    end
  end
end


local function ban (g, flagBan)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	local newg = parser.initgrammar(g)
	
	banned = {}  -- map with non-terminals that we mut not annotate
	visited = {}
	for i, v in ipairs(g.plist) do
		visited[v] = {}
	end
		
	if flagBan == 'alt' or flagBan == 'altunique' then
		ban_aux(g, notannotate_deep, flw)
	elseif flagBan == 'deep' then
		ban_aux(g, notannotate_deep, flw)
	else
		error("ban: Invalid flag " .. tostring(flagBan))
	end

	local s = first.sortset(banned)
	io.write("Banned (" .. #s .. "): ")
	for i, v in ipairs(s) do
		io.write(v .. ', ')
	end
	io.write"\n"

	return newg
end


local function annotateBan (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	local newg = parser.initgrammar(g)

	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) and not banned[v] then
			newg.prules[v] = addlab(g, g.prules[v], false, flw[v])
		end
	end

	return newg
end


return {
	ban = ban,
	annotateBan = annotateBan
}

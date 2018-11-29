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
local changedBan

-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+

local function adderror (p, flw)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if flagRecovery then
		local pred = newNot(set2choice(flw))
		local seq = newNode('var', 'eatToken')
		gerr[s] = newNode('star', newSeq(pred, seq))
	end
	return newOrd(p, newThrow(s))
end


local function makeFailure (f, s)
	return { f = f, s = s }
end


local function notannotate (g, p, flw, flag)
	if p.tag == 'var' then
		if flag and not banned[p.p1] then
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


local function notannotateSoft (g, p, flw, flag, v)
  print("soft v tag", v, p.tag, p.p1 ) 
	if p.tag == 'var' then
		if flag and not banned[p.p1] then
			banned[p.p1] = true
			changedBan = true
		end
	elseif p.tag == 'ord' then
		-- TODO: should not ban A in a choice A p1 / A p2 (the benefit of this
		-- extra case seems small)
		if flag then
			notannotateSoft(g, p.p1, flw, true, v)
			notannotateSoft(g, p.p2, flw, true, v)
		else
			local k = calck(g, p.p2, flw)
			local firstp1 = calcfirst(g, p.p1)
			print("soft v disjoint", v, disjoint(calcfirst(g, p.p1), k)) 
			if not disjoint(calcfirst(g, p.p1), k) then
				if not banned[v] and first.issubset(firstp1, k) then
					notannotateSoft(g, p.p1, flw, false, v)
					notannotateSoft(g, p.p2, flw, false, v)
				elseif not banned[v] then
					notannotateSoft(g, p.p1, flw, true, v)
					notannotateSoft(g, p.p2, flw, false, v)
				else
					notannotateSoft(g, p.p1, flw, true, v)
					notannotateSoft(g, p.p2, flw, true, v)
				end
			else
				notannotateSoft(g, p.p1, flw, false, v)
				notannotateSoft(g, p.p2, flw, false, v)
			end
		end
	elseif p.tag == 'con' then
		notannotateSoft(g, p.p1, calck(g, p.p2, flw), flag, v)
		notannotateSoft(g, p.p2, flw, flag, v)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		flag = flag or not disjoint(calcfirst(g, p.p1), flw)
		notannotateSoft(g, p.p1, flw, flag, v)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotateSoft(g, p.p1, flw, flag, v)
	elseif p.tag == 'nameCap' then
		notannotateSoft(g, p.p2, flw, flag, v)
	end
end


local function getTokenRules (g)
	local t = {}
	for k, _ in pairs(g.lex) do
		table.insert(t, newNode('var', k))
	end
	return t
end


local function addlab_aux (g, p, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq then
    return adderror(p, flw)
	elseif p.tag == 'con' then
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
		if flagBanned == 'soft' then
			changedBan = true
			while changedBan do
				changedBan = false
				for i, v in ipairs(g.plist) do
					print("flagBanned", v)
					if not g.lex[v] then
						notannotateSoft(g, g.prules[v], flw[v], false, v)
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
		local t = unpack(getTokenRules(g))
		for k, v in pairs(g.tokens) do
			print("tokens", k)
			table.insert(t, k)
		end
		local p = newOrd(unpack(getTokenRules(g)))
		newg.prules['token'] = p
		table.insert(newg.plist, 'token')
		

		-- (!FOLLOW(p) eatToken space)*
		-- eatToken  <-  token / (!space .)+
		local tk = newNode('var', 'token')
		local notspace = newNot(newNode('var', 'SKIP'))
		local eatToken = newOrd(tk, newNode('plus', newSeq(notspace, newAny())))
		newg.prules['eatToken'] = newSeq(eatToken, newNode('var', 'SKIP'))
		table.insert(newg.plist, 'eatToken')

		addrecrules(newg)
	end
		
	return newg
end


return {
	addlab = addlab,
}

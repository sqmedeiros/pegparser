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
local flagrecovery
local banned

local function adderror (p, flw)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if flagRecovery then
		local pred = newNot(set2choice(flw))
		gerr[s] = newNode('star', newSeq(pred, newAny()))
	end
	return newOrd(p, newThrow(s))
end


local function makeFailure (f, s)
	return { f = f, s = s }
end


local function notannotate (p)
	if p.tag == 'var' then
		if not banned[p.p1] then
			banned[p.p1] = true
			notannotate(p.p1)
		end
	elseif p.tag == 'ord' then
		notannotate(p.p1)
		notannotate(p.p2)
	elseif p.tag == 'con' then
		notannotate(p.p1)
		if matchEmpty(p.p1) then
			notannotate(p.p2)
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		notannotate(p.p1)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		notannotate(p.p1)
	elseif p.tag == 'nameCap' then
		notannotate(p.p2)
	end
end

local function addlab_aux (g, p, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq then
    return adderror(p, flw)
	elseif p.tag == 'con' then
		local newseq = seq or not matchEmpty(p.p1)
		return newSeq(addlab_aux(g, p.p1, seq, calck(g, p.p2, flw)), addlab_aux(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    if flagDisjoint then
      p1 = addlab_aux(g, p.p1, false, flw)
		else
			notannotate(p.p1, false)
    end
		local p2 = addlab_aux(g, p.p2, false, flw)
		if seq and not matchEmpty(p) then
			return adderror(newOrd(p1, p2), flw)	
		else
      return newOrd(p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(p.p1), flw) then
		local newp
    --if seq then
    --if true then
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

local function addrecrules (g, r)
	for j = 1, ierr - 1 do
  	local s = 'Err_' .. string.format("%03d", j)
		g[s] = gerr[s]
		r[#r + 1] = s
	end
end

local function addlab (g, rules, rec, flagBanned)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g, rules[1])	
	flagRecovery = rec

	local newg = {}
	local newrules = {}
	banned = {}  -- map with non-terminals that we mut not annotate
	gerr = {}
	ierr = 1
	for i, v in ipairs(rules) do
		if not flagBanned or not banned[v] then
			newg[v] = addlab_aux(g, g[v], false, flw[v])
		else
			newg[v] = g[v]
		end
		newrules[i] = v
	end

	if flagRecovery then
		addrecrules(newg, newrules)
	end
		
	return newg, newrules
end


return {
	addlab = addlab,
}

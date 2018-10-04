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


local function adderror (p, flw)
  local s = 'Err_' .. string.format("%03d", ierr)
	local pred = newNot(set2choice(flw))
  gerr[s] = newNode('star', newSeq(pred, newAny()))
	ierr = ierr + 1
	return newOrd(p, newThrow(s))
end


local function makeFailure (f, s)
	return { f = f, s = s }
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

local function addlab (g, rules)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g, rules[1])	

	local newg = {}
	local newrules = {}
	gerr = {}
	ierr = 1
	for i, v in ipairs(rules) do
		newg[v] = addlab_aux(g, g[v], false, flw[v])
		newrules[i] = v
	end
	
	addrecrules(newg, newrules)
		
	return newg, newrules
end


return {
	addlab = addlab,
}

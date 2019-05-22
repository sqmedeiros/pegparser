local parser = require'parser'
local first = require'first'
local unique = require'unique'
local pretty = require'pretty'

local newNode = parser.newNode
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local set2choice = first.set2choice
local matchEmpty = parser.matchEmpty
local calck = first.calck
local ierr
local gerr
local flagRecovery

-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+

local function adderror (p, flw)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if flagRecovery then
		local pred = parser.newNot(set2choice(flw))
		local seq = newNode('var', 'EatToken')
		gerr[s] = newNode('star', parser.newSeq(pred, seq))
	end
	return parser.newOrd(p, parser.newThrow(s))
end


local function markerror (p, flw)	
	p.throw = flw or true
	return p
end


local function addrecrules (g)
	for j = 1, ierr - 1 do
  	local s = 'Err_' .. string.format("%03d", j)
		g.prules[s] = gerr[s]
		table.insert(g.plist, s)
	end
end


local function putlabel (p)
	if p.throw and not p.ban then
		print("adding error ", ierr)
		return adderror(p, p.throw)
	else
		return p
	end
end


local function labelexp (g, p)
	if p.tag == 'char' or p.tag == 'var' or p.tag == 'any' then
		return putlabel(p)
	elseif p.tag == 'ord' then
		local p1 = labelexp(g, p.p1)
		local p2 = labelexp(g, p.p2)
		return putlabel(newNode(p, p1, p2))
	elseif p.tag == 'con' then
		local p1 = labelexp(g, p.p1)
		local p2 = labelexp(g, p.p2)
		return newNode(p, p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = labelexp(g, p.p1)
		return putlabel(newNode(p, p1))
	else
		return p	
	end
end


local function labelgrammar (g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			g.prules[v] = labelexp(g, g.prules[v])
		else
			g.prules[v] = g.prules[v]
		end
		g.plist[i] = v
	end

	return g
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
		return markerror(p, nil)
	elseif p.tag == 'con' then
		local p1 = annotateUniqueAux(g, p.p1, seq, afterU, tu, calck(g, p.p2, flw))
		local p2 = annotateUniqueAux(g, p.p2, seq or not matchEmpty(p1), afterU or matchUnique(p.p1, tu), tu, flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, tu, flw)
		local p2 = annotateUniqueAux(g, p.p2, false, afterU, tu, flw)
		if seq and afterU and not matchEmpty(p) then
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
				return markerror(newNode(p, newp), nil)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function annotateUnique (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	local tu = unique.uniqueTk(g)
	flagRecovery = false
	ierr = 1
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUniqueAux(g, g.prules[v], false, false, tu, flw[v])
		end
	end

	return labelgrammar(newg)
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


local function annotateUPathAux (g, p, afterU, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and afterU and seq then
    return markerror(p, nil)
	elseif p.tag == 'con' then
		local p1 = annotateUPathAux(g, p.p1, afterU, seq, calck(g, p.p2, flw))
		seq = seq or not parser.matchEmpty(p.p1) 
		local p2 = annotateUPathAux(g, p.p2, afterU or matchUPath(p.p1), seq, flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
		local p1 = annotateUPathAux(g, p.p1, afterU, false, flw)
		local p2 = annotateUPathAux(g, p.p2, afterU, false, flw)
		if afterU and not matchEmpty(p) and seq then
			return markerror(newNode(p, p1, p2), nil)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw)  then
		local newp = annotateUPathAux(g, p.p1, afterU, false, flw)
    if p.tag == 'star' then
			return newNode('star', newp)
		elseif p.tag == 'opt' then
			return newNode('opt', newp)
    else --plus
      if afterU and seq then
				return markerror(newNode('plus', newp), nil)
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
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUPathAux(g, g.prules[v], g.uniqueVar[v], g.uniqueVar[v] and not g.loopVar[v], flw[v])
			--newg.prules[v] = annotateUPathAux(g, g.prules[v], false, flw[v])
		end
	end

	return labelgrammar(newg)
end



return {
	addlab = addlab,
	annotateBan = annotateBan,
	annotateUnique = annotateUnique,
	annotateUniqueAlt = annotateUniqueAlt,
	annotateUPath = annotateUPath,
}

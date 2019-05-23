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

-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+

local function adderror (g, p, rec)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if rec then
		local pred = parser.newNot(set2choice(p.flw))
		local seq = newNode('var', 'EatToken')
		table.insert(g.plist, s)
		g.prules[s] = newNode('star', parser.newSeq(pred, seq))
	end
	return parser.newOrd(p, parser.newThrow(s))
end


local function markerror (p, flw)	
	p.throw = true
	p.flw = flw
	return p
end


local function putlabel (g, p, rec)
	if p.throw then
		print("adding error ", ierr)
		return adderror(g, p, rec)
	else
		return p
	end
end


local function labelexp (g, p, rec)
	if p.tag == 'char' or p.tag == 'var' or p.tag == 'any' then
		return putlabel(g, p, rec)
	elseif p.tag == 'ord' then
		local p1 = labelexp(g, p.p1, rec)
		local p2 = labelexp(g, p.p2, rec)
		return putlabel(g, newNode(p, p1, p2), rec)
	elseif p.tag == 'con' then
		local p1 = labelexp(g, p.p1, rec)
		local p2 = labelexp(g, p.p2, rec)
		return newNode(p, p1, p2, rec)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = labelexp(g, p.p1, rec)
		return putlabel(g, newNode(p, p1), rec)
	else
		return p	
	end
end


local function getLexRules (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if parser.isLexRule(v) and v ~= 'SKIP' and v ~= 'SPACE' then
			t['__' .. v] = true
		end
	end
	return t
end


local function addTkRule (g)
	local t = getLexRules(g)
	-- add literal tokens to t
	for k, v in pairs(g.tokens) do
		t[k] = v
	end
	local p = first.set2choice(t)
	g.prules['Token'] = p
	table.insert(g.plist, 'Token')
end


local function addEatTkRule (g)
	-- (!FOLLOW(p) eatToken space)*
	-- eatToken  <-  token / (!space .)+
	local newSeq = parser.newSeq
	local any = parser.newAny()
	local tk = newNode('var', 'Token')
	local notspace = parser.newNot(newNode('var', 'SPACE'))
	local eatToken = parser.newOrd(tk, newNode('plus', newSeq(notspace, any)))
	g.prules['EatToken'] = newSeq(eatToken, newNode('var', 'SKIP'))
	table.insert(g.plist, 'EatToken')
end


local function labelgrammar (g, rec)
	if rec then
		addTkRule(g)
		addEatTkRule(g)
	end

	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			g.prules[v] = labelexp(g, g.prules[v], rec)
		else
			g.prules[v] = g.prules[v]
		end
		g.plist[i] = v
	end

	return g
end


local function matchUnique (g, p)
	if p.tag == 'char' then
		return g.unique[p.p1]
	elseif p.tag == 'var' and parser.isLexRule(p.p1) then
		return g.unique[p.p1]
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


local function annotateUniqueAux (g, p, seq, afterU, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and afterU then
		return markerror(p, flw)
	elseif p.tag == 'con' then
		local p1 = annotateUniqueAux(g, p.p1, seq, afterU, calck(g, p.p2, flw))
		local p2 = annotateUniqueAux(g, p.p2, seq or not matchEmpty(p.p1), afterU or matchUnique(g, p.p1), flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, flw)
		local p2 = annotateUniqueAux(g, p.p2, false, afterU, flw)
		if seq and afterU and not matchEmpty(p) then
			return markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		local newp = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq and afterU then
				return markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function annotateUnique (g, rec)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	g.unique = unique.uniqueTk(g)
	ierr = 1
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUniqueAux(g, g.prules[v], false, false, flw[v])
		end
	end

	return labelgrammar(newg, rec)
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


local function annotateUPathAux (g, p, seq, afterU, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and afterU and seq then
    return markerror(p, flw)
	elseif p.tag == 'con' then
		local p1 = annotateUPathAux(g, p.p1, seq, afterU, calck(g, p.p2, flw))
		seq = seq or not parser.matchEmpty(p.p1) 
		local p2 = annotateUPathAux(g, p.p2, seq, afterU or matchUPath(p.p1), flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
		local p1 = annotateUPathAux(g, p.p1, false, afterU, flw)
		local p2 = annotateUPathAux(g, p.p2, false, afterU, flw)
		if afterU and not matchEmpty(p) and seq then
			return markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw)  then
		local newp = annotateUPathAux(g, p.p1, false, afterU, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if afterU and seq then
				return markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function annotateUPath (g, rec)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)	
	unique.calcUniquePath(g)
	ierr = 1
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUPathAux(g, g.prules[v], g.uniqueVar[v] and not g.loopVar[v], g.uniqueVar[v], flw[v])
			--newg.prules[v] = annotateUPathAux(g, g.prules[v], false, flw[v])
		end
	end

	return labelgrammar(newg, rec)
end


return {
	annotateUnique = annotateUnique,
	annotateUPath = annotateUPath,
}

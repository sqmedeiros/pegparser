local parser = require'parser'
local first = require'first'
local unique = require'unique'
local pretty = require'pretty'
local label = require'label'
local ban = require'ban'

local newNode = parser.newNode
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local matchEmpty = parser.matchEmpty
local calck = first.calck
local labelgrammar = label.labelgrammar


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
		return label.markerror(p, flw)
	elseif p.tag == 'con' then
		local p1 = annotateUniqueAux(g, p.p1, seq, afterU, calck(g, p.p2, flw))
		local p2 = annotateUniqueAux(g, p.p2, seq or not matchEmpty(p.p1), afterU or matchUnique(g, p.p1), flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, flw)
		local p2 = annotateUniqueAux(g, p.p2, false, afterU, flw)
		if seq and afterU and not matchEmpty(p) then
			return label.markerror(newNode(p, p1, p2), flw)
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
				return label.markerror(newNode(p, newp), flw)
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
	g.unique = unique.uniqueTk(g)
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUniqueAux(g, g.prules[v], false, false, flw[v])
		end
	end

	return newg
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
    return label.markerror(p, flw)
	elseif p.tag == 'con' then
		local p1 = annotateUPathAux(g, p.p1, seq, afterU, calck(g, p.p2, flw))
		seq = seq or not parser.matchEmpty(p.p1) 
		local p2 = annotateUPathAux(g, p.p2, seq, afterU or matchUPath(p.p1), flw)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
		local p1 = annotateUPathAux(g, p.p1, false, afterU, flw)
		local p2 = annotateUPathAux(g, p.p2, false, afterU, flw)
		if afterU and not matchEmpty(p) and seq then
			return label.markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	--elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw)  then
		--local newp = annotateUPathAux(g, p.p1, false, afterU, flw)
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		local newp = annotateUPathAux(g, p.p1, false, flagDisjoint and afterU, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if afterU and seq then
				return label.markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
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
	local newg = parser.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = annotateUPathAux(g, g.prules[v], g.uniqueVar[v] and not g.loopVar[v], g.uniqueVar[v], flw[v])
			--newg.prules[v] = annotateUPathAux(g, g.prules[v], false, flw[v])
		end
	end

	return newg
end


local function putlabels (g, f, rec)
	if f == 'unique' then
		return labelgrammar(annotateUnique(g), rec)
	elseif f == 'upath' then
		return labelgrammar(annotateUPath(g), rec)
	elseif f == 'deep' then
		local newg = ban.ban(g, f)
		return labelgrammar(ban.annotateBan(newg), rec)
	elseif f == 'deepupath' then
		local newg = ban.annotateBan(ban.ban(g, 'deep'))
		return labelgrammar(annotateUPath(g), rec)
	else  -- regular
		return labelgrammar(ban.annotateBan(g), rec)
	end	
end



return {
	putlabels = putlabels,
}

local parser = require'pegparser.parser'
local first = require'pegparser.first'
local unique = require'pegparser.unique'
local pretty = require'pegparser.pretty'
local label = require'pegparser.label'
local ban = require'pegparser.ban'


local newNode = parser.newNode
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local matchEmpty = parser.matchEmpty
local calck = first.calck
local labelgrammar = label.labelgrammar
local matchUnique = unique.matchUnique
local matchUPath = unique.matchUPath
local matchUniqueEq = unique.matchUniqueEq
local union = first.union
local calcfirst = first.calcfirst

local function annotateUniqueAux (g, p, seq, afterU, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and afterU then
		return label.markerror(p, flw)
	elseif ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and p.uniqueEq then
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
		--local newp = annotateUniqueAux(g, p.p1, false, flagDisjoint and afterU, flw)
		if p.tag == 'star' or p.tag == 'plus' then
			flw = union(calcfirst(g, p.p1), flw)
		end
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


local function annotateUPathAux (g, p, seq, afterU, flw, afterUEq)
	--print("UPathAux", p.tag, p.p1, seq, afterU, afterUEq)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and afterU and seq then
    return label.markerror(p, flw)
	elseif ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and afterUEq and seq and p.uniqueEq then
		print("addEq", p.p1, p.throw, g.symRule[p])
		return label.markerror(p, flw)
	elseif p.tag == 'con' then
		--print("con", p.p1.tag, p.p2.tag, matchUniqueEq(p.p1))
		local p1 = annotateUPathAux(g, p.p1, seq, afterU, calck(g, p.p2, flw), afterUEq)
		seq = seq or not parser.matchEmpty(p.p1)
		local p2 = annotateUPathAux(g, p.p2, seq, afterU or matchUPath(p.p1), flw, matchUniqueEq(p.p1))
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = annotateUPathAux(g, p.p1, false, afterU and flagDisjont, flw, afterUEq and flagDisjoint)
		local p2 = annotateUPathAux(g, p.p2, false, afterU, flw, afterUEq)
		if afterU and not matchEmpty(p) and seq then
			return label.markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	--elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw)  then
		--local newp = annotateUPathAux(g, p.p1, false, afterU, flw)
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then
		local flagDisjoint = disjoint(calcfirst(g, p.p1), flw)
		--local newp = annotateUPathAux(g, p.p1, false, flagDisjoint and afterU, flw)
		if p.tag == 'star' or p.tag == 'plus' then
			flw = union(calcfirst(g, p.p1), flw)
		end
		local newp = annotateUPathAux(g, p.p1, false, afterU and flagDisjoint, flw, afterUEq and flagDisjoint)
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


local function addlabAll (g, p, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and not p.ban then
    return label.markerror(p, flw)
	elseif p.tag == 'con' then
		local newseq = seq or not matchEmpty(p.p1)
		--return newSeq(addlab(g, p.p1, seq, calck(g, p.p2, flw)), addlab(g, p.p2, newseq, flw))
		return newNode(p, addlabAll(g, p.p1, seq, calck(g, p.p2, flw)), addlabAll(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    --if flagDisjoint then
      p1 = addlabAll(g, p.p1, false, flw)
    --end
		local p2 = addlabAll(g, p.p2, false, flw)
		if seq and not matchEmpty(p) and not p.ban then
			return label.markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then  --and disjoint(calcfirst(g, p.p1), flw) then
		--local newp = addlabAll(g, p.p1, false, flw)
		if p.tag == 'star' or p.tag == 'plus' then
			flw = union(calcfirst(g, p.p1), flw)
		end
		local newp = addlabAll(g, p.p1, false, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq and not p.ban then
				return label.markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function annotateAll (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	local newg = parser.initgrammar(g)

	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			newg.prules[v] = addlabAll(g, g.prules[v], false, flw[v])
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
		ban.ban(g, f)
		return labelgrammar(ban.annotateBan(g), rec)
	elseif f == 'deepupath' then
		ban.ban(g, 'deep')
		local newg = ban.annotateBan(g)
		return labelgrammar(annotateUPath(newg), rec) --tanto faz passar 'g' ou 'newg' (normalizar uso de funções que alteram ou não 'g')
	elseif f == 'upathdeep' then
		local newg = annotateUPath(g)
		ban.ban(newg, 'upathdeep')
		newg = ban.annotateBan(newg)
		return labelgrammar(newg, rec)
	elseif f == 'all' then  -- regular
		return labelgrammar(annotateAll(g), rec)
	else  -- regular
		return labelgrammar(ban.annotateBan(g), rec)
	end	
end



return {
	putlabels = putlabels,
}

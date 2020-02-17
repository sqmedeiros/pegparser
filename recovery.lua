local parser = require'pegparser.parser'
local first = require'pegparser.first'
local unique = require'pegparser.unique'
local label = require'pegparser.label'


local newNode = parser.newNode
local labelgrammar = label.labelgrammar


local function annotateUPathAux (g, p)
	if (p.tag == 'var' or p.tag == 'char' or p.tag == 'any') and p.label then
    return label.markerror(p, p.flw)
	elseif p.tag == 'con' then
		local p1 = annotateUPathAux(g, p.p1)
		local p2 = annotateUPathAux(g, p.p2)
		return newNode(p, p1, p2)
	elseif p.tag == 'ord' then
		local p1 = annotateUPathAux(g, p.p1)
		local p2 = annotateUPathAux(g, p.p2)
		local newp = newNode(p, p1, p2)
		if p.label then
			newp = label.markerror(newp, p.flw)
		end
		return newp
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') then
		local newp = annotateUPathAux(g, p.p1)
		if p.label then
			return label.markerror(newNode(p, newp), p.flw)
		else
			return newNode(p, newp)
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
			newg.prules[v] = annotateUPathAux(g, g.prules[v])
		end
	end

	return newg
end

local function putlabels (g, f, rec)
	if f == 'upath' then
		return labelgrammar(annotateUPath(g), rec)
	else
		assert(false, tostring(f))
	end	
end



return {
	putlabels = putlabels,
}

local defs = require'pegparser.defs'
local first = require'pegparser.first'
local recovery = require'pegparser.recovery'
local parser = require'pegparser.parser'
local pretty = require'pegparser.pretty'

local function getPeg (g, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' then
		return newNode(p, p.p1, p.p2)
	elseif p.tag == 'ord' then
		if p.disjoint then
			return newNode(p, getPeg(g, p.p1, flw, rule), getPeg(g, p.p2, flw, rule))
		else
			print("Non-ll(1) choice", pretty.printp(p))
			return newNode(p, getPeg(g, p.p1, flw, rule), getPeg(g, p.p2, flw, rule))
		end
	elseif p.tag == 'con' then
		local p1 = getPeg(g, p.p1, calck(g, p.p2, flw, rule), rule)
		local p2 = getPeg(g, p.p2, flw), rule)
		return newNode(p, p1, p2))
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local first1 = calcfirst(g, p.p1)
		--local flwRep = union(calcfirst(g, p.p1), flw, true)
		local flwRep = flw
		
		if p.disjoint then
			return newNode(p, getPeg(g, p.p1, flw, rule)
		else
			print("Non-ll(1) repetition", pretty.printp(p))
			return newNode(p, getPeg(g, p.p1, flw, rule)
		end
	else
		assert(false)
	end
end


local function convertGrammar (g)
	local peg = defs.initgrammar(g)
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			peg[v] = getPeg(g, g.prules[v], g.FOLLOW[v], v)		
		end
  end
end

return {
	convertGrammar = convertGrammar,
}

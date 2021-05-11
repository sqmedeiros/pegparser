local first = require'pegparser.first'
local recovery = require'pegparser.recovery'
local parser = require'pegparser.parser'
local pretty = require'pegparser.pretty'
local unique = require'pegparser.unique'

local calck = first.calck
local calcfirst = first.calcfirst
local newNode = parser.newNode

local function getPeg (g, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' or p.tag == 'any' then
		return newNode(p, p.p1, p.p2)
	elseif p.tag == 'ord' then
		if p.disjoint then
			return newNode(p, getPeg(g, p.p1, flw, rule), getPeg(g, p.p2, flw, rule))
		else
			print("Non-ll(1) choice", pretty.printp(p))
			if unique.matchUPath(p.p1) then
				print("Alternative 1 match unique", pretty.printp(p.p1))
				return newNode(p, getPeg(g, p.p1, flw, rule), getPeg(g, p.p2, flw, rule))
			end
			if unique.matchUPath(p.p2) then
			  print("Alternative 2 match unique", pretty.printp(p.p2))
			  return newNode(p, getPeg(g, p.p2, flw, rule), getPeg(g, p.p1, flw, rule))
			end
			return newNode(p, getPeg(g, p.p1, flw, rule), getPeg(g, p.p2, flw, rule))
		end
	elseif p.tag == 'con' then
		local p1 = getPeg(g, p.p1, calck(g, p.p2, flw, rule), rule)
		local p2 = getPeg(g, p.p2, flw, rule)
		return newNode(p, p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local first1 = calcfirst(g, p.p1)
		--local flwRep = union(calcfirst(g, p.p1), flw, true)
		local flwRep = flw
		
		if p.disjoint then
			return newNode(p, getPeg(g, p.p1, flw, rule))
		else
			print("Non-ll(1) repetition", pretty.printp(p))
			if unique.matchUPath(p.p1) then
			  print("Repetition match unique", pretty.printp(p.p1))
			  return newNode(p, getPeg(g, p.p1, flw, rule))  
			end
			return newNode(p, getPeg(g, p.p1, flw, rule))
		end
	elseif p.tag == 'not' then
		return newNode(p, getPeg(g, p.p1, flw, rule))	
	else
		assert(false, p.tag .. ': ' .. pretty.printp(p))
	end
end


local function convert (g)
	local peg = parser.initgrammar(g)
	unique.calcUniquePath(g)
  --print(pretty.printg(gupath, true), '\n')
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			peg[v] = getPeg(g, g.prules[v], g.FOLLOW[v], v)		
		end
  end
  return peg
end

return {
	convert = convert,
}

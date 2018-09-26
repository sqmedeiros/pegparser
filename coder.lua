local coder = {}

local function coder.makeexp (p)
	if p.tag == 'empty' then
		return lpeg.P""
	elseif p.tag == 'char' then
		return lpeg.P(p.p1)
	elseif p.tag == 'set' then
		return lpeg.S(p.p1)
	elseif p.tag == 'any' then
		return lpeg.P(1)
	elseif p.tag == 'posCap' then
		return m.Cp()
	elseif p.tag == 'simpCap' then
		return m.C(coder.makeexp(p.p1))
	elseif p.tag == 'tabCap' then
		return m.Ct(coder.makeexp(p.p1))
	elseif p.tag == 'var' then
		return lpeg.V(p.p1)
	elseif p.tag == 'ord' then
		return coder.makeexp(p.p1) + makeexp(p.p2)
	elseif p.tag == 'con' then
		return coder.makeexp(p.p1) * makeexp(p.p2)
	elseif p.tag == 'and' then
		return #coder.makeexp(p.p1)
	elseif p.tag == 'not' then
		return -coder.makeexp(p.p1)
	elseif p.tag == 'opt' then
		return coder.makeexp(p.p1)^-1
	elseif p.tag == 'star' then
		return coder.makeexp(p.p1)^0
	elseif p.tag == 'plus' then
		return coder.makeexp(p.p1)^1
	elseif p.tag == 'throw' then
		return m.T(p.p1)
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function coder.makepeg (p)
	
end


return coder

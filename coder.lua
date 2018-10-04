local m = require'lpeglabel'
local re = require'relabel'

local function makep (p)
	if p.tag == 'empty' then
		return m.P""
	elseif p.tag == 'char' then
		return m.P(p.p1)
	elseif p.tag == 'set' then
		return re.compile(p.p1)
	elseif p.tag == 'any' then
		return m.P(1)
	elseif p.tag == 'posCap' then
		return m.Cp()
	elseif p.tag == 'simpCap' then
		return m.C(makep(p.p1))
	elseif p.tag == 'tabCap' then
		return m.Ct(makep(p.p1))
	elseif p.tag == 'nameCap' then
		return m.Cg(makep(p.p1), makep(p.p2))
	elseif p.tag == 'anonCap' then
		return m.Cg(makep(p.p1))
	elseif p.tag == 'var' then
		return m.V(p.p1)
	elseif p.tag == 'ord' then
		return makep(p.p1) + makep(p.p2)
	elseif p.tag == 'con' then
		return makep(p.p1) * makep(p.p2)
	elseif p.tag == 'and' then
		return #makep(p.p1)
	elseif p.tag == 'not' then
		return -makep(p.p1)
	elseif p.tag == 'opt' then
		return makep(p.p1)^-1
	elseif p.tag == 'star' then
		return makep(p.p1)^0
	elseif p.tag == 'plus' then
		return makep(p.p1)^1
	elseif p.tag == 'throw' then
		return m.T(p.p1)
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function makeg (g, s)
	local peg = { [1] = s }
	for k, v in pairs(g) do
		peg[k] = makep(v)
	end
	return m.P(peg)
end


return {
	makep = makep,
	makeg = makeg
}

local m = require'lpeglabel'
local parser = require 'parser'

local predef = {}
m.locale(predef)
local sp = predef.space^0

local function unfoldset (l)
	local set = {}
	for i, v in ipairs(l) do
		if #v == 3 then
			local x = string.byte(v:sub(1, 1))
			local y = string.byte(v:sub(3, 3))
			for i = x, y do
				set[#set + 1] = string.char(i)
			end
		else
			set[#set + 1] = v
		end
	end
	return table.concat(set)
end

local function makep (p)
	if p.tag == 'empty' then
		return m.P""
	elseif p.tag == 'char' then
		return m.P(p.p1)
	elseif p.tag == 'set' then
		return m.S(unfoldset(p.p1))
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


local function matchskip (p)
	return parser.newSeq(p, parser.newVar('skip'))
end

local function autoskip (p, g)
	if p.tag == 'empty' or p.tag == 'char' or p.tag == 'set' or
     p.tag == 'any' then
		return matchskip(p)
	elseif p.tag == 'posCap' then
		return p
	elseif p.tag == 'simpCap' then
		return matchskip(p)  --TODO: see if this is ok
	elseif p.tag == 'tabCap' then
		return matchskip(p)
	elseif p.tag == 'nameCap' then
		return matchskip(p)
	elseif p.tag == 'anonCap' then
		return matchskip(p)
	elseif p.tag == 'var' then
		if p.p1 ~= 'skip' and g[p.p1].lex then
			return matchskip(p)
		else
			return p
		end
	elseif p.tag == 'ord' or p.tag == 'con' then
		return parser.newNode(p.tag, autoskip(p.p1, g), autoskip(p.p2, g))
	elseif p.tag == 'and' or p.tag == 'not' or p.tag == 'opt' or
         p.tag == 'star' or p.tag == 'plus' then
		return parser.newNode(p.tag, autoskip(p.p1, g))
	elseif p.tag == 'throw' then
		return p
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function makeg (g, r)
	local peg = { [1] = r[1].name }
	for i, v in ipairs(r) do
		if v.name ~= 'skip' then
			local p = g[v.name]
			if not p.lex then
				p = autoskip(p, g)
			end
			peg[v.name] = makep(p)
		else
			peg[v.name] = makep(g[v.name])
		end
	end
	return m.P(peg)
end


return {
	makep = makep,
	makeg = makeg
}

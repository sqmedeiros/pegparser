local m = require'lpeglabel'
local parser = require'pegparser.parser'
local pretty = require'pegparser.pretty'
local predef = require'pegparser.predef'
local ast = require'pegparser.ast'

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
	elseif p.tag == 'def' then
		return predef[p.p1]
	elseif p.tag == 'set' then
		return m.S(unfoldset(p.p1))
	elseif p.tag == 'any' then
		return m.P(1)
	elseif p.tag == 'constCap' then
		return m.Cc(p.p1)
	elseif p.tag == 'posCap' then
		return m.Cp()
	elseif p.tag == 'simpCap' then
		return m.C(makep(p.p1))
	elseif p.tag == 'tabCap' then
		return m.Ct(makep(p.p1))
	elseif p.tag == 'nameCap' then
		return m.Cg(makep(p.p2), p.p1)
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


local function isLetter (s) --'for'
	return (s >= 'a' and s <= 'z') or (s >= 'A' and s <= 'Z')
end

local function matchskip (p)
	if p.tag == 'char' and isLetter(string.sub(p.p1, 1)) then
		--local aux = parser.newClass('a-z', 'A-Z', '0-9')
		local aux = parser.newClass{'a-z', 'A-Z', '0-9'}
		aux = parser.newNot(aux)
		aux = parser.newSeq(parser.newSeq(p, aux), parser.newVar('SKIP'))
		--print(pretty.printp(aux))
		return aux
	else
		return parser.newSeq(p, parser.newVar('SKIP'))
	end
end

local function autoskip (p, g)
	if p.tag == 'empty' or p.tag == 'char' or p.tag == 'set' or
     p.tag == 'any' then
		return matchskip(p)
	elseif p.tag == 'def' then
		return p
	elseif p.tag == 'constCap' then
		return p
	elseif p.tag == 'posCap' then
		return p
	elseif p.tag == 'simpCap' then
		return matchskip(p)  --TODO: see if this is ok
	elseif p.tag == 'tabCap' then
		return parser.newNode(p.tag, autoskip(p.p1, g))
	elseif p.tag == 'nameCap' then
		return parser.newNode(p.tag, p.p1, autoskip(p.p2, g))
	elseif p.tag == 'anonCap' then
		return matchskip(p)
	elseif p.tag == 'var' then
		if p.p1 ~= 'SKIP' and p.p1 ~= 'SPACE' and parser.isLexRule(p.p1) then
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


local function makeg (g, tree)
	local g = g
	if tree then
		g = ast.buildAST(g)
		--print("Coder: New grammar with annotations to build AST")
		--print(pretty.printg(g), '\n')
	end
	local peg = { [1] = g.plist[1] }
	for i, v in ipairs(g.plist) do
		if v ~= 'SKIP' and v ~= 'SPACE' and v ~= 'COMMENT' then
			local p = g.prules[v]
			if not parser.isLexRule(v) then
				p = autoskip(p, g)
				if v == g.plist[1] then
					p = parser.newSeq(parser.newVar('SKIP'), p)
				end
			end
			peg[v] = makep(p)
		else
			peg[v] = makep(g.prules[v])
		end
	end
	return m.P(peg)
end


return {
	makep = makep,
	makeg = makeg
}

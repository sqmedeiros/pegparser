local Coder = {}
Coder.__index = Coder

local M = require'lpeglabel'
local Node = require'pegparser.node'
local Predef = require'pegparser.predef'
--local Ast = require'pegparser.ast'
local Grammar = require'pegparser.grammar'

local sp = Predef.space^0
local lpegG = {}


function Coder.unfoldset (l)
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


function Coder.makep (p)
	assert(p)
	local tag = p.tag
	
	if p.tag == "empty" then
		return M.P""
	elseif p.tag == "char" then
		local v = p:unquote()
		if v == "'\\t'" then
			return M.P'\t'
		elseif v == "'\\r'" then
			return M.P'\r'
		elseif v == "'\\n'" then
			return M.P'\n'
		else
			return M.P(v)
		end
	elseif tag == 'def' then
		return Predef[p.v]
	elseif tag == 'set' then
		return M.S(Coder.unfoldset(p.v))
	elseif tag == 'any' then
		return M.P(1)
	elseif tag == 'constCap' then
		return M.Cc(p.v)
	elseif tag == 'posCap' then
		return M.Cp()
	elseif tag == 'simpCap' then
		return M.C(makep(p.v))
	elseif tag == 'tabCap' then
		return M.Ct(Coder.makep(p.v))
	elseif tag == 'namedCap' then
		return M.Cg(Coder.makep(p.v[2]), p.v[1])
	elseif tag == 'anonCap' then
		return M.Cg(Coder.makep(p.v))
	elseif tag == 'funCap' then
		return Coder.makep(p.v) / function () return end
	elseif tag == 'var' then
		return M.V(p.v)
	elseif tag == 'choice' then
		local res = Coder.makep(p.v[1])
		for i = 2, #p.v do
			res = res + Coder.makep(p.v[i])
		end
		return res
	elseif tag == 'con' then
		local res = Coder.makep(p.v[1])
		for i = 2, #p.v do
			res = res * Coder.makep(p.v[i])
		end
		return res
	elseif tag == 'and' then
		return #Coder.makep(p.v)
	elseif tag == 'not' then
		return -Coder.makep(p.v)
	elseif tag == 'opt' then
		return Coder.makep(p.v)^-1
	elseif tag == 'star' then
		return Coder.makep(p.v)^0
	elseif tag == 'plus' then
		return Coder.makep(p.v)^1
	elseif tag == 'throw' then
		return M.T(p.v)
	else
		error("Unknown tag: " .. tag)
	end
end


function Coder.isLetter (s)
	return (s >= 'a' and s <= 'z') or (s >= 'A' and s <= 'Z')
end

function Coder.matchskip (p)
	--if p.tag == 'char' and Coder.isLetter(string.sub(p.v, 2)) then
	--	print("here", p.v, string.sub(p.v, 2))
    --local notLetterDigit = Node.nott(Node.set('a-z', 'A-Z', '0-9'))
    --return Node.con{p, notLetterDigit, Node.var"SKIP"}
    --return p
	--else
		return Node.con{p, Node.var"SKIP"}
	--end
end

function Coder.autoskip (p, g)
	assert(p.tag)
	if p.tag == 'empty' or p.tag == 'char' or p.tag == 'set' or
     p.tag == 'any' then
		return Coder.matchskip(p)
	elseif p.tag == 'def' then
		return p
	elseif p.tag == 'constCap' then
		return p
	elseif p.tag == 'posCap' then
		return p
	elseif p.tag == 'simpCap' then
		return Coder.matchskip(p)  --TODO: see if this is ok
	elseif p.tag == 'tabCap' then
		return Node.tabCap(Coder.autoskip(p.v, g))
	elseif p.tag == 'namedCap' then
		return Node.namedCap(p.v[1], Coder.autoskip(p.v[2], g))
	elseif p.tag == 'anonCap' then
		return Coder.matchskip(p)
	elseif p.tag == 'var' then
		if Grammar.isLexRule(p.v) then
			return Coder.matchskip(p)
		else
			return p
		end
	elseif p.tag == 'choice' or p.tag == 'con' then
		local expList = {}
		for _, iExp in ipairs(p.v) do
			table.insert(expList, Coder.autoskip(iExp, g))
		end
		return Node.new(p.tag, expList)
	elseif p.tag == 'and' or p.tag == 'not' or p.tag == 'opt' or
         p.tag == 'star' or p.tag == 'plus' then
		return Node.new(p.tag, Coder.autoskip(p.v, g))
	elseif p.tag == 'throw' then
		return p
	else
		error("Unknown tag: " .. p.tag)
	end
end


function Coder.setSkip (g)
	local space = Node.set{' ','\t','\n','\v','\f','\r'}
	if g:hasRule("COMMENT") then
		space =	Node.choice{space, Node.var"COMMENT"}
	end

	local varSpace = 'SPACE'
	if g:hasRule(varSpace) then
		space = Node.choice{space, g:getRHS(varSpace) }
	end
	lpegG[varSpace] = Coder.makep(space)

	local skip = Node.star(space)
	local varSkip = 'SKIP'
	lpegG[varSkip] = Coder.makep(skip)
end


function Coder.setEOF (g, s)
	s = s or 'EOF'
	assert(g:hasRule(s) == false, "Grammar already has rule " .. tostring(s))
	lpegG[s] = Coder.makep(Node.nott(Node.any()))
end


function Coder.makeg (g, tree)
	local g = g
	--if tree then
	--	g = Ast.buildAST(g)
	--end
	
	lpegG = { [1] = g:getStartRule() }
		
	for i, var in ipairs(g:getVars()) do
		local p = g:getRHS(var)
		if not g.isLexRule(var) then
			p = Coder.autoskip(p, g)
			if var == g:getStartRule() then
				p = Node.con{Node.var"SKIP", p}
			end
		end
 		lpegG[var] = Coder.makep(p)
	end
	
	Coder.setSkip(g)
	Coder.setEOF(g)
	
	return M.P(lpegG)
end


return Coder

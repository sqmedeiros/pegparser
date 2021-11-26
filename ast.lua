local parser = require 'pegparser.parser'
local pretty = require 'pegparser.pretty'

local newSeq = parser.newSeq
local newNode = parser.newNode
local newSimpCap = parser.newSimpCap
local newTabCap = parser.newTabCap
local newNameCap = parser.newNameCap


local function addCaptures (p, g)
	if p.tag == 'empty' or p.tag == 'char' or p.tag == 'set' or
     p.tag == 'any' then
		return newSimpCap(p)
	elseif p.tag == 'posCap' then
		return p
	elseif p.tag == 'simpCap' then
		return p 
	elseif p.tag == 'tabCap' then
		return p
	elseif p.tag == 'nameCap' then
		return p
	elseif p.tag == 'anonCap' then
		return p
	elseif p.tag == 'var' then
		if p.p1 ~= 'SKIP' and p.p1 ~= 'SPACE' and parser.isLexRule(p.p1) then
			return newSimpCap(p)
		else
			return p
		end
	elseif p.tag == 'ord' or p.tag == 'con' then
		return parser.newNode(p.tag, addCaptures(p.p1, g), addCaptures(p.p2, g))
	elseif p.tag == 'and' or p.tag == 'not' then
		return p
	elseif p.tag == 'opt' or p.tag == 'star' or p.tag == 'plus' then
		return parser.newNode(p.tag, addCaptures(p.p1, g))
	elseif p.tag == 'throw' then
		return p
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function buildAST (g)
	local newg = parser.initgrammar()
	newg.plist = g.plist
	for i, v in ipairs(newg.plist) do
		if not parser.isLexRule(v) then
			local p = addCaptures(g.prules[v], g)
			p = parser.newSeq(newNameCap('rule', parser.newConstCap(v)), p)
			newg.prules[v] = newTabCap(p)
		elseif parser.isErrRule(v) then
			print("isErrRule", v)
			local p = g.prules[v]
			p = parser.newSeq(p, parser.newConstCap('NONE' .. v))
			newg.prules[v] = p
		elseif v == 'EatToken' then
			local p = g.prules[v]
			p = parser.newSeq(p, parser.newDiscardCap())
			newg.prules[v] = p
		else
			newg.prules[v] = g.prules[v]
		end
	end
	return newg
end


local function printAST (t, tab)
	tab = tab or 0
	if type(t) == 'table' then
		if #t == 1 and type(t[1]) == 'table' then
			printAST(t[1], tab)
		else
			--io.write(string.rep(' ', tab))
			io.write(t.rule .. '{')
			--io.write('\n')
			for i, v in ipairs(t) do
				printAST(v, tab + 2)
				io.write(', ') 
			end
			--io.write('\n' .. string.rep(' ', tab))
			io.write('}')
		end
	else
		io.write('"'.. t .. '"')
	end
end


local function getTokens_aux (ast, tabTk)
	if type(ast) == 'table' then
		for i, v in ipairs(ast) do
			getTokens_aux(v, tabTk)
		end
	else
		table.insert(tabTk, ast)
	end
end

local function getTokens (ast)
	local tabTk = {}
	getTokens_aux(ast, tabTk)
	return tabTk
end


return {
	buildAST = buildAST,
	printAST = printAST,
	getTokens = getTokens,
}
	

local first = require'pegparser.first'
local recovery = require'pegparser.recovery'
local parser = require'pegparser.parser'
local pretty = require'pegparser.pretty'
local unique = require'pegparser.unique'

local calck = first.calck
local calcfirst = first.calcfirst
local newNode = parser.newNode
local newSeq = parser.newSeq
local newNot = parser.newNot
local newVar = parser.newVar
local newOrd = parser.newOrd
local newAnd = parser.newAnd
local matchIDBegin = first.matchIDBegin

local KEYWORD = 'KEY__'
local IDBegin = 'IDBegin__'
local IDRest = 'IDRest__'

local irep = 0
local getPeg

local function getRepName ()
  local s = 'rep_' .. string.format("%03d", irep)
	irep = irep + 1
	return s
end

function newNonLL1Rep(g, peg, p, flw, rule)
	assert(p ~= nil)
	print("newNonLL1Rep", pretty.printp(p))
	local p1 = getPeg(g, peg, p.p1, flw, rule)
	local predFlw = parser.newAnd(first.set2choice(flw))

	if p.tag == 'opt' then
		return newOrd(newSeq(p1, predFlw), newNode('empty'))
	elseif p.tag == 'star' or p.tag == 'plus' then
		local s = getRepName()
		table.insert(peg.plist, s)
		local var = newVar(s)
		if p.tag == 'plus' then
			predFlw = newSeq(p1, predFlw)
		end
		peg.prules[s] = newOrd(newSeq(p1, var), predFlw)
		return var
	end
end


function getPeg (g, peg, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' or p.tag == 'any' or p.tag == 'set' then
		return newNode(p, p.p1, p.p2)
	elseif p.tag == 'ord' then
		if p.disjoint or parser.isLexRule(rule) then
			return newNode(p, getPeg(g, peg, p.p1, flw, rule), getPeg(g, peg, p.p2, flw, rule))
		else
			print("Non-ll(1) choice", pretty.printp(p))
			if unique.matchUPath(p.p1) then
				print("Alternative 1 match unique", pretty.printp(p.p1))
				return newNode(p, getPeg(g, peg, p.p1, flw, rule), getPeg(g, peg, p.p2, flw, rule))
			end
			if unique.matchUPath(p.p2) then
			  print("Alternative 2 match unique", pretty.printp(p.p2))
			  return newNode(p, getPeg(g, peg, p.p2, flw, rule), getPeg(g, peg, p.p1, flw, rule))
			end
			--print("rule123", rule)
			return newNode(p, getPeg(g, peg, p.p1, flw, rule), getPeg(g, peg, p.p2, flw, rule))
		end
	elseif p.tag == 'con' then
		local p1 = getPeg(g, peg, p.p1, calck(g, p.p2, flw, rule), rule)
		local p2 = getPeg(g, peg, p.p2, flw, rule)
		return newNode(p, p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local first1 = calcfirst(g, p.p1)
		--local flwRep = union(calcfirst(g, p.p1), flw, true)
		local flwRep = flw
		
		if p.disjoint then
			return newNode(p, getPeg(g, peg, p.p1, flw, rule))
		else
			print("Non-ll(1) repetition", pretty.printp(p))
			if unique.matchUPath(p.p1) then
			  print("Repetition match unique", pretty.printp(p.p1))
			  return newNode(p, getPeg(g, peg, p.p1, flw, rule))
			else
				--return newNode(p, getPeg(g, peg, p.p1, flw, rule))
				local res = newNonLL1Rep(g, peg, p, flw, rule)
				print("nonLL1Rep res", pretty.printp(res))
				return res
			end
		end
	elseif p.tag == 'not' then
		return newNode(p, getPeg(g, peg, p.p1, flw, rule))
	elseif p.tag == 'def' then
		return newNode(p, p.p1, p.p2)
	else
		assert(false, p.tag .. ': ' .. pretty.printp(p))
	end
end

local function markRulesUsedByID (peg, p)
	if p.tag == 'var' then
		peg.usedByID[p.p1] = true
		markRulesUsedByID(peg, peg.prules[p.p1])
	elseif p.tag == 'con' or p.tag == 'ord' then
		markRulesUsedByID(peg, p.p1)
		markRulesUsedByID(peg, p.p2)
	elseif p.tag == 'star' or p.tag == 'rep' or p.tag == 'opt' then
		markRulesUsedByID(peg, p.p1)
	end
end

local function initId (g, peg, ruleId)
	local pIDBegin = g.prules[ruleId].p1
	local pIDRest = g.prules[ruleId].p2
	local fragment = true

	parser.addRuleG(peg, IDBegin, pIDBegin, fragment)
	parser.addRuleG(peg, IDRest, pIDRest, fragmen)
	peg.usedByID = {}
	markRulesUsedByID(peg, peg.prules[ruleId])
end

local function newPredIDRest (p)
	return newSeq(p, newNot(newVar(IDRest)))
end

local function addPredIDRest (p, tkey, rule)
	table.insert(tkey, newVar(rule))
	return newPredIDRest(p)
end

local function collectKwSyn (peg, p, tkey, rule)
	if p.tag == 'char' or p.tag == 'set' then
		if matchIDBegin(p) then
			return addPredIDRest(p, tkey, rule)
		end
	elseif p.tag == 'ord' then
		local p1 = collectKwSyn(peg, p.p1, tkey, rule)
		local p2 = collectKwSyn(peg, p.p2, tkey, rule)
		return newOrd(p1, p2)
	elseif p.tag == 'con' then
		local p1 = collectKwSyn(peg, p.p1, tkey, rule)
		local p2 = collectKwSyn(peg, p.p2, tkey, rule)
		return newSeq(p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = collectKwSyn(peg, p.p1, tkey, rule)
		return newNode(p, p1)
	end
	return p
end

local function collectKwLex (peg, p, tkey, rule)
	if p.tag == 'char' or p.tag == 'set' then
		if matchIDBegin(p) then
			return addPredIDRest(p, tkey, rule)
		end
	elseif p.tag == 'ord' then
		if matchIDBegin(p.p1) or matchIDBegin(p.p2) then
			return addPredIDRest(p, tkey, rule)
		end
	elseif p.tag == 'con' then
		local p1 = p.p1
		while type(p1) == 'table' and (p1.tag ~= 'char' and p1.tag ~= 'set') do
			p1 = p1.p1
		end

		if type(p1) == 'table' and matchIDBegin(p1) then
			return addPredIDRest(p, tkey, rule)
		end
	elseif p.tag == 'plus' and matchIDBegin(p.p1) then
		return addPredIDRest(p, tkey, rule)
	end
	return p
end

local function collectKeywords (g, peg, ruleID, lex)
	local tkey = {}
	for i, v in ipairs(g.plist) do
		if parser.isLexRule(v) and not peg.usedByID[v] then
			peg.prules[v] = collectKwLex(peg, peg.prules[v], tkey, v)
			--print("Rule ", v)
			--io.write(v .. " -> ")
			--io.write(pretty.printp(peg.prules[v]))
			--io.write("\n")
		elseif not parser.isLexRule(v) then
			peg.prules[v] = collectKwSyn(peg, peg.prules[v], tkey, v)
		end
  end

	print("#tkey", #tkey)
	if #tkey > 0 then
		local pKey = tkey[1]
    for i = 2, #tkey do
      pKey = newOrd(pKey, tkey[i])
    end
    parser.addRuleG(peg, KEYWORD, pKey)
    --print(KEYWORD, "<--->", pretty.printp(pKey))

    peg.prules[ruleID] = newSeq(newNot(newVar(KEYWORD)), peg.prules[ruleID])
  end
end

local function convertLexRule (g, peg, ruleID)
	initId(g, peg, ruleID)
	--collectKeywords(g, peg, ruleID)
end

local function convert (g, ruleID)
	local peg = parser.initgrammar(g)
	convertLexRule(g, peg, ruleID)
	unique.calcUniquePath(g)
  --print(pretty.printg(gupath, true), '\n')
  local n = #g.plist
	--for i = 1, n, v in ipairs(g.plist) do
	for i = 1, n do
		local v = g.plist[i]
		if not parser.isLexRule(v) then
		--if v ~= 'SKIP' then
			peg.prules[v] = getPeg(g, peg, g.prules[v], g.FOLLOW[v], v)
		end
  end
  return peg
end

return {
	convert = convert,
}

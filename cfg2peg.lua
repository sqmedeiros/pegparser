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


function tableSwap (t, i, j)
	local aux = t[i]
	t[i] = t[j]
	t[j] = aux
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

--[==[function getLexPeg (g, peg, p, pflw, rule)
	if p.tag == 'var' or p.tag == 'char' or p.tag == 'any' or p.tag == 'set' then
		return newNode(p, p.p1, p.p2)
	elseif p.tag == 'ord' then
		local p1 = getLexPeg(g, peg, p.p1, pflw, rule)
		local p2 = getLexPeg(g, peg, p.p1, pflw, rule)
		return newNode(p, p1, p2)
	end
	elseif p.tag == 'con' then
		local p1 = getLexPeg(g, peg, p.p1, newSeq(p.p2, pflw)), rule)
		local p2 = getLexPeg(g, peg, p.p2, pflw, rule)
		return newNode(p, p1, p2)
	elseif p.tag == 'star' or p.tag == 'plus' then
		return newNode(p, getLexPeg(g, peg, p.p1, pflw, rule))
	elseif p.tag == 'opt' then
		if p.p1.tag == 'opt' or p.p1.tag == 'star' or p.p1.tag == 'plus' then
			local
		else
			return newNode(p, getLexPeg(g, peg, p.p1, pflw, rule))
		end
	elseif p.tag == 'not' then
		return newNode(p, getLexPeg(g, peg, p.p1, pflw, rule))
	elseif p.tag == 'def' then
		return newNode(p, p.p1, p.p2)
	else
		assert(false, p.tag .. ': ' .. pretty.printp(p))
	end
end
--]==]

-- given a list of expressions, generates a left-associateve con
function getConFromList (l)
	local n = #l

	if n == 1 then
		return l[1]
	else
		local p2 = l[n]
		return newSeq(getConFromList(table.pack(table.unpack(l, 1, n - 1))), p2)
	end
end


-- assumes concatenation is left-associative
function getListFromCon (p)
	local t = {}

	local aux = p
	while aux.tag == 'con' do
		table.insert(t, aux.p2)
		aux = aux.p1
	end
	table.insert(t, aux)

	local n = #t
	for i = 1, n/2 do
		tableSwap(t, i, n - i + 1)
	end

	return t
end

function isLazyRep (p)
	return p.tag == 'opt' and
	       (p.p1.tag == 'opt' or p.p1.tag == 'star' or p.p1.tag == 'plus')
end

-- Assumes a few simplifications
-- 1. there is no other transformation related to lexical rules
-- 2. there is no lazy repetition inside another one
function convertLazyRepetition(g, peg, p)
	local t = getListFromCon(p)
	local n = #t

	for i = n, 1, -1 do
		local v = t[i]
		if isLazyRep(v) then
			local newt = table.pack(table.unpack(t, i + 1, n))
			local p = getConFromList(newt)
			t[i] = newNode(v.p1, newSeq(newNot(p), v.p1.p1))
		end
	end

	return getConFromList(t)
end

-- assumes the choice is right-associative
function getChoiceAlternatives (p)
	local t = {}

	local aux = p
	while aux.tag == 'ord' do
		table.insert(t, aux.p1)
		aux = aux.p2
	end
	table.insert(t, aux)

	return t
end


function solveChoiceConflict (g, p1, p2)
	local solved = nil
	if unique.matchUPath(p1) then
		print("Alternative 1 match unique", pretty.printp(p1))
		solved = 1
	end

	if unique.matchUPath(p2) then
		print("Alternative 2 match unique", pretty.printp(p2))
		solved = solved or 2
	end

	local tkPath1 = {}
	first.calcTkPath(g, p1, tkPath1, {})
	io.write("tkpath1: ")
	printktable(tkPath1)

	local tkPath2 = {}
	first.calcTkPath(g, p2, tkPath2, {})
	io.write("tkpath2: ")
	printktable(tkPath2)

	if (matchTkNotInPath(g, p1, tkPath2, {})) then
		print("Alternative 1 match tkpath different, should come first")
		solved = 1
	end

	if (matchTkNotInPath(g, p2, tkPath1, {})) then
		print("Alternative 2 match tkpath different, should come first")
		solved = solved or 2
	end

	return solved
end

function getChoicePeg (g, peg, p, flw, rule)
	local t = getChoiceAlternatives(p)

	local n = #t
	local tDisj = {}
	local conflict = {}
	local newt = {}

	print("Before ordering")
	for i, v in pairs(t) do
		print("Alt " .. i .. ": ", pretty.printp(v))
		conflict[i] = {}
	end

	for i = 1, n -1 do
		local p1 = t[i]
		for j = i + 1, n do
			local p2 = t[j]
			local first1 = calcfirst(g, p1)
			local first2 = calcfirst(g, p2)
			if not first.disjoint(first1, first2) then
				print("p1", pretty.printp(p1))
			  print("p2", pretty.printp(p2))
				print("Conflict ", i, j)
				local solved = solveChoiceConflict(g, p1, p2)
				if solved then
					print("Conflict solved")
				end
			end
		end
	end

	return

	--[===[
	print("Conflicts")
	for i, v in pairs(t) do
		local first1 = calcfirst(g, p1)
		local first2 = calcfirst(g, p2)
		print("p1", pretty.printp(p1))
		print("p2", pretty.printp(p2))
		if not first.disjoint(first1, first2) then
	end


	local last = n
	while last > 1 do
		local j = 1
		while j < last do
			local p1 = t[j]
			local p2 = t[j+1]
			local first1 = calcfirst(g, p1)
			local first2 = calcfirst(g, p2)
			print("p1", pretty.printp(p1))
			print("p2", pretty.printp(p2))
			if not first.disjoint(first1, first2) then
				if unique.matchUPath(p1) then
					print("Alternative 1 match unique", pretty.printp(p1))
				end
			end
			if unique.matchUPath(p.p2) then
			  print("Alternative 2 match unique", pretty.printp(p2))
			  tableSwap(t, j, j + 1)
			end
			local tkPath1 = {}
			first.calcTkPath(g, p1, tkPath1, {})
			io.write("tkpath1: ")
			printktable(tkPath1)

			local tkPath2 = {}
			first.calcTkPath(g, p2, tkPath2, {})
			io.write("tkpath2: ")
			printktable(tkPath2)

			if (matchTkNotInPath(g, p1, tkPath2, {})) then
				print("Alternative 1 match tkpath different, should come first")
			end

			if (matchTkNotInPath(g, p2, tkPath1, {})) then
				print("Alternative 2 match tkpath different, should come first")
				tableSwap(t, j, j + 1)
			end
			j = j + 1
		end
		last = last - 1
	end

	print("After ordering")
	for i, v in pairs(t) do
		print("Alt " .. i .. ": ", pretty.printp(v))
	end
	return t
	]===]

end


function getPeg (g, peg, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' or p.tag == 'any' or p.tag == 'set' then
		return newNode(p, p.p1, p.p2)
	elseif p.tag == 'ord' then
		if p.disjoint or parser.isLexRule(rule) then
			return newNode(p, getPeg(g, peg, p.p1, flw, rule), getPeg(g, peg, p.p2, flw, rule))
		else
			print("Non-ll(1) choice", pretty.printp(p))
			getChoicePeg(g, peg, p, flw, rule)
		end

			--[==[if p.p2.tag == 'ord' then
				local first1 = calcfirst(g, p.p1)
				local first21 = calcfirst(g, p.p2.p1)
				if first.disjoint(first1, first21) then
				  print("tkpath inverter")
					return newNode(p, getPeg(g, peg, p.p2.p1, flw, rule),
					                  getPeg(g, peg, newOrd(p.p1, p.p2.p2), flw, rule))
				end
			end]==]

			--print("rule123", rule)
		return newNode(p, getPeg(g, peg, p.p1, flw, rule), getPeg(g, peg, p.p2, flw, rule))
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
  print(pretty.printg(g, true, 'unique'), '\n')
  local n = #g.plist
	--for i = 1, n, v in ipairs(g.plist) do
	for i = 1, n do
		local v = g.plist[i]
		if not parser.isLexRule(v) then
		--if v ~= 'SKIP' then
			peg.prules[v] = getPeg(g, peg, g.prules[v], g.FOLLOW[v], v)
		elseif v ~= 'SKIP' then
			peg.prules[v] = convertLazyRepetition(g, peg, g.prules[v])
		end
  end
  return peg
end

return {
	convert = convert,
}

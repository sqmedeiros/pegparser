local First = require'first'
local Grammar = require'grammar'
local Pretty = require'pretty'


local Cfg2Peg = {
	KEYWORD = 'KEY__',
	IDBegin = 'IDBegin__',
	IDRest = 'IDRest__',
}

Cfg2Peg.__index = Cfg2Peg

function Cfg2Peg.new(cfg)
	assert(cfg)
	local self = setmetatable({}, Cfg2Peg)
	self.cfg = cfg
	self.first = First.new(cfg)
	self.first:calcFirstG()
	return self
end


local function getRepName ()
  local s = 'rep_' .. string.format("%03d", irep)
	irep = irep + 1
	return s
end


function Cfg2Peg.tableSwap (t, i, j)
	local aux = t[i]
	t[i] = t[j]
	t[j] = aux
end


function Cfg2Peg:newNonLL1Rep(p, flw, rule)
	assert(p ~= nil)
	print("newNonLL1Rep", Pretty.printp(p))
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


function Cfg2Peg.isLazyRep (p)
	return p.tag == 'opt' and
	       (p.v.tag == 'opt' or p.v.tag == 'star' or p.v.tag == 'plus')
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

function Cfg2Peg:getChoicePeg (p, flw, rule)
	local t = getChoiceAlternatives(p)

	local n = #t
	local tDisj = {}
	local conflict = {}
	local newt = {}
	local firstAlt = {}

	print("Before ordering")
	for i, v in pairs(t) do
		print("Alt " .. i .. ": ", Pretty.printp(v))
		conflict[i] = {}
		firstAlt[i] = self.first:calcFirstExp(v)
	end

	for i = 1, n - 1 do
		for j = i + 1, n do
			if not firstAlt[i]:disjoint(firstAlt[j]) then
				print("Alt i", Pretty.printp(t[i]))
				print("Alt j", Pretty.printp(t[j]))
				print("Conflict ", i, j)
				--local solved = solveChoiceConflict(g, p1, p2)
				--if solved then
				--	print("Conflict solved")
				--end
			end
		end
	end

	return
end


function Cfg2Peg:getPeg (p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' or p.tag == 'any' or p.tag == 'set' then
		return p
	elseif p.tag == 'choice' then
		if p.disjoint or Grammar.isLexRule(rule) then
			local t = {}
			for i, v in ipairs(p.v) do
				table.insert(t, self:getPeg(v, flw, rule))
			end
			return Node.choice(t)
		else
			print("Non-ll(1) choice", Pretty.printp(p))
			return self:getChoicePeg(p, flw, rule)
		end
	elseif p.tag == 'con' then
		local t = {}
		local n = #p.v
		for i = n, 1, -1 do
			local iExp = p.v[i]
			t[i] = self:getPeg(iExp, flw, rule)
			flw = self.first:calck(self.g, iExp, flw, rule)
		end
		return Node.con(t)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		if true then
			return p
		end
		local firstV = self.first:calcFistExp(p.v)
		--local flwRep = union(calcfirst(g, p.p1), flw, true)
		local flwRep = flw
		
		if p.disjoint then
			return Node.new(p.tag, self:getPeg(p.v, flw, rule))
		else
			print("Non-ll(1) repetition", pretty.printp(p))
			return Node.new(p.tag, self:getPeg(p.v, flw, rule))
			--[==[if unique.matchUPath(p.p1) then
				print("Repetition match unique", pretty.printp(p.p1))
				return newNode(p, getPeg(g, peg, p.p1, flw, rule))
			else
				--return newNode(p, getPeg(g, peg, p.p1, flw, rule))
				local res = newNonLL1Rep(g, peg, p, flw, rule)
				print("nonLL1Rep res", pretty.printp(res))
				return res
			end]==]
		end
	elseif p.tag == 'not' then
		return p
	elseif p.tag == 'def' then
		return p
	else
		assert(false, p.tag .. ': ' .. Pretty.printp(p))
	end
end

function Cfg2Peg:markRulesUsedByID (peg, p)
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

function Cfg2Peg:initId ()
	local expId = self.cfg:getRHS(self.ruleId)
	local pIDBegin = Node.copy(expId.v[1])
	local pIDRest = Node.copy(expId.v[2]) --TODO: assumes a simple concatenation
	local fragment = true

	self.peg:addRule(IDBegin, pIDBegin, fragment)
	self.peg:addRule(IDRest, pIDRest, fragment)
	self.peg.usedByID = {}
	self:markRulesUsedByID(peg, peg.prules[ruleId])
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


function Cfg2Peg:convertLexRule ()
	self:initId()
	--collectKeywords(g, peg, ruleID)
end


function Cfg2Peg:convert (ruleID)
	self.peg = self.cfg:copy()
	self.irep = 0
	self.ruleId = ruleId or self.ruleId
	self:convertLexRule()

	if true then
		return
	end
	unique.calcUniquePath(g)
	print(pretty.printg(g, true, 'unique'), '\n')
	local n = #g.plist
	
	for i, var in ipairs(grammar:getVars()) do
		local v = self.cfg:getStartRule()
		if not Grammar.isLexRule(v) then
		--if v ~= 'SKIP' then
			peg.prules[v] = getPeg(g, peg, g.prules[v], g.FOLLOW[v], v)
		elseif v ~= 'SKIP' then
			peg.prules[v] = convertLazyRepetition(g, peg, g.prules[v])
		end
  end
  return peg
end

return Cfg2Peg


--return {
--	convert = convert,
--	getChoiceAlternatives = getChoiceAlternatives,
--}

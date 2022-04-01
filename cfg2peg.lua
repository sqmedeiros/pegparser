local First = require'first'
local Grammar = require'grammar'
local Pretty = require'pretty'
local Node = require'node'
local UVerySimple = require"uniqueVerySimple"

local Cfg2Peg = {
	KEYWORD = 'KEY__',
	IdBegin = 'IDBegin__',
	IdRest = 'IDRest__',
}

Cfg2Peg.__index = Cfg2Peg

function Cfg2Peg.new(cfg)
	assert(cfg)
	local self = setmetatable({}, Cfg2Peg)
	self.cfg = cfg
	self.first = First.new(cfg)
	self.first:calcFirstG()
    self.first:calcFollowG()
    self.unique = nil
    self.predUse = false
	return self
end


local function getRepName ()
  local s = 'rep_' .. string.format("%03d", irep)
	irep = irep + 1
	return s
end


function Cfg2Peg:setPredUse (v)
	self.predUse = v
end

function Cfg2Peg.tableSwap (t, i, j)
	local aux = t[i]
	t[i] = t[j]
	t[j] = aux
end


function Cfg2Peg:newNonLL1Rep(p, flw, rule)
	assert(p ~= nil)
	print("newNonLL1Rep", Pretty:printp(p))
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

-- Assumes a few simplifications:
-- 1. there is no other transformation related to lexical rules
-- 2. there is no lazy repetition inside another one
function Cfg2Peg:convertLazyRepetition (p)
    if p.tag == 'choice' then
        for i, v in ipairs(p.v) do
            self:convertLazyRepetition(v)
        end
    elseif p.tag == 'con' then
        local n = #p.v

        for i = n, 1, -1 do
            local iExp = p.v[i]
            if self.isLazyRep(iExp) then
                assert(i ~= n, "Lazy repetition must not be the last expression of a concatenation")
                local tailCon = Node.con{table.unpack(p.v, i + 1, n)}
                local innerRep = iExp.v
                p.v[i].tag = innerRep.tag
                p.v[i].v = Node.con{Node.nott(tailCon), innerRep.v}
            end
        end
    end
end


function Cfg2Peg:isConflictSolved (tabConflict)
    local conflict = false
    io.write("Remaining conflicts: ")
    for i, row in ipairs(tabConflict) do
        for k, _ in pairs(row) do
            if k < i and tabConflict[k][i] then
                io.write("(" .. k .. " , " .. i .. ") ")
                conflict = true
            end
        end
    end

    io.write"\n"
    return not conflict
end


function Cfg2Peg:solveChoiceConflict (p, tConflict)
    local solved = true
    local tNotConflict = {}

    pretty = Pretty.new()
    for i, v in ipairs(tConflict) do
        if next(v) ~= nil then -- alternative has a conflict with other(s)
            local iExp = p.v[i]
            if self.unique:matchUPath(iExp) then  -- conflict solved
                print("Alternative " .. i .. " match unique", pretty:printp(iExp))
                tConflict[i] = {}
                table.insert(tNotConflict, i)
            end
        else  -- no conflict with other alternatives
            table.insert(tNotConflict, i)
        end
    end

    return tConflict, tNotConflict


    --[==[
    
    local solved = nil
	if unique.matchUPath(p1) then
		
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

    ]==]
end


function Cfg2Peg:reordAlternatives (p, tConflict, tNotConflict)
    local listChoice = {}
    for i, v in ipairs(tNotConflict) do
        table.insert(listChoice, p.v[v])
    end

	local n = #p.v
	local pretty = Pretty.new()
    for i, v in ipairs(tConflict) do
        if next(v) ~= nil then -- alternative has a conflict with other(s)
			local tAltPred = {}
            for j = i + 1, #p.v do
                if tConflict[i][j] then
                    table.insert(tAltPred, p.v[j]) 
                end
            end
            
            local newAlt = p.v[i]
            if #tAltPred > 0 then
				local predChoice = Node.nott(Node.choice(tAltPred))
				print("pred", pretty:printp(predChoice))
            	newAlt = Node.con(predChoice, newAlt)
            	
			end
			table.insert(listChoice, newAlt)
        end
    end

	print(#listChoice, p.tag)
    p.v = listChoice
    
    print("heeere", pretty:printp(p))
end


function Cfg2Peg:getChoicePeg (p, flw, rule)
    local t = p.v
	local n = #t
	local tConflict = {}
	local newt = {}
	local firstAlt = {}

	print("Alternativies before ordering")
    local pretty = Pretty.new()
	for i, v in ipairs(p.v) do
		io.write("( " .. i .. ") " .. pretty:printp(v))
        if i < #p.v then io.write(" / ") end
		tConflict[i] = {}
		firstAlt[i] = self.first:calcFirstExp(v)
	end
    io.write"\n"

    local disjoint = true

    io.write("Conflicts: ")
	for i = 1, n - 1 do
		for j = i + 1, n do
			if not firstAlt[i]:disjoint(firstAlt[j]) then
				--print("Alt i", Pretty:printp(t[i]))
				--print("Alt j", Pretty:printp(t[j]))
				io.write("(" .. i .. " , " .. j .. ") ")
                disjoint = false
                tConflict[i][j] = true
                tConflict[j][i] = true
			end
		end
	end
    io.write("\n")

    if not disjoint then
        tConflict, tNotConflict = self:solveChoiceConflict(p, tConflict)
        if self:isConflictSolved(tConflict) then
            print("Solved")
            disjoint = true
        end
        if self.predUse then
			self:reordAlternatives(p, tConflict, tNotConflict)
		end
    end

    return disjoint
end


function Cfg2Peg:getPeg (p, flw, rule)
	if p.tag == 'choice' then
        self:getChoicePeg(p, flw, rule)
	elseif p.tag == 'con' then
		local n = #p.v
		for i = n, 1, -1 do
			self:getPeg(p.v[i], flw, rule)
            flw = self.first:calck(p.v[i], flw)
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		if true then
			return p
		end
		local firstV = self.first:calcFirstExp(p.v)
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
	end
end

function Cfg2Peg:markRulesUsedById (p)
	if p.tag == 'var' then
		self.peg.usedById[p.v] = true
		self:markRulesUsedById(self.peg:getRHS(p.v))
	elseif p.tag == 'con' or p.tag == 'choice' then
        for i, v in ipairs(p.v) do
            self:markRulesUsedById(v)
        end
	elseif p.tag == 'star' or p.tag == 'rep' or p.tag == 'opt' then
		self:markRulesUsedById(p.v)
	end
end

function Cfg2Peg:initId ()
	local expId = self.cfg:getRHS(self.ruleId)
    -- assumes a simple concatenation
    assert(expId.tag == 'con' and #expId.v == 2, "The rule that matches an identifier should be a concenation of two expressions")
	local pIdBegin = Node.copy(expId.v[1])
	local pIdRest = Node.copy(expId.v[2])
	local fragment = true

	self.peg:addRule(self.IdBegin, pIdBegin, fragment)
    self.peg:addRule(self.IdRest, pIdRest, fragment)
	self.peg.usedById = {}
	self:markRulesUsedById(self.peg:getRHS(self.ruleId))
end


local function newPredIdRest (p)
	return newSeq(p, newNot(newVar(self.IdRest)))
end


local function addPredIdRest (p, tkey, rule)
	table.insert(tkey, newVar(rule))
	return newPredIdRest(p)
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


function Cfg2Peg:convertLexRule (ruleId)
    self.ruleId = ruleId or self.ruleId
	self:initId()
	--collectKeywords(g, peg, ruleID)
end


function Cfg2Peg:convert (ruleId)
	self.peg = self.cfg:copy()
	self.irep = 0
    self:convertLexRule(ruleId)

    self.unique = UVerySimple.new(self.peg)
    self.unique:calcUniquePath()
    local pretty = Pretty.new("unique")
    print(pretty:printg(self.peg))
    
	for i, var in ipairs(self.peg:getVars()) do
		if not Grammar.isLexRule(var) then
            self:getPeg(self.peg:getRHS(var), self.first.FOLLOW[var], var)
		else
            self:convertLazyRepetition(self.peg:getRHS(var))
		end
    end

  return self.peg
end

return Cfg2Peg

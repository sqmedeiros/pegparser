local First = require'pegparser.first'
local Grammar = require'pegparser.grammar'
local Pretty = require'pegparser.pretty'
local Node = require'pegparser.node'
local UVerySimple = require"pegparser.uniqueVerySimple"
local Set = require'pegparser.set'

local Cfg2Peg = {
	Keyword = '__Keywords',
	IdBegin = '__IdBegin',
	IdRest = '__IdRest',
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
    self.useUnique = false
    self.usePrefix = false
    self.pretty = Pretty.new()
    self:initConflictStats()
	return self
end


function Cfg2Peg:initConflictStats ()
    self.conflictStats = { unique = 0, prefix = 0, total = 0}
end


function Cfg2Peg:printConflictStats ()
    print("Conflict stats:")
    print("Total #conflicts: ", self.conflictStats.total)
    print("Solved by #unique: ", self.conflictStats.unique)
    print("Solved by #prefix: ", self.conflictStats.prefix)
end


local function getRepName ()
  local s = 'rep_' .. string.format("%03d", irep)
	irep = irep + 1
	return s
end


function Cfg2Peg:setUseUnique (v)
	self.useUnique = v
end


function Cfg2Peg:setUsePrefix (v)
	self.usePrefix = v
end


function Cfg2Peg.tableSwap (t, i, j)
	local aux = t[i]
	t[i] = t[j]
	t[j] = aux
end


function Cfg2Peg:newNonLL1Rep(p, flw, rule)
	assert(p ~= nil)
	print("newNonLL1Rep", self.pretty:printp(p))
	local innerExp = self:getPeg(p.v, flw, rule)
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


function Cfg2Peg:isConflictSolved (mapConflict)
    local conflict = false
    io.write("Remaining conflicts: ")
    for i, row in ipairs(mapConflict) do
        for k, _ in pairs(row) do
            if k < i and mapConflict[k][i] then
                io.write("(" .. k .. " , " .. i .. ") ")
                conflict = true
            end
        end
    end

    io.write"\n"
    return not conflict
end


function Cfg2Peg:calcUniqueAlternatives (p, mapConflict)
    local hasUniqueAlt = false
    
    for i, v in ipairs(p.v) do
		if next(mapConflict[v]) ~= nil then -- alternative has a conflict with other(s)
            if self.useUnique and self.unique:matchUPath(v) then  -- conflict solved
                print("Alternative " .. i .. " match unique", self.pretty:printp(v))
                for _, _ in pairs(mapConflict[v]) do
                    self.conflictStats.unique = self.conflictStats.unique + 1
                end
                mapConflict[v] = {}
				hasUniqueAlt = true
            end
        end
    end
end


function Cfg2Peg:compAlternatives (v, i, j, mapConflict)
	-- if the first alternative does not have a conflict, do not change its order
	if next(mapConflict[v[i]]) == nil then
		return false
	end
	
	-- from now on, we know the first alternative has a conflict
	
	-- if the second alternative does not have a conflict, put it first
	if next(mapConflict[v[j]]) == nil then
		return true
	end
	
	-- from now on, we konw both alternatives have a conflict
    if not self.usePrefix then
        return false
    end

    -- if the first alternative is a prefix of the second one, swap them
	local s1 = self.pretty:printp(v[i])
	local s2 = self.pretty:printp(v[j])
	local start, finish = string.find(s2, s1, 1, true)
    if start == 1 then
        print("Prefix: ", s1, s2, start, finish)
        mapConflict[v[i]][v[j]] = nil
        mapConflict[v[j]][v[i]] = nil
        self.conflictStats.prefix = self.conflictStats.prefix + 1
    end
    return start == 1
end


function Cfg2Peg:swap (t, i, j)
    t[i], t[j] = t[j], t[i]
end


function Cfg2Peg:reordAlternatives (p, mapConflict)
    local n = #p.v
    repeat
		changed = false
		for i = 1, n - 1 do
			if self:compAlternatives(p.v, i, i + 1, mapConflict) then
                self:swap(p.v, i, i + 1)
                changed = true
            end
		end
		n = n - 1
    until changed == false
end


function Cfg2Peg:computeFirstAlternatives (p)
	local firstAlt = {}
	for i, v in ipairs(p.v) do
		firstAlt[i] = self.first:calcFirstExp(v)
	end
    return firstAlt
end


function Cfg2Peg:initConflictData (p)
	assert(p.tag == 'choice')
	local listChoice = {}
    local mapConflict = {}
	for i, v in ipairs(p.v) do
		table.insert(listChoice, v)
		mapConflict[v] = {}
	end
	return listChoice, mapConflict
end


function Cfg2Peg:computeConflicts (p, flw, rule)
    local firstAlt = self:computeFirstAlternatives(p)
	local listChoice, mapConflict = self:initConflictData(p)
	local disjoint = true
	local n = #p.v

	for i = 1, n - 1 do
		for j = i + 1, n do
			if not firstAlt[i]:disjoint(firstAlt[j]) then
			    disjoint = false
                mapConflict[p.v[i]][p.v[j]] = true
                mapConflict[p.v[j]][p.v[i]] = true
                self.conflictStats.total = self.conflictStats.total + 1
			end
		end
	end

	return disjoint, listChoice, mapConflict
end


function Cfg2Peg:getChoicePeg (p, flw, rule)
	local pretty = self.pretty

    local disjoint, listChoice, mapConflict = self:computeConflicts(p, flw, rule)

    if not disjoint then
        print("Conflicting alternatives before ordering")
        print(pretty:printChoiceAlternatives(p))

		print("Conflicts:")
        print(self:printChoiceConflicts(p, listChoice, mapConflict))

		if self.useUnique then
			self:calcUniqueAlternatives(p, mapConflict)
		end

        self:reordAlternatives(p, mapConflict)

		if self:isConflictSolved(mapConflict) then
			print("Solved")
			disjoint = true
		end
    end

    return disjoint
end


function Cfg2Peg:getRepPeg (p, flw, rule)
	local firstRep = self.first:calcFirstExp(p.v)
	local flwRep = self.first:calck(firstRep, flw)
		
	if firstRep:disjoint(flwRep) then
		p.v = self:getPeg(p.v, flw, rule)
		return
	end
	
	print("Non-ll(1) repetition", self.pretty:printp(p))
	
	if self.useUnique and self.unique:matchUPath(p.v) then
		print("Repetition match unique", pretty.printp(p.v))
		p.v = self:getPeg(p.v, flw, rule)	
	else		
		Cfg2Peg:newNonLL1Rep(p, flw, rule)
	end
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
		self:getRepPeg(p, flw, rule)
	end
end


function Cfg2Peg.isIdBegin (ch)
	return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_'
end


function Cfg2Peg.matchIdBegin (p)
	if p.tag == 'char' then
		return Cfg2Peg.isIdBegin(string.sub(p.v, 2, 2))
	elseif p.tag == 'set' then
		for k, v in pairs(p.v) do
			if #v == 1 then
				if Cfg2Peg.isIdBegin(string.sub(v, 2, 2)) then
					return true
				end
			elseif Cfg2Peg.isIdBegin(string.sub(v, 1, 1)) or Cfg2Peg.isIdBegin(string.sub(v, 3, 3)) then
				return true
			end
		end
	end
		
	return false
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
end


function Cfg2Peg:newPredIdRest (p)
	return Node.con(p, Node.nott(Node.var(self.IdRest)))
end


function Cfg2Peg:addPredIdRest (p, setKey, rule)
	setKey:insert(p.v)
	return self:newPredIdRest(p)
end


function Cfg2Peg:collectKwSyn (p, tKey, rule)
	if p.tag == 'char' or p.tag == 'set' then
		if Cfg2Peg.matchIdBegin(p) then
			return self:addPredIdRest(p, tKey, rule)
		end
	elseif p.tag == 'choice' then
		local tChoice = {}
		for i, v in ipairs(p.v) do
			table.insert(tChoice, self:collectKwSyn(v, tKey, rule))
		end
		return Node.choice(tChoice)
	elseif p.tag == 'con' then
		pretty = Pretty.new()
		local newCon = self:collectKwSyn(p.v[1], tKey, rule)
		for i = 2, #p.v do
			local p2 = self:collectKwSyn(p.v[i], tKey, rule)
			newCon = Node.con(newCon, p2)
		end
		return newCon
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = self:collectKwSyn(p.v, tKey, rule)
		return Node.new(p.tag, p1)
	end
	return p
end


function Cfg2Peg:collectKeywords ()
	local setKey = Set.new()
	for i, v in ipairs(self.cfg:getVars()) do
		if not Grammar.isLexRule(v) and v ~= self.ruleId then
			self.peg:updateRule(v, self:collectKwSyn(self.peg:getRHS(v), setKey, v))
		end
	end

	local tKey = setKey:sort()
	local nKey = #tKey
	io.write("#nKey " .. #tKey .. ': ')
	for i, v in ipairs(tKey) do
		io.write(v .. ', ')
	end
	io.write("\n")
	if nKey > 0 then
		local pKey
		if nKey == 1 then
			pKey = Node.char(tKey)
		else
			pKey = {}
			for i, v in ipairs(tKey) do
				table.insert(pKey, Node.char(v))
			end
			pKey = Node.choice(pKey)
		end
			
		
		self.peg:addRule(self.Keyword, pKey)
		
    --print(KEYWORD, "<--->", pretty.printp(pKey))
		local pNotKeyword = Node.nott(Node.var(self.Keyword))
		
		self.peg:updateRule(self.ruleId, Node.con(pNotKeyword, self.peg:getRHS(self.ruleId)))
		
	end
end


function Cfg2Peg:convertLexRule (ruleId)
    self.ruleId = ruleId or self.ruleId
	self:initId()
	self:collectKeywords()
end


function Cfg2Peg:convert (ruleId, checkIdReserved)
	self.peg = self.cfg:copy()
	self.irep = 0
    
    if self.useUnique then
		print("Unique Symbols")
		self.unique = UVerySimple.new(self.peg)
		self.unique:calcUniquePath()
			
		pretty:setProperty('unique')
		print(pretty:printg(self.peg))
		pretty:setProperty(nil)
		print("")
	end
    
    if checkIdReserved then
		self:convertLexRule(ruleId)
	end

    self:initConflictStats()
	for i, var in ipairs(self.peg:getVars()) do
		if not Grammar.isLexRule(var) then
            self:getPeg(self.peg:getRHS(var), self.first.FOLLOW[var], var)
		else
            self:convertLazyRepetition(self.peg:getRHS(var))
		end
    end
    self:printConflictStats()

  return self.peg
end


function Cfg2Peg:printChoiceConflicts (p, listChoice, mapConflict, verbose)
	local n = #p.v
	local t = {}
    local pretty = self.pretty

	for i = 1, n - 1 do
        local p1 = listChoice[i]
		for j = i + 1, n do
            local p2 = listChoice[j]
			if mapConflict[p1][p2] then
				local s = '(' .. i .. ' , ' .. j .. ') '
				table.insert(t, s)
				if verbose then
					s = pretty:printp(p1) .. '  ,  ' .. pretty:printp(p2)
					table.insert(t, s)
				end
			end
		end
	end

    return table.concat(t, ';  ')
end


return Cfg2Peg

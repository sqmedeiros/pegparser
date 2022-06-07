local First = require'pegparser.first'
local Grammar = require'pegparser.grammar'
local Pretty = require'pegparser.pretty'
local Node = require'pegparser.node'
local UVerySimple = require"pegparser.uniqueVerySimple"
local Set = require'pegparser.set'

local Cfg2Peg = {
	Keyword = '__Keywords',
	IdBegin = '__IdBegin',
	IdRest  = '__IdRest',
	RepPrefix = '__rep_',
	ImpLexPrefix = 'ZLex_'
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
    self.repCount = 0
    self.impLex = 0
    self.impMap = {}
    self.pretty = Pretty.new()
    self:initConflictStats()
	return self
end


function Cfg2Peg:initConflictStats ()
    self.conflictStats = { unique = 0, prefix = 0, total = 0}
end


function Cfg2Peg:newRepVar ()
	self.repCount = self.repCount + 1
	return Cfg2Peg.RepPrefix .. string.format("%03d", self.repCount)
end


function Cfg2Peg:printConflictStats ()
    print("Conflict stats:")
    print("Total #conflicts: ", self.conflictStats.total)
    print("Solved by #unique: ", self.conflictStats.unique)
    print("Solved by #prefix: ", self.conflictStats.prefix)
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

-- Rewrites a non-disjoint repetition in the following ways
-- p? ==>  p_rep  (where p_rep is a new rule)
-- p_rep <-  p &flw  /  ''  (only matches p if is possible to match  &flw)
-- p* ==>  p_rep  (where p_rep is a new rule)
-- p_rep <-  p p_rep  /  &flw  (backtracks when is not possible to match  &flw)
-- p+ ==>  p_rep  (where p_rep is a new rule)
-- p_rep <-  p p_rep  /  p &flw  (backtracks when is not possible to match  p &flw)
function Cfg2Peg:newNonDisjointRep(p, flw, rule)
	assert(p.tag == 'opt' or p.tag == 'plus' or p.tag == 'star')
	print("newNonDisjointRep", self.pretty:printp(p))
	local predFlw = Node.andd(self.first.choiceFromSet(flw))
	local innerExp = p.v
	self:getPeg(innerExp, flw, rule)
	--print("innerExp = ", self.pretty:printp(innerExp))

	local p_rep = self:newRepVar()	
	local p_rep_rhs
	if p.tag == 'opt' then
		p_rep_rhs = Node.choice{Node.con{innerExp, predFlw}, Node.empty()}
	else
		if p.tag == 'plus' then
			predFlw = Node.con{innerExp, predFlw}
		end
		p_rep_rhs = Node.choice{Node.con{innerExp, Node.var(p_rep)}, predFlw}
	end
	
	p.tag = 'var'
	p.v = p_rep	
	self.peg:addRule(p_rep, p_rep_rhs)
	self.first.FIRST[p_rep] = self.first:calcFirstExp(p_rep_rhs)
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
    for k, v in pairs(mapConflict) do
        if next(v) ~= nil then
            return false
        end
    end

    return true
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
			local interIJ = firstAlt[i]:inter(firstAlt[j])
			if not interIJ:empty() then
			    disjoint = false
                mapConflict[p.v[i]][p.v[j]] = interIJ
                mapConflict[p.v[j]][p.v[i]] = interIJ
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

        print("Remaining Conflicts:")
        print(self:printChoiceConflicts(p, listChoice, mapConflict))

        if self:isConflictSolved(mapConflict) then
			disjoint = true
		end
    end

    return disjoint
end


function Cfg2Peg:getRepPeg (p, flw, rule)
	assert(p and flw and rule)
	local firstRep = self.first:calcFirstExp(p.v)
	local flwRep = flw
	local interFirstFlw = firstRep:inter(flw)

	if interFirstFlw:empty() then
		self:getPeg(p.v, flw, rule)
		return
	end

	print("Non-ll(1) repetition", self.pretty:printp(p), interFirstFlw:tostring(), firstRep:tostring(), flwRep:tostring(), flw:tostring())

	if self.useUnique and self.unique:matchUPath(p.v) then
		print("Repetition match unique", pretty.printp(p.v))
		self:getPeg(p.v, flw, rule)
	else		
		self:newNonDisjointRep(p, flw, rule)
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
				if Cfg2Peg.isIdBegin(string.sub(v, 1, 1)) then
					return true
				end
			elseif Cfg2Peg.isIdBegin(string.sub(v, 1, 1)) or Cfg2Peg.isIdBegin(string.sub(v, 3, 3)) then
				return true
			end
		end
	elseif p.tag == 'con' then
		return Cfg2Peg.matchIdBegin(p.v[1])
	elseif p.tag == 'choice' then
		for i, v in ipairs(p.v) do
			if Cfg2Peg.matchIdBegin(v) then
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


function Cfg2Peg:addPredIdRest (var, setKey)
	setKey:insert(var)
	return self:newPredIdRest(Node.var(var))
end



--[==[function Cfg2Peg:convertLexRuleByOrder ()
	local setKey = Set.new()
	for i, v in ipairs(self.cfg:getVars()) do
		if self.cfg:isToken(v) then
			print("Tk ", v)
			self.peg:updateRule(v, self:collectKwSyn(self.peg:getRHS(v), setKey, v))
		end
	end

end]==]

function Cfg2Peg:collectKeywords ()
	local setKey = Set.new()
	for i, var in pairs(self.peg:getVars()) do
		local rhs = self.peg:getRHS(var)
		if var ~= self.ruleId and Grammar.isLexRule(var) and not self.cfg.fragmentSet[var] and Cfg2Peg.matchIdBegin(rhs) then
			self:addPredIdRest(var, setKey)
			self.peg:updateRule(var, self:newPredIdRest(rhs))
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
	self:checkImplicitLexRulesG()
	self:collectKeywords()
end


function Cfg2Peg:newImplicitLexVar ()
	self.impLex = self.impLex + 1
	return Cfg2Peg.ImpLexPrefix .. string.format("%03d", self.impLex)
end


function Cfg2Peg:addImplicitLexRule (exp)
	local impVar = self.impMap[exp.v]
	
	if not impVar then
		impVar = self:newImplicitLexVar()
		self.peg:addRule(impVar, Node.copy(exp), false)
		self.impMap[exp.v] = impVar 
	end
	
	exp.tag = 'var'
	exp.v = impVar
end


function Cfg2Peg:checkImplicitLexRulesAux (exp)
	if exp.tag == 'char' then
		self:addImplicitLexRule(exp)
	elseif exp.tag == 'con' or exp.tag == 'choice' then
		for i, iExp in ipairs(exp.v) do
			self:checkImplicitLexRulesAux(iExp)
		end
	elseif exp:isRepetition() then
		self:checkImplicitLexRulesAux(exp.v)
	end
end


function Cfg2Peg:checkImplicitLexRulesG ()
	local listVars = self.peg:getVars()
	local nVars = #listVars
	
	for i = 1, nVars do
		local var = listVars[i]
		if Grammar.isSynRule(var) then
            self:checkImplicitLexRulesAux(self.peg:getRHS(var))
		end
    end
end


function Cfg2Peg:convert (ruleId, checkIdReserved)
	self.peg = self.cfg:copy()
	self.irep = 0
    
    if self.useUnique then
		print("Unique Symbols")
		self.unique = UVerySimple.new(self.peg)
		self.unique:calcUniquePath()
			
		self.pretty:setProperty('unique')
		print(self.pretty:printg(self.peg))
		self.pretty:setProperty(nil)
		print("")
	end
    
    self:initConflictStats()
	for i, var in ipairs(self.peg:getVars()) do
		if Grammar.isSynRule(var) then
            self:getPeg(self.peg:getRHS(var), self.first.FOLLOW[var], var)
		elseif Grammar.isLexRule then
            self:convertLazyRepetition(self.peg:getRHS(var))
		end
    end
    self:printConflictStats()

    if checkIdReserved then
		self:convertLexRule(ruleId)
		--self:convertLexRuleByOrder()
	end


    return self.peg
end


function Cfg2Peg:printChoiceConflicts (p, listChoice, mapConflict, verbose)
	local n = #p.v
	local t = {}
    local pretty = self.pretty
	local none = true

	for i = 1, n - 1 do
        local p1 = listChoice[i]
		for j = i + 1, n do
            local p2 = listChoice[j]
			if mapConflict[p1][p2] and mapConflict[p2][p1] then
				none = false
				local s = '(' .. i .. ' , ' .. j .. '): ' .. mapConflict[p1][p2]:tostring()
				table.insert(t, s)
				if verbose then
					s = pretty:printp(p1) .. '  ,  ' .. pretty:printp(p2)
					table.insert(t, s)
				end
			end
		end
	end

	if none then
		table.insert(t, "None")
	end
    return table.concat(t, '\n')
end


return Cfg2Peg

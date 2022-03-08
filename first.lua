local Set = require"set"
local Pretty = require"pretty"
local Grammar = require"grammar"
local Node = require"node"

local First = { prefixLex  = "___",
								empty      = "__empty",
								any        = "__any" ,
								endInput   = "__$",
								beginInput = "__@",
								prefixKey  = '__' }
First.__index = First

function First.new (grammar)
	local self = {}
	setmetatable(self, First)
	self:setGrammar(grammar)
	return self
end


function First:setGrammar(grammar)
	self.grammar = grammar
	self:initSetFromGrammar("FIRST")
	--self:initSetFromGrammar("LAST")
	self:initSetFromGrammar("FOLLOW")
	--self:initSetFromGrammar("PRECEDE")
	--self:initSetFromGrammar("LEFT")
	--self:initSetFromGrammar("RIGHT")
end


function First:lexKey (var)
	assert(Grammar.isLexRule(var), tostring(var))
	return self.prefixLex .. var
end

function First:initSetFromGrammar (name)
	self[name] = {}
	local tab = self[name]
	for _, var in ipairs(self.grammar:getVars()) do
		tab[var] = Set.new()
	end
end


function First.unfoldset (l)
	local myset = Set.new()
	for i, v in ipairs(l) do
		if #v == 3 then
			local x = string.byte(v:sub(1, 1))
			local y = string.byte(v:sub(3, 3))
			for i = x, y do
				myset:insert(string.char(i))
			end
		else
			myset:insert(v)
		end
	end
	return myset
end


function First:calcFirstG ()
	local update = true
	local grammar = self.grammar
	local FIRST = self.FIRST
	
	while update do
		update = false
		for i, var in ipairs(grammar:getVars()) do
			local exp = grammar:getRHS(var)
			if Grammar.isLexRule(var) then
				exp = Node.var(var)
			end
			local newFirst = self:calcFirstExp(exp)
			if not newFirst:equal(FIRST[var]) then
				update = true
				FIRST[var] = FIRST[var]:union(newFirst)
			end
		end
	end

	return FIRST
end


function First:calcFirstExp (exp)
    if exp.tag == 'empty' then
        return Set.new{ self.empty }
    elseif exp.tag == 'char' then
        return Set.new{ exp:unquote() }
    elseif exp.tag == 'any' then
        return Set.new{ self.any }
    elseif exp.tag == 'set' then
        return self.unfoldset(exp.v)
    elseif exp.tag == 'choice' then
		local firstChoice = Set.new()
		
		for i, v in ipairs(exp.v) do
			firstChoice = firstChoice:union(self:calcFirstExp(v))
		end
		
		return firstChoice
	elseif exp.tag == 'con' then
		local firstSeq = self:calcFirstExp(exp.v[1])
		local i = 2
		
		while firstSeq:getEle(self.empty) == true and i <= #exp.v do
			local firstNext = self:calcFirstExp(exp.v[i])
			firstSeq = firstSeq:union(firstNext)
			if not firstNext:getEle(self.empty) then
				firstSeq:remove(self.empty)
			end
			i = i + 1
		end
		
		return firstSeq
	elseif exp.tag == 'var' then
		if Grammar.isLexRule(exp.v) then
			return Set.new{ self:lexKey(exp.v) }
		end
		return Set.new(self.FIRST[exp.v].tab, 'fromKey')
	elseif exp.tag == 'throw' then
		return Set.new{ self.empty }
	elseif exp.tag == 'and' then
		return Set.new{ self.empty }
	elseif exp.tag == 'not' then
		return Set.new{ self.empty }
  -- in a well-formed PEG, given p*, we know p does not match the empty string
	elseif exp.tag == 'opt' or exp.tag == 'star' then 
		return self:calcFirstExp(exp.v):union(Set.new{self.empty})
  elseif exp.tag == 'plus' then
		return self:calcFirstExp(exp.v)
	else
		print(exp, exp.tag, exp.empty, exp.any)
		error("Unknown tag: " .. exp.tag)
	end
end


function First:calck (exp, k)
	assert(k:getEle(empty) == nil)
	local newK = self:calcFirstExp(exp)
	
	if newK:getEle(self.empty) then
		newK = newK:union(k)
		newK:remove(self.empty)
	end
	return newK
end


function First:calcFollowG ()
	local update = true
	local grammar = self.grammar
	local FOLLOW = self.FOLLOW

	FOLLOW[self.grammar:getStartRule()] = Set.new{ self.endInput }

	while update do
		update = false

		local oldFOLLOW = {}
		for k, v in pairs(FOLLOW) do
			oldFOLLOW[k] = v
		end

		for i, var in ipairs(grammar:getVars()) do
			local exp = grammar:getRHS(var)
			if Grammar.isLexRule(var) then
				exp = Node.var(var)
			end
			self:calcFollowExp(exp, FOLLOW[var])
		end

		for i, var in ipairs(grammar:getVars()) do
			if not FOLLOW[var]:equal(oldFOLLOW[var]) then
				update = true
				break
			end
		end
	end

	return FOLLOW
end


function First:firstWithoutEmpty (set1, set2)
	assert(not set2:getEle(self.empty), set2:tostring() .. ' || ' .. set1:tostring())
	if set1:getEle(self.empty) then
		set1:remove(self.empty)
		return set1:union(set2)
	else
		return set1
	end
end


function First:calcFollowExp (exp, flw)
	if exp.tag == 'empty' or exp.tag == 'char' or exp.tag == 'any' then
		return
	elseif exp.tag == 'var' then
    self.FOLLOW[exp.v] = self.FOLLOW[exp.v]:union(flw)
  elseif exp.tag == 'con' then
		local n = #exp.v
		for i = n, 1, -1 do
			local iExp = exp.v[i]
			self:calcFollowExp(iExp, flw)
			local firstIExp = self:calcFirstExp(iExp)
			flw = self:firstWithoutEmpty(firstIExp, flw)
		end
  elseif exp.tag == 'choice' then
		for i, v in ipairs(exp.v) do
			self:calcFollowExp(v, flw)
		end
  elseif exp.tag == 'star' or exp.tag == 'plus' then
		local firstInnerExp = self:calcFirstExp(exp.v)
		firstInnerExp:remove(self.empty)
		self:calcFollowExp(exp.v, firstInnerExp:union(flw))
  elseif exp.tag == 'opt' then
    self:calcFollowExp(exp.v, flw)
  else
		print(exp, exp.tag, exp.empty, exp.any)
		error("Unknown tag: " .. exp.tag)
	end
end


return First

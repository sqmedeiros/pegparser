local Node = require"pegparser.node"

local Grammar = {
	prefErrRule = "__Err",
}

Grammar.__index = Grammar


function Grammar.new ()
	local self = setmetatable({}, Grammar)
	self.ruleMap = {}
	self.ruleList = {}
	self.tokenSet = {}
	self.startRule = nil
	self:setPreDefRules()
	return self
end


function Grammar:setPreDefRules ()
	self.preDefRules = {
		EOF = Node.nott(Node.any())
	}
end


function Grammar:isPreDefRule (rule)
	return self.preDefRules[rule] ~= nil
end


function Grammar:copy ()
	local copy = Grammar.new()

	for i, var in ipairs(self.ruleList) do
		copy.ruleList[i] = var
		copy.ruleMap[var] = Node.copy(self.ruleMap[var])
	end

	for k, v in pairs(self.tokenSet) do
		copy.tokenSet[k] = v
	end

	copy.startRule = self.startRule
	return copy
end




function Grammar:getRHS (exp)
	local var = Grammar.getVarName(exp, true)
	
	local rhs = self.ruleMap[var]
	assert(rhs ~= nil, "Rule '" .. var .. "' was not defined")
	
	return rhs
end


function Grammar:getRules ()
	return self.ruleMap
end


function Grammar:getVars ()
	return self.ruleList
end


function Grammar.getVarName (exp)
	local var = exp
	if type(exp) == "table" then
		assert(exp.tag == 'var', "Tag was " .. tostring(exp.tag))
		var = exp.v
	end
	assert(type(var) == "string", "Type of 'var' was " .. type(var))
	
	return var
end


function Grammar:setStartRule (var)
	assert(#self.ruleList >= 1, "Grammar does not have rules")
	if not var then
		var = self.ruleList[1]
	else
		var = Grammar.getVarName(var, true)
	end
	self.startRule = var
end


function Grammar:getStartRule ()
	assert(#self.ruleList >= 1, "Grammar does not have rules")
		
	if not self.startRule then
		self.startRule = self.ruleList[1]
	end
	
	return self.startRule
end


function Grammar:addRule (var, rhs, frag)
	assert(not self:hasRule(var))

	table.insert(self.ruleList, var)
	self.ruleMap[var] = rhs

	if Grammar.isLexRule(var) and not frag then
	  self:addToken(var)
	end
end


function Grammar:addNewRep (var, rhs, frag)
	assert(not self:hasRule(var))

	table.insert(self.ruleList, var)
	self.ruleMap[var] = rhs

	if Grammar.isLexRule(var) and not frag then
	  self:addToken(var)
	end
end


function Grammar:updateRule (var, rhs)
	assert(self:hasRule(var))
			
	self.ruleMap[var] = rhs
	return true
end



function Grammar:addToken (tk)
	if self.tokenSet[tk] then
		return false
	end

	self.tokenSet[tk] = true
	return true
end


function Grammar:removeToken (tk)
	if not self.tokenSet[tk] then
		return false
	end

	self.tokenSet[tk] = nil
	return true
end


function Grammar:getTokens (tk)
	return self.tokenSet
end


function Grammar:isToken (tk)
	return self.tokenSet[tk]
end


function Grammar:hasRule (var)
	local var = Grammar.getVarName(var)
	return self.ruleMap[var] ~= nil
end


function Grammar.isLexRule (exp)
	local var = Grammar.getVarName(exp)

	local ch = string.sub(var, 1, 1)
	return ch >= 'A' and ch <= 'Z'
end


function Grammar.isSynRule (exp)
	local var = Grammar.getVarName(exp)

	local ch = string.sub(var, 1, 1)
	return ch >= 'a' and ch <= 'z'
end


function Grammar.isErrRule (exp)
	local var = Grammar.getVarName(exp)
	return string.find(var, Grammar.prefErrRule) ~= nil
end


return Grammar

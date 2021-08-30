local Grammar = {
	prefErrRule = "__Err",
}

Grammar.__index = Grammar


function Grammar.new ()
	local self = setmetatable({}, Grammar)
	self.ruleMap = {}
	self.ruleList = {}
	self.tokenSet = {}
	self.unique = {}
	self.startRule = nil
	return self
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
		assert(exp.tag == 'var')
		var = exp.v
	end
	assert(type(var) == "string", "Type of 'var' was " .. type(var))
	
	return var
end


function Grammar:setStartRule (var)
	var = Grammar.getVarName(var, true)
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
	table.insert(self.ruleList, var)
	self.ruleMap[var] = rhs

	if Grammar.isLexRule(var) and not frag then
	  self:addToken(var)
	end
end


function Grammar:addToken (tk)
	self.tokenSet[tk] = true
end


function Grammar:removeToken (tk)
	self.tokenSet[tk] = nil
end


function Grammar:getTokens (tk)
	return self.tokenSet
end


function Grammar.isLexRule (exp)
	local var = Grammar.getVarName(exp)

	local ch = string.sub(var, 1, 1)
	return ch >= 'A' and ch <= 'Z'
end


function Grammar.isErrRule (exp)
	local var = Grammar.getVarName(exp)
	return string.find(var, Grammar.prefErrRule) ~= nil
end


return Grammar

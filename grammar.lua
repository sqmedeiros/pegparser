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
	assert(exp.tag == 'var')
	return self.ruleMap[exp.v]
end


function Grammar:getRuleMap ()
	return self.ruleMap
end


function Grammar:getRuleList ()
	return self.ruleMap
end


function Grammar:setStartRule (var)
	var = var or self.ruleList[1]
	assert(self.ruleMap[v] ~= nil, "Rule '" .. var .. "' was not defined")
	self.startRule = var	
end


function Grammar:addRule (var, rhs, frag)
	table.insert(self.ruleList, var)
	self.ruleMap[var] = rhs

	if Grammar.isVarLexRule(var) and not frag then
	  self:addToken(var)
	end
end


function Grammar:addToken (tk)
	self.tokenSet[tk] = true
end


function Grammar:removeToken (tk)
	self.tokenSet[tk] = nil
end


function Grammar.isLexRule (exp)
	assert(exp.tag == 'var')
	return Grammar.isVarLexRule(exp.v)
end


function Grammar.isVarLexRule (var)
	local ch = string.sub(var, 1, 1)
	return ch >= 'A' and ch <= 'Z'
end


function Grammar.isErrRule (exp)
	assert(exp.tag == 'var')
	return string.find(exp.v, Grammar.prefErrRule)
end


return Grammar

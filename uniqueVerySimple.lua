local Grammar = require'grammar'

local UniqueVerySimple = { ON    = "on",
                           OFF   = "off" }

UniqueVerySimple.__index = UniqueVerySimple


function UniqueVerySimple.new (grammar)
	local self = { 
		grammar = grammar,
		tkUse = {},
		tkUnique = {},
		varUse = {},
		varUnique = {}
	}
	return setmetatable(self, UniqueVerySimple)
end


function UniqueVerySimple:addTkUse (v)
	if not self.tkUse[v] then
		self.tkUse[v] = 1
	else
		self.tkUse[v] = self.tkUse[v] + 1
	end
end


function UniqueVerySimple:countTkUse (exp)
	if exp.tag == 'char' then
		self:addTkUse(exp.v)
	--elseif exp.tag == 'set' then
	--	for i, v in pairs(p.v) do
	--		updateCountTk(v, t)
	--	end
	elseif exp.tag == 'var' and Grammar.isLexRule(exp.v) then
		self:addTkUse(exp.v)
	elseif exp.tag == 'con' or exp.tag == 'choice' then
		local n = #exp.v
		for i, exp in ipairs(exp.v) do
			self:countTkUse(exp)
		end
	elseif exp.tag == 'star' or exp.tag == 'opt' or exp.tag == 'plus' then
		self:countTkUse(exp.v)
	elseif exp.tag == 'and' or exp.tag == 'not' then
		--does not count tokens inside a predicate
		return
	end
end


function UniqueVerySimple:printUnique ()
	local l = {}
	for k, v in pairs(self.tkUse) do
		table.insert(l, k)
	end
	table.sort(l)
	io.write("Unique tokens (# " .. #l .. "): ")
	io.write(table.concat(l, ', '))
	io.write('\n')
end


function UniqueVerySimple:uniqueTk ()
	local grammar = self.grammar

	for i, var in ipairs(grammar:getVars()) do
		if not Grammar.isLexRule(var) then
			self:countTkUse(grammar:getRHS(var))
		end
	end

	local cont = {}
	for k, v in pairs(self.tkUse) do
		self.tkUnique[k] = (v == 1) or nil
	end

	return self.tkUnique
end


function UniqueVerySimple:addVarUse (exp)
	if not self.varUse[exp.v] then
		self.varUse[exp.v] = {}
	end
	table.insert(self.varUse[exp.v], exp)
end


function UniqueVerySimple:countVarUse (exp)
	local tag = exp.tag
	if tag == 'empty' or tag == 'char' or tag == 'set' or
     tag == 'any' or tag == 'throw' or tag == 'def' then
		return
	elseif tag == 'var' and Grammar.isLexRule(exp.v) then
		return
	elseif tag == 'var' then
		self:addVarUse(exp)
	elseif tag == 'not' or tag == 'and' or tag == 'star' or
         tag == 'opt' or tag == 'plus' then
		self:countVarUse(exp)
	elseif tag == 'con' or tag == 'choice' then
		for i, v in ipairs(exp.v) do
			self:countVarUse(v)
		end
	else
		print(exp)
		error("Unknown tag", exp.tag)
	end

end

local function varUse ()
	for i, var in ipairs(self.grammar:getVars()) do
		if not self.varUse[var] then
			self.varUse[var] = {}
		end
		self:countVarUse(self.grammar:getRHS(var))
	end
end

function UniqueVerySimple:printVarUse ()
	for i, var in ipairs(self.grammar:getVars()) do
		if not Grammar.isLexRule(var) then
			print("Usage", var, self.varUse[var])
		end
	end
end


function UniqueVerySimple:setUnique (exp, unique)
	exp.unique = unique
end


function UniqueVerySimple:setUniqueTk (exp)
	if exp.tag == 'char' or (exp.tag == 'var' and Grammar.isLexRule(exp.v)) then
		self:setUnique(exp, self.tkUnique[exp.v])
	elseif exp.tag == 'choice' or exp.tag == 'con' then
		for i, v in ipairs(exp.v) do
			self:setUniqueTk(v)
		end
	elseif exp.tag == 'star' or exp.tag == 'plus' or exp.tag == 'opt' then
		self:setUniqueTk(exp.v)
	end
end


function UniqueVerySimple:setlabel (exp, upath)
	if upath == UniqueVerySimple.ON and not exp:matchEmpty(self.grammar) then
		exp.label = true
	end
end


function UniqueVerySimple:updateUPath (exp, upath)
	if exp.unique then
		return UniqueVerySimple.ON
	else
		return upath
	end
end


function UniqueVerySimple:uniquePath (exp, upath)
	local tag = exp.tag
	if tag == 'char' or tag == 'var' then
		self:setlabel(exp, upath)
	elseif tag == 'con' then
		for i, v in ipairs(exp.v) do
			self:uniquePath(v, upath)
			upath = self:updateUPath(v, upath)
		end
	elseif tag == 'choice' then
		self:setlabel(exp, upath)
		local n = #exp.v
		for i = 1, n - 1 do
			self:uniquePath(exp.v[i], UniqueVerySimple.OFF)
		end
		self:uniquePath(exp.v[n], UniqueVerySimple.OFF)
	elseif tag == 'star' or tag == 'opt' then
		uniquePath(exp.v, UniqueVerySimple.OFF)
	elseif tag == 'plus' then
		self:setlabel(exp, upath)
		self:uniquePath(exp.v, UniqueVerySimple.OFF)
    else
        assert(false, tostring(exp.tag))
	end
end


function UniqueVerySimple:calcUniquePath (startOn)
	local grammar = self.grammar

	for i, var in ipairs(grammar:getVars()) do
		self.varUnique[var] = UniqueVerySimple.OFF
	end

	if startOn then
		self.varUnique[grammar:getStartRule()] = UniqueVerySimple.ON
	end

	self:uniqueTk()
	for i, var in ipairs(grammar:getVars()) do
		if not Grammar.isLexRule(var) then
			self:setUniqueTk(grammar:getRHS(var))
		end
	end

	--self:varUse()
	for i, var in ipairs(grammar:getVars()) do		
		if not Grammar.isLexRule(var) then
			self:uniquePath(grammar:getRHS(var), self.varUnique[var])
			--self:uniquePath(grammar:getRHS(var), self.varUse[var])
		end
	end

	--[==[io.write("Unique vars: ")
	for i, v in ipairs(g.plist) do
		if g.uniqueVar[v].upath then
			io.write(v .. '(' .. tostring(g.uniqueVar[v].upath) .. ';' .. tostring(g.uniqueVar[v].seq) .. ')' .. ', ')
		end
	end
	io.write('\n')
  ]==]

end


return UniqueVerySimple

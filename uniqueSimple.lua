local Parser = require'parser'
local First = require'first'
local Set = require'set'

local UniqueSimple = { ON    = "on",
                       PAUSE = "pause",
                       OFF   = "off" }

UniqueSimple.__index = UniqueSimple


function UniqueSimple.new (grammar)
	local self = { 
		grammar = grammar,
		first = First.new(grammar) 
		tkUse = {},
		tkUnique = {},
		varUse = {},
		varUnique = {}
	}
	return setmetatable(self, UniqueSimple)
end


function UniqueSimple:addTkUse (v)
	if not self.tkUse[v] then
		self.tkUse[v] = 1
	else
		self.tkUse[v] = self.tkUse[v] + 1
	end
end


function UniqueSimple:countTkUse (exp)
	if exp.tag == 'char' then
		self:addTkUse(exp:unquote())
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


function UniqueSimple:printUnique ()
	local l = {}
	for k, v in pairs(self.tkUse) do
		table.insert(l, k)
	end
	table.sort(l)
	io.write("Unique tokens (# " .. #l .. "): ")
	io.write(table.concat(l, ', '))
	io.write('\n')
end


function UniqueSimple:setlabel (exp, upath)
	if upath == UniqueSimpe.ON and not Node.matchEmpty(exp) then
		exp.label = true
	end
end

function UniqueSimple:updateUPath (exp, upath)
	if exp.unique then
		return UniqueSimple.ON
	elseif upath == UniqueSimple.PAUSE and not Node.matchEmpty(exp) then
		return UniqueSimpe.ON
	else
		return UniqueSimple.upath
	end
end


function UniqueSimple:uniqueTk ()
	for i, var in ipairs(self.grammar:getVars()) do
		if not Grammar.isLexRule(var) then
			countTk(self.grammar:getRHS(var))
		end
	end

	print("Uunique")
	local cont = {}
	for k, v in pairs(self.tkUse) do
		print(k, " = ", v)
		self.tkUnique[k] = (v == 1) or nil
		--if not cont[v] then
		--	cont[v] = 1
		--else
		--	cont[v] = cont[v] + 1
		--end
	end
	
	--[==[
	for i = 1, 10 do
		print("Token ", i, " = ", cont[i])
	end
	]==]

	self.tkUnique['SKIP'] = nil 
	self:printUnique()
	return self.tkUnique
end


function UniqueSimple:addVarUse (exp)
	if not self.varUse[exp.v] then
		self.varUse[exp.v] = {}
	end
	table.insert(self.varUse[exp.v], exp)
end


function UniqueSimple:countVarUse (exp)
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
		for i, v in iparis(exp.v) do
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

function UniqueSimple:printVarUse ()
	for i, var in ipairs(self.grammar:getVars()) do
		if not Grammar.isLexRule(var) then
			print("Usage", var, self.varUse[var])
		end
	end
end

function UniqueSimple:setUnique (exp, unique)
	exp.unique = unique
end

function UniqueSimple:setUniqueTk (exp)
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

function UniqueSimple:calcUPathChoice (first1, first2, upath)
	if first1:disjoint(first2) and 
	   (upath == UniqueSimpe.ON or upath == UniqueSimple.PAUSE) then
		return UniqueSimple.PAUSE
	else
		return UniqueSimple.OFF
	end
end

function UniqueSimple:uniquePath (exp, upath, flw)
	if exp.tag == 'char' or exp.tag == 'var' then
		self:setlabel(exp, upath)
	elseif exp.tag == 'con' then
		local n = #exp.v
		for i = 1, n - 1 do
			local iExp = exp.v[i]
			local nextIExp = Node.con(table.pack(table.unpack(exp.v, i + 1)))
			local iExpFlw = First.calcfirst 
			if nextIExp:matchEmpty(self.grammar) then
				iExpFlw
			else

			end
			self:uniquePath(v, upath, flw:calck()  
				flwcalck(g, p.p2, flw))
		end
		upath = uniquePath(p.p1, upath, calck(g, p.p2, flw))
		return uniquePath(g, p.p2, upath, flw)
	elseif p.tag == 'ord' then
		setlabel(p, upath)
		local upathP1 = calcUPathChoice(calcfirst(g, p.p1), calck(g, p.p2, flw), upath)
    uniquePath(g, p.p1, upathP1, flw)
		uniquePath(g, p.p2, upath, flw)
		--could remove this line and return the previous call to 'uniquePath'
		return updateUPath(p, upath)
	elseif p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
		local upathP1 = calcUPathChoice(calcfirst(g, p.p1), flw, upath)
		uniquePath(g, p.p1, upathP1, flw)
		return upath
	end
end


function UniqueSimple:calcUniquePath (startOn)
	for i, v in ipairs(self.grammar:getVars()) do
		self.varUnique[v] = UniqueSimple.OFF
	end

	if startOn then
		self.varUnique[self.grammar:getStartRule()] = UniqueSimple.ON
	end

	--g.notDisjointFirst = first.notDisjointFirst(g)

	self:uniqueTk(self.grammar)
	for i, v in ipairs(self.grammar:getVars()) do
		if not parser.isLexRule(v) then
			setUniqueTk(g, g.prules[v])
		end
	end

	varUsage(g)
	for i, var in ipairs(g:getVars()) do		
		if not Grammar.isLexRule(var) then
			uniquePath(g, g:getRHS(var), g.uniqueVar[v], flw[v])
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


return {
	uniqueTk = uniqueTk,
	calcUniquePath = calcUniquePath,
}

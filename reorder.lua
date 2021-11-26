local first = require"first"
local pretty = require"pretty"
local unique = require"unique"

local calcfirst = first.calcfirst
local disjoint = first.disjoint

local Reorder = {}
Reorder.__index = Reorder

function Reorder.new (grammar, choice)
	local self = setmetatable({}, Reorder)
	self.grammar = grammar
	self.choice = choice
	self.conflict = {}
	self.nonConflict = {}
	return self
end


function Reorder:calcFirstAlt ()
	self.firstAlt = {}
	for i, exp in pairs(self.choice) do
		table.insert(self.firstAlt, calcfirst(self.grammar, exp))
	end
	
	return self.firstAlt
end


function Reorder:detectConflict ()
	self.conflict = {}
	self.nonConflict = {}
	local conflict = self.conflict
	local nonConflict = self.nonConflict
	local choice = self.choice
	local grammar = self.grammar
	
	local firstAlt = self:calcFirstAlt()
	
	local n = #self.choice
	for i = 1, n - 1 do
		for j = i + 1, n do
			if not disjoint(firstAlt[i], firstAlt[j]) then
				conflict[choice[i]] = true
				conflict[choice[j]] = true
			end
		end
	end
	
	for i, v in pairs(choice) do
		if not conflict[v] then
			nonConflict[v] = true
		end
	end
	
	return next(conflict) ~= nil, conflict
end


function Reorder:sort ()
	local hasConflict, tConflict = self:detectConflict()
	
	if not hasConflict then
		print("No conflict")
		return self.choice
	end
	
	local output = {}
	for k, v in pairs(tConflict) do
		table.insert(output, pretty.printp(k))
	end
	
	print(table.concat(output, " / "))
	
	unique.calcUniquePath(self.grammar)
	
	
	for k, v in pairs(tConflict) do
		if unique.matchUPath(k) then
			print("Alternative match unique", pretty.printp(k))
		end
	end

end


return Reorder

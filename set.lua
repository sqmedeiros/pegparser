local Set = {}
Set.__index = Set


function Set.new (t, fromKey)
	local self = {}
	self.tab = {}
	setmetatable(self, Set)
	assert(type(t) == 'nil' or type(t) == 'table')
	t = t or {}
	for k, v in pairs(t) do
		if fromKey then
			self:insert(k)
		else
			self:insert(v)
		end
	end
	return self
end


function Set:insert(ele)
	local res = self:getEle(ele)
	if res ~= nil then
		return false
	else
		self.tab[ele] = true
		return true
	end
end


function Set:remove(ele)
	local res = self:getEle(ele)
	if res ~= nil then
		self.tab[ele] = nil
		return true
	else
		return false
	end
end


function Set:getEle (ele)
	return self.tab[ele]
end


function Set:getAll ()
	return self.tab
end


function Set:union (set)
	local newSet = Set.new()
	
	for k, _ in pairs(self.tab) do
		newSet:insert(k)
	end
	
	for k, _ in pairs(set.tab) do
		newSet:insert(k)
	end
  
	return newSet
end


function Set:equal (set)
  for k, _ in pairs(self.tab) do
    if not set:getEle(k) then
      return false
    end
  end
  for k, _ in pairs(set.tab) do
    if not self:getEle(k) then
      return false
    end
  end
  return true
end


function Set:inter (set)
	local newSet = Set.new()

	for k, _ in pairs(self.tab) do
		if set:getEle(k) then
			newSet:insert(k)
		end
	end
  
	return newSet
end


-- true in case self is a subset of set
function Set:subset (set)
  for k, _ in pairs(self.tab) do
    if not set:getEle(k) then
      return false
    end
  end
  return true
end


function Set:empty ()
	return next(self.tab) == nil
end



function Set:disjoint (set)
	return self:inter(set):empty()
end


-- returns self - set
function Set:diff (set)
	local newSet = Set.new()
	
	for k, _ in pairs(self.tab) do
		if not set:getEle(k) then
			newSet:insert(k)
		end
	end
	
	return newSet
end


function Set:sort()
  local list = {}
	for k, _ in pairs(self.tab) do
		table.insert(list, k)
	end
	table.sort(list)
	return list
end


function Set:tostring()
  local list = self:sort()
  return "{ " .. table.concat(list, ", ") .. " }"
end


return Set

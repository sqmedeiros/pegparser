local Node = {}
Node.__index = Node


function Node.new (tag, v)
	local self = { tag = tag, v = v }
	return setmetatable(self, Node)
end

--function Node.copy (node)
--	if type.node(v) ~= "table" then
--		return Node.new(node.tag, node.v)
--	else
--		
--	end	
--end


function Node.empty ()
	return Node.new('empty')
end


function Node.any ()
	return Node.new('any')
end


function Node.char (v)
	assert(v)
	return Node.new('char', v)
end


function Node.set (l)
	assert(l)
	return Node.new('set', l)
end


function Node.var (v)
	assert(v)
	return Node.new('var', v)
end


function Node.andd (exp)
	assert(exp)
	return Node.new('and', exp)
end


function Node.nott (exp)
	assert(exp)
	return Node.new('not', exp)
end


function Node.con (...)
	local l = {...}
	
	if #l > 1 then
		return Node.new('con', l)
	else
		return ...
	end
end


function Node.choice (...)
	local l = {...}
	
	if #l > 1 then
		return Node.new('choice', l)
	else
		return ...
	end
end


function Node.opt (exp)
	return Node.new('opt', exp)
end


function Node.star (exp)
	return Node.new('star', exp)
end


function Node.plus (exp)
	return Node.new('plus', exp)
end


function Node.throw (lab)
	return Node.new('throw', lab)
end


function Node.def (v)
	return Node.new('def', v)
end


function Node.constCap (v)
	return Node.new('constCap', v)
end


function Node.posCap ()
	return Node.new('posCap')
end


function Node.simpCap (exp)
	return Node.new('simpCap', exp)
end


function Node.tabCap (exp)
	return Node.new('tabCap', exp)
end


function Node.anonCap (exp)
	return Node.new('anonCap', exp)
end


function Node.namedCap (v, exp)
	return Node.new('namedCap', {v, exp} )
end


function Node.discardCap (exp)
	return Node.new('funCap', exp)
end


function Node:isSimple ()
	local tag = self.tag
	return tag == 'empty' or tag == 'char' or tag == 'any' or
         tag == 'set' or tag == 'var' or tag == 'throw' or
         tag == 'posCap' or tag == 'def'
end


function Node:getRepOp ()
	local tag = self.tag
	assert(tag == 'opt' or tag == 'plus' or tag == 'star', tag)
	if tag == 'star' then
		return '*'
	elseif tag == 'plus' then
		return '+'
	else
		return '?'
	end
end


function Node:getPredOp ()
	local tag = self.tag
	assert(tag == 'not' or tag == 'and', tag)
	if self.tag == 'not' then
		return '!'
	else
		return '&'
	end
end


function Node:matchEmpty (g)
	local tag = self.tag
	if tag == 'empty' or tag == 'not' or tag == 'and' or
     tag == 'posCap' or tag == 'star' or tag == 'opt' or
		 tag == 'throw' then
		return true
	elseif tag == 'def' then
		return false
	elseif tag == 'char' or tag == 'set' or tag == 'any' or
         tag == 'plus' then
		return false
	elseif tag == 'con' then
		for _, iExp in ipairs(self.v) do
			if not iExp:matchEmpty(g) then
				return false
			end
		end
		return true
	elseif tag == 'choice' then
		for _, iExp in ipairs(self.v) do
			if iExp:matchEmpty(g) then
				return true
			end
		end
		return false
	elseif tag == 'var' then
		assert(g ~= nil)
		local rhs = g:getRHS(self)
		return rhs:matchEmpty(g)
	elseif tag == 'simpCap' or tag == 'tabCap' or tag == 'anonCap' then
		return self.v:matchEmpty(g)
	elseif tag == 'nameCap' then
		local exp = self.v[2]
		return exp:matchEmpty(g)
	else
		print(self)
		error("Unknown tag" .. tostring(self.tag))
	end
end


return Node

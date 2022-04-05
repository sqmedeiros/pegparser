local Node = {
	
}
Node.__index = Node


function Node.new (tag, v)
	local self = { tag = tag, v = v }
	return setmetatable(self, Node)
end


function Node.copy (node)
    assert(type(node) == "table")
	if type(node.v) ~= "table" or node.tag == 'set' then
		return Node.new(node.tag, node.v)
	elseif node.tag == 'con' or node.tag == 'choice' then
		local t = {}
		for k, v in pairs(node.v) do
			t[k] = Node.copy(v)
		end
		return Node.new(node.tag, t)			
    else
		return Node.new(node.tag, Node.copy(node.v))
	end
end


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
	assert(#l >= 1)
	return Node.new('set', l)
end


function Node.var (v)
	assert(v)
	return Node.new('var', v)
end


function Node.andd (exp)
	assert(exp)
	return Node.new('and', Node.copy(exp))
end


function Node.nott (exp)
	assert(exp)
	return Node.new('not', Node.copy(exp))
end


function Node.con (l1, l2)
	-- in case of two arguments, the code asssumes two exp
	if l2 ~= nil then
		local exp
		if l1.tag == 'con' then
			exp = Node.copy(l1)
		else
			exp = Node.new('con', {Node.copy(l1)})
		end
		
		if l2.tag == 'con' then
			for i, v in ipairs(l2.v) do
				table.insert(exp.v, Node.copy(v))
			end
		else
			table.insert(exp.v, Node.copy(l2))
		end
		
		return exp
	elseif #l1 > 1 then
		local con = Node.new('con', {})
		for i, v in ipairs(l1) do
			table.insert(con.v, Node.copy(v))
		end
		return con
	else
		return Node.copy(l1[1])
	end
end


function Node.choice (l)
	if #l > 1 then
		local choice = Node.new('choice', {})
		for i, v in ipairs(l) do
			table.insert(choice.v, Node.copy(v))
		end
		return choice
	else
		return Node.copy(l[1])
	end
end


function Node.opt (exp)
	return Node.new('opt', Node.copy(exp))
end


function Node.star (exp)
	return Node.new('star', Node.copy(exp))
end


function Node.plus (exp)
	return Node.new('plus', Node.copy(exp))
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
	return Node.new('simpCap', Node.copy(exp))
end


function Node.tabCap (exp)
	return Node.new('tabCap', Node.copy(exp))
end


function Node.anonCap (exp)
	return Node.new('anonCap', Node.copy(exp))
end


function Node.namedCap (v, exp)
	return Node.new('namedCap', {v, Node.copy(exp)} )
end


function Node.discardCap (exp)
	return Node.new('funCap', Node.copy(exp))
end


function Node:unquote ()
	return string.sub(self.v, 2, #self.v - 1)
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

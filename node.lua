local Node = {}
Node.__index = Node


function Node.new (tag, p)
	return { tag = tag, p = p }
end


function Node.newEmpty ()
	return Node.new('empty')
end


function Node.newAny ()
	return Node.new('any')
end


function Node.newChar (v)
	assert(v)
	return Node.new('char', v)
end


function Node.newSet (l)
	assert(l)
	return Node.new('set', l)
end


function Node.newVar (v)
	assert(v)
	return Node.new('var', v)
end


function Node.newAnd (p)
	assert(p)
	return Node.new('and', p)
end


function Node.newNot (p)
	assert(p)
	return Node.new('not', p)
end


function Node.newCon (...)
	if #{...} > 1 then
		return Node.new('con', {...})
	else
		return ...
	end
end


function Node.newChoice (...)
	if #{...} > 1 then
		return Node.new('choice', {...})
	else
		return ...
	end
end


return Node

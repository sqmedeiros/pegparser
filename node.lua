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
	local l = {...}
	
	if #l > 1 then
		return Node.new('con', l)
	else
		return ...
	end
end


function Node.newChoice (...)
	local l = {...}
	
	if #l > 1 then
		return Node.new('choice', l)
	else
		return ...
	end
end


function Node.newOpt (p)
	return Node.new('opt', p)
end


function Node.newStar (p)
	return Node.new('star', p)
end


function Node.newPlus (p)
	return Node.new('plus', p)
end


function Node.newThrow (lab)
	return Node.new('throw', lab)
end


function Node.newDef (v)
	return Node.new('def', v)
end


function Node.newConstCap (p)
	return Node.new('constCap', p)
end

function Node.newPosCap ()
	return Node.new('posCap')
end

function Node.newSimpCap (p)
	return Node.new('simpCap', p)
end

function Node.newTabCap(p)
	return Node.new('tabCap', p)
end

function Node.newAnonCap (p)
	return Node.new('anonCap', p)
end

function Node.newNameCap (p1, p2)
	return Node.new('nameCap', p1, p2)
end

function Node.newDiscardCap (p)
	return Node.new('funCap', p)
end



return Node

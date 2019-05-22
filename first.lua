local parser = require'parser'
local pretty = require'pretty'
local FIRST
local FOLLOW
local empty = '__empty'
local any = '__any'
local calcf
local newString = parser.newString
local newNode = parser.newNode
local newOrd = parser.newOrd
local printfirst, printsymbols, calcfirst, calck

local function disjoint (s1, s2)
	for k, _ in pairs(s1) do
		if s2[k] then
			return false
		end
	end
	return true
end


local function isequal (s1, s2)
  for k, _ in pairs(s1) do
    if not s2[k] then
      return false
    end
  end
  for k, _ in pairs(s2) do
    if not s1[k] then
      return false
    end
  end
  return true
end


-- true in case s1 is a subset of s2
local function issubset (s1, s2)
  for k, _ in pairs(s1) do
    if not s2[k] then
      return false
    end
  end
  return true
end


local function inter (s1, s2, notEmpty)
	local s3 = {}
	for k, _ in pairs(s1) do
		if s2[k] then
			s3[k] = true
		end
	end
  if notEmpty then
		s3[empty] = nil
	end	
	return s3
end


local function union (s1, s2, notEmpty)
	local s3 = {}
	for k, _ in pairs(s1) do
		s3[k] = true
	end
	for k, _ in pairs(s2) do
		s3[k] = true
	end
  if notEmpty then
		s3[empty] = nil
	end	
	return s3
end


local function sortset(s)
  local r = {}
	for k, _ in pairs(s) do
		table.insert(r, k)
	end
	table.sort(r)
	return r
end


local function getElem (v)
	if string.sub(v, 1, 2) == '__' then
		return newNode('var', string.sub(v, 3))
	elseif v == '$' then
		return parser.newNot(parser.newAny())
	else
		return newString(v)
	end
end

local function set2choice (s)
	local p
  local r = sortset(s)
	for i, v in ipairs(r) do
		if not p then
				p = getElem(v)
		else
			p = newOrd(getElem(v), p)
		end
	end	
	return p
end



local function printfollow (g)
	for i, v in ipairs(g.plist) do
		print(v .. ': ', table.concat(sortset(FOLLOW[v]), ", "))
	end
end

function printfirst (g)
	for i, v in ipairs(g.plist) do
		print(v .. ': ', table.concat(sortset(calcfirst(g, g.prules[v])), ", "))
	end
end


local function unfoldset (l)
	local t = {}
	for i, v in ipairs(l) do
		if #v == 3 then
			local x = string.byte(v:sub(1, 1))
			local y = string.byte(v:sub(3, 3))
			for i = x, y do
				t[string.char(i)] = true
			end
		else
			t[v] = true
		end
	end
	return t
end

function calcfirst (g, p)
	--print(p.tag, p.p1.tag, p.p1)
	if p.tag == 'empty' then
		return { [empty] = true }
	elseif p.tag == 'char' then
    return { [p.p1] = true }
	elseif p.tag == 'any' then
		return { [any] = true }
	elseif p.tag == 'set' then
		return unfoldset(p.p1)
	elseif p.tag == 'posCap' then
		return { [empty] = true }
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		return calcfirst(g, p.p1)
	elseif p.tag == 'nameCap'then
		return calcfirst(g, p.p2)
	elseif p.tag == 'ord' then
		return union(calcfirst(g, p.p1), calcfirst(g, p.p2), false)
	elseif p.tag == 'con' then
		local s1 = calcfirst(g, p.p1)
    local s2 = calcfirst(g, p.p2)
		if s1[empty] then
			s1[empty] = nil
      local s3 = union(s1, s2, false)
			s1[empty] = true
			return s3
		else
			return s1
		end
	elseif p.tag == 'var' then
		if parser.isLexRule(p.p1) then
			return { ['__' .. p.p1] = true }
		end
		return FIRST[p.p1]
	elseif p.tag == 'throw' then
		return { [empty] = true }
	elseif p.tag == 'and' then
		return { [empty] = true }
	elseif p.tag == 'not' then
		return { [empty] = true }
  -- in a well-formed PEG, given p*, we know p does not match the empty string
	elseif p.tag == 'opt' or p.tag == 'star' then 
    --if p.tag == 'plus' and p.p1.v == 'recordfield' then
    --  print ('danado', p.p1.v)
    --end
		return union(calcfirst(g, p.p1), { [empty] = true}, false)
  elseif p.tag == 'plus' then
		return calcfirst(g, p.p1)
	elseif p.tag == 'def' then
		return { ['%' .. p.p1] = true }
	else
		print(p, p.tag, p.empty, p.any)
		error("Unknown tag: " .. p.tag)
	end
end


function calck (g, p, k)
	if p.tag == 'empty' then
		return k
	elseif p.tag == 'char' then
		return { [p.p1]=true }
	elseif p.tag == 'any' then
		return { [any] = true }
	elseif p.tag == 'set' then
		return unfoldset(p.p1)
	elseif p.tag == 'posCap' then
		return { [empty] = true }
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'nameCap' or p.tag == 'anonCap' then
		return { [empty] = true }
	elseif p.tag == 'ord' then
		local k1 = calck(g, p.p1, k)
		local k2 = calck(g, p.p2, k)
		return union(k1, k2, true)
	elseif p.tag == 'con' then
		local k2 = calck(g, p.p2, k)
		return calck(g, p.p1, k2)
	elseif p.tag == 'var' then
		if parser.isLexRule(p.p1) then
			return { ['__' .. p.p1] = true }
		end
    if parser.matchEmpty(p) then
			return union(FIRST[p.p1], k, true)
    else
		  return FIRST[p.p1]
    end
	elseif p.tag == 'throw' then
		return k
	elseif p.tag == 'any' then
		return { ['.']=true }
	elseif p.tag == 'and' then
		return { [empty] = true }
	elseif p.tag == 'not' then
		return k 
	elseif p.tag == 'opt' then
		return union(calck(g, p.p1, k), k, true) 
  -- in case of a well-formed PEG a repetition does not match the empty string
	elseif p.tag == 'star' then
		return union(calck(g, p.p1, k), k, true)
	elseif p.tag == 'plus' then
		return union(calck(g, p.p1, k), k, true)
	elseif p.tag == 'def' then
		return { ['%' .. p.p1] = true }
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function initFst (g)
  FIRST = {}
  for k, v in pairs(g.prules) do
    FIRST[k] = {}
  end
end


local function calcFst (g)
  local update = true
  initFst(g)
	
  while update do
    update = false
    for k, v in pairs(g.prules) do
			local firstv = calcfirst(g, v)
			if not isequal(FIRST[k], firstv) then
        update = true
	      FIRST[k] = union(FIRST[k], firstv, false)
			end
    end
	end

	return FIRST
end


local function initFlw(g)
  FOLLOW = {}
  for k, v in pairs(g.prules) do
    FOLLOW[k] = {}
  end
  FOLLOW[g.init] = { ['$'] = true }
end


local function calcFlwAux (g, p, flw)
  if p.tag == 'var' then
    FOLLOW[p.p1] = union(FOLLOW[p.p1], flw, true)
  elseif p.tag == 'con' then
    calcFlwAux(g, p.p2, flw)
    local k = calcfirst(g, p.p2)
    assert(not k[empty] == not parser.matchEmpty(p.p2), tostring(k[empty]) .. ' ' .. tostring(parser.matchEmpty(p.p2)) .. ' ' .. pretty.printp(p.p2))
    if parser.matchEmpty(p.p2) then
    --if k[empty] then
      calcFlwAux(g, p.p1, union(k, flw, true))
    else
      calcFlwAux(g, p.p1, k)
		end
  elseif p.tag == 'star' or p.tag == 'plus' then
    calcFlwAux(g, p.p1, union(calcfirst(g, p.p1), flw, true))
  elseif p.tag == 'opt' then
    calcFlwAux(g, p.p1, flw)
  elseif p.tag == 'ord' then
    calcFlwAux(g, p.p1, flw)
    calcFlwAux(g, p.p2, flw)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		calcFlwAux(g, p.p1, flw)
	elseif p.tag == 'nameCap' then
		calcFlwAux(g, p.p2, flw)
	end
end


local function calcFlw (g)
  local update = true
  initFlw(g)

  while update do
    local tmp = {}
    for k, v in pairs(FOLLOW) do
      tmp[k] = v
    end

    for k, v in pairs(g.prules) do
      calcFlwAux(g, v, FOLLOW[k]) 
    end

    update = false
    for k, v in pairs(g.prules) do
      if not isequal(FOLLOW[k], tmp[k]) then
			  update = true
      end
    end
  end

  return FOLLOW
end


return {
  calcFlw = calcFlw,
  calcFst = calcFst,
	calcfirst = calcfirst,
	printfollow = printfollow,
	printfirst = printfirst,
	disjoint = disjoint,
	set2choice = set2choice,
	calck = calck,
	empty = empty,
	any = any,
	isequal = isequal,
	issubset = issubset,
	sortset = sortset,
	inter = inter,
	union = union,
}


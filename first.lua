local parser = require'parser'
local pretty = require'pretty'
local FIRST
local FOLLOW
local empty = '__empty'
local any = '__any'
local calcf
local newString = parser.newString
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


local function issubset (s1, s2)
  for k, _ in pairs(s1) do
    if not s2[k] then
      return false
    end
  end
  return true
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


local function set2choice (s)
	local p
  local r = sortset(s)
	for i, v in ipairs(r) do
		if not p then
			p = newString(v)
		else
			p = newOrd(newString(v), p)
		end
	end	
	return p
end



local function printfollow (r)
	for i, v in ipairs(r) do
		print(v .. ': ', table.concat(sortset(FOLLOW[v]), ", "))
	end
end

function printfirst (g, r)
	for i, v in ipairs(r) do
		print(v .. ': ', table.concat(sortset(calcfirst(g[v])), ", "))
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

function calcfirst (p)
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
		return calcfirst(p.p1)
	elseif p.tag == 'nameCap'then
		return calcfirst(p.p2)
	elseif p.tag == 'ord' then
		return union(calcfirst(p.p1), calcfirst(p.p2), false)
	elseif p.tag == 'con' then
		local s1 = calcfirst(p.p1)
    local s2 = calcfirst(p.p2)
		if s1[empty] then
			s1[empty] = nil
      local s3 = union(s1, s2, false)
			s1[empty] = true
			return s3
		else
			return s1
		end
	elseif p.tag == 'var' then
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
		return union(calcfirst(p.p1), { [empty] = true}, false)
  elseif p.tag == 'plus' then
		return calcfirst(p.p1)
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
    if parser.matchEmpty(p) then
			return union(FIRST[p.p1], k, true)
    else
		  return FIRST[p.p1]
    end
	elseif p.tag == 'throw' then
		return k
	elseif p.tag == 'any' then
		return { ['.']=true }
	elseif p.tag == 'not' then
		return k 
	elseif p.tag == 'opt' then
		return union(calck(g, p.p1, k), k, true) 
  -- in case of a well-formed PEG a repetition does not match the empty string
	elseif p.tag == 'star' then
		return union(calck(g, p.p1, k), k, true)
	elseif p.tag == 'plus' then
		return union(calck(g, p.p1, k), k, true)
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function initFst (g)
  FIRST = {}
  for k, v in pairs(g) do
    FIRST[k] = {}
  end
end


local function calcFst (g)
  local update = true
  initFst(g)
	
  while update do
    update = false
    for k, v in pairs(g) do
			local firstv = calcfirst(v)
			if not isequal(FIRST[k], firstv) then
        update = true
	      FIRST[k] = union(FIRST[k], firstv, false)
			end
    end
	end

	return FIRST
end


local function initFlw(g, init)
  FOLLOW = {}
  for k, v in pairs(g) do
    FOLLOW[k] = {}
  end
  FOLLOW[init] = { ['$'] = true }
end


local function calcFlwAux (p, flw)
  if p.tag == 'var' then
    FOLLOW[p.p1] = union(FOLLOW[p.p1], flw, true)
  elseif p.tag == 'con' then
    calcFlwAux(p.p2, flw)
    local k = calcfirst(p.p2)
    assert(not k[empty] == not parser.matchEmpty(p.p2), tostring(k[empty]) .. ' ' .. tostring(parser.matchEmpty(p.p2)) .. ' ' .. pretty.printp(p.p2))
    if parser.matchEmpty(p.p2) then
    --if k[empty] then
      calcFlwAux(p.p1, union(k, flw, true))
    else
      calcFlwAux(p.p1, k)
		end
  elseif p.tag == 'star' or p.tag == 'plus' then
    calcFlwAux(p.p1, union(calcfirst(p.p1), flw, true))
  elseif p.tag == 'opt' then
    calcFlwAux(p.p1, flw)
  elseif p.tag == 'ord' then
    calcFlwAux(p.p1, flw)
    calcFlwAux(p.p2, flw)
	elseif p.tag == 'simpCap' or p.tag == 'tabCap' or p.tag == 'anonCap' then
		calcFlwAux(p.p1, flw)
	elseif p.tag == 'nameCap' then
		calcFlwAux(p.p2, flw)
	end
end


local function calcFlw (g, init)
  local update = true
  initFlw(g, init)

  while update do
    local tmp = {}
    for k, v in pairs(FOLLOW) do
      tmp[k] = v
    end

    for k, v in pairs(g) do
      calcFlwAux(v, FOLLOW[k]) 
    end

    update = false
    for k, v in pairs(g) do
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
}


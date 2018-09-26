local lpeg = require"lpeg"
local parser = require'parser'
local FIRST
local FOLLOW
local empty = '' 
local calcf
local newString = parser.newString
local newOrd = parser.newOrd
local printfirst, calcfirst, calck


local function disjoint (s1, s2)
	for k, _ in pairs(s1) do
		if s2[k] then
			return false
		end
	end
	return true
end


local function equalSet (s1, s2)
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


local function union (s1, s2, notEmpty)
	local s3 = {}
  local eq = true
	for k, _ in pairs(s1) do
		s3[k] = true
    if not s2[k] then
      eq = false
    end
	end
	for k, _ in pairs(s2) do
		s3[k] = true
    if not s1[k] then
      eq = false
    end
	end
  if notEmpty then
		s3[empty] = nil
	end	
	return s3, eq
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


local function matchEmpty (p)
	if p.tag == 'empty' or p.tag == 'star' or
     p.tag == 'not' or p.tag == 'and' or p.tag == 'opt' then 
		return true
	elseif p.tag == 'char' or p.tag == 'plus' or p.tag == 'any' then
		return false
	elseif p.tag == 'ord' then
		return matchEmpty(p.p1) or matchEmpty(p.p2)
	elseif p.tag == 'con' then
		if matchEmpty(p.p1) then
			return matchEmpty(p.p2)
		else
			return false
		end
	elseif p.tag == 'var' then
		return FIRST[p.v][empty]
  else
		error("Unknown tag " .. tostring(p.tag))
	end
end


local function writepeg (p, iscon)
	if p.tag == 'char' then
		return "'" .. p.v .. "'"
	elseif p.tag == 'empty' then
		return "''"
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'var' then
		return p.v
	elseif p.tag == 'ord' then
		local s1 = writepeg(p.p1, false)
		local s2 = writepeg(p.p2, false)
		if iscon then
			return '(' .. s1 .. " / " .. s2 .. ')'
		else
			return s1 .. " / " .. s2
		end
	elseif p.tag == 'con' then
		return writepeg(p.p1, true) .. " " .. writepeg(p.p2, true)
	elseif p.tag == 'and' then
		return '&(' .. writepeg(p.p1)	.. ')'
	elseif p.tag == 'not' then
		return '!(' .. writepeg(p.p1)	.. ')'
  elseif p.tag == 'opt' then
    return writepeg(p.p1) .. '?'
  elseif p.tag == 'star' then
    return writepeg(p.p1) .. '*'
  elseif p.tag == 'plus' then
    return writepeg(p.p1) .. '+'
	else
		error("Unknown tag: " .. p.tag)
	end
end



local function printfollow (g)
	for k, v in pairs(g) do
		local s = k .. ':'
		local fst = calcfirst(v)
    local r = sortset(FOLLOW[k])
		for _, v1 in ipairs(r) do
			s = s .. ' ' .. v1
		end
		print(s)
    print("FIRST")
		printfirst(fst) 
	end
end


function printfirst (t)
	local s = ''
	for k, _ in pairs(t) do
		s = s .. ' ' .. k
	end
	print(s) 
end


function calcfirst (p)
	if p.tag == 'empty' then
		return { [empty] = true }
	elseif p.tag == 'char' then
    return { [p.v] = true }
	elseif p.tag == 'ord' then
		return union(calcfirst(p.p1), calcfirst(p.p2))
	elseif p.tag == 'con' then
		local s1 = calcfirst(p.p1)
    local s2 = calcfirst(p.p2)
		if s1[empty] then
      return union(s1, s2, not s2[empty])
		else
			return s1
		end
	elseif p.tag == 'var' then
		return FIRST[p.v]
	elseif p.tag == 'throw' then
		return { }
	elseif p.tag == 'any' then
		return { ["any"] = true }
	elseif p.tag == 'not' then
		return { [empty] = true }
  -- in a well-formed PEG, given p*, we know p does not match the empty string
	elseif p.tag == 'opt' or p.tag == 'star' then 
    --if p.tag == 'plus' and p.p1.v == 'recordfield' then
    --  print ('danado', p.p1.v)
    --end
		return union(calcfirst(p.p1), { [empty] = true})
  elseif p.tag == 'plus' then
		return calcfirst(p.p1)
	else
		error("Unknown tag: " .. p.tag)
	end
end


local function updateFollow (p, k)
	if p.tag == 'var' then
    local v = p.v
    FOLLOW[v] = union(FOLLOW[v], k, true)
	elseif p.tag == 'con' then
		if p.p1.tag == 'var' and matchEmpty(p.p2) then
			updateFollow(p.p1, k)
		end
    updateFollow(p.p2, k)
	elseif p.tag == 'ord' then
		updateFollow(p.p1, k)
		updateFollow(p.p2, k)
	end
end


function calck (g, p, k)
	if p.tag == 'empty' then
		return k
	elseif p.tag == 'char' then
		return { [p.v]=true }
	elseif p.tag == 'ord' then
		local k1 = calck(g, p.p1, k)
		local k2 = calck(g, p.p2, k)
		return union(k1, k2, true)
	elseif p.tag == 'con' then
		local k2 = calck(g, p.p2, k)
		return calck(g, p.p1, k2)
	elseif p.tag == 'var' then
    if matchEmpty(p) then
			return union(FIRST[p.v], k, true)
    else
		  return FIRST[p.v]
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
    updateFollow(g, p.p1, calcfirst(p))
    --if p.p1.tag == 'var' then
    --  local v = p.p1.v
		--	FOLLOW[v] = union(FOLLOW[v], calcfirst(g, g[v], {}), true)
		--end
		return union(calck(g, p.p1, k), k, true)
	elseif p.tag == 'plus' then
    --return calck(g, p.p1, k)
    updateFollow(g, p.p1, calcfirst(p))
    --[[if p.p1.tag == 'var' then
      local v = p.p1.v
			FOLLOW[v] = union(FOLLOW[v], calcfirst(g, g[v], {}), true)
		end]]
		--return union(calck(g, p.p1, k), k) 
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
  local equal
  initFst(g)
	
  while update do
    update = false
    for k, v in pairs(g) do
      FIRST[k], equal = union(FIRST[k], calcfirst(v))
      if not equal then
        update = true
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
    FOLLOW[p.v] = union(FOLLOW[p.v], flw)
  elseif p.tag == 'con' then
    calcFlwAux(p.p2, flw)
    local k = calcfirst(p.p2)
    assert(not k[empty] == not matchEmpty(p.p2), tostring(k[empty]) .. ' ' .. tostring(matchEmpty(p.p2)) .. ' ' .. writepeg(p.p2, p.p2.tag == 'con'))
    if matchEmpty(p.p2) then
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
      if not equalSet(FOLLOW[k], tmp[k]) then
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
	disjoint = disjoint,
	set2choice = set2choice,
	calck = calck,
	matchEmpty = matchEmpty
}


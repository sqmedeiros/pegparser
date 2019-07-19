local parser = require'parser'
local pretty = require'pretty'
local FIRST
local FOLLOW
local TAIL
local empty = '__empty'
local nothing = '__nothing'
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


local function isempty (s)
	return next(s) == nil
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

-- returns s1 - s2
local function setdiff (s1, s2)
	local s3 = {}
	for k, _ in pairs(s1) do
		if not s2[k] then
			s3[k] = true
		end
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


local function printtail (g)
	for i, v in ipairs(g.plist) do
		print(v .. ': ', table.concat(sortset(TAIL[v]), ", "))
	end
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

function updatePref (g, p, tk)
	local entry = g.varPref[p.p1]
	if not entry[p] then
		entry[p] = {}
		updatePrefix = true
	end
	entry[p] = union(entry[p], tk)
	updatePrefix = updatePrefix or not issubset(tk, entry[p])
end


local function printTkPath (t)
	print(table.concat(sortset(t), ", "))
end


local function calcTkPath_aux (g, p, mark, notll1, seq)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		return calcfirst(g, p)
	elseif p.tag == 'var' then
		if mark[p.p1] then
			return {}
		else
			mark[p.p1] = true
			return calcTkPath_aux(g, g.prules[p.p1], mark, notll1, seq)
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		return calcTkPath_aux(g, p.p1, mark, notll1, seq)
	elseif p.tag == 'ord' then
		local tk1, tk2 = {}, {}
		local s1 = inter(notll1, calcfirst(g, p.p1))
		if not isempty(s1) or seq then
			tk1 = calcTkPath_aux(g, p.p1, mark, notll1, seq)
		end
		local s2 = inter(notll1, calcfirst(g, p.p2))
		if not isempty(s2) or seq then
			tk2 = calcTkPath_aux(g, p.p2, mark, notll1, seq)
		end
		return union(tk1, tk2)
	elseif p.tag == 'con' then
		return union(calcTkPath_aux(g, p.p1, mark, notll1, seq), calcTkPath_aux(g, p.p2, mark, notll1, seq or not parser.matchEmpty(p.p1)))
	elseif p.tag == 'not' or p.tag == 'and' then
		return {}
	else
		error("Unknown tag: " .. p.tag)
	end
end

local function calcTkPath (g, p, notll1, all)
	return calcTkPath_aux(g, p, {}, notll1, all)
end


local function matchTkPath_aux (g, p, t, mark)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		return t[p.p1]
	elseif p.tag == 'var' then
		if mark[p.p1] then
			return false
		else
			mark[p.p1] = true
			return matchTkPath_aux(g, g.prules[p.p1], t, mark)
		end
	elseif p.tag == 'plus' then
		return matchTkPath_aux(g, p.p1, t, mark)
	elseif p.tag == 'ord' then
		return matchTkPath_aux(g, p.p1, t, mark) and matchTkPath_aux(g, p.p2, t, mark)
	elseif p.tag == 'con' then
		return matchTkPath_aux(g, p.p1, t, mark) or matchTkPath_aux(g, p.p2, t, mark)
	else
		return false
	end
end

local function matchTkPath (g, p, t)
	return matchTkPath_aux(g, p, t, {})
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


local function initPrefix (g)
	g.varPref = {}
	for i, v in ipairs(g.plist) do
		g.varPref[v] = {}
	end
end


local function calcPrefix (g)
  updatePrefix = true
  initPrefix(g)

	while updatePrefix do
    updatePrefix = false
    for i, v in ipairs(g.plist) do
			if i == 1 then
				prefix(g, g.prules[v], { [nothing] = true })
			else
				prefix(g, g.prules[v], {})
			end
    end
	end

	for i1, v1 in ipairs(g.plist) do
		for i2, v2 in ipairs(g.varPref[v1]) do
			print(v1 .. ': ', table.concat(sortset(v2)), ", ")
		end
	end
end


local function initTail(g)
  TAIL = {}
  for k, v in pairs(g.prules) do
    TAIL[k] = {  }
  end
end


function calcTailAux (g, p, tk)
	if p.tag == 'empty' then
		return tk
	elseif p.tag == 'char' then
    return { [p.p1] = true }
	elseif p.tag == 'any' then
		return { [any] = true }
	elseif p.tag == 'set' then
		return unfoldset(p.p1)
	elseif p.tag == 'ord' then
		local s = union(calcTailAux(g, p.p1, tk), calcTailAux(g, p.p2, tk), false)
		if s[empty] then
			s[empty] = nil
			s = union(s, tk)
		end
		return s
	elseif p.tag == 'con' then
    local s1 = calcTailAux(g, p.p1, tk)
		local s2 = calcTailAux(g, p.p2, s1)
		--print("Con", pretty.printp(p))
		--print("Test: ", table.concat(sortset(s2), ", "))
		return s2
	elseif p.tag == 'var' then
		if parser.isLexRule(p.p1) then
			return { ['__' .. p.p1] = true }
		else
			local s = TAIL[p.p1]
			if s[empty] then
				return union(s, tk, false)
			else
				return s
			end
		end
	elseif p.tag == 'throw' then
		return tk 
	elseif p.tag == 'and' then
		return tk 
	elseif p.tag == 'not' then
		return tk 
  -- in a well-formed PEG, given p*, we know p does not match the empty string
	elseif p.tag == 'opt' or p.tag == 'star' then 
    --if p.tag == 'plus' and p.p1.v == 'recordfield' then
    --  print ('danado', p.p1.v)
    --end
		return union(calcTailAux(g, p.p1, tk), tk, false)
  elseif p.tag == 'plus' then
		return calcTailAux(g, p.p1, tk)
	elseif p.tag == 'def' then
		return { ['%' .. p.p1] = true }
	else
		print(p, p.tag, p.empty, p.any)
		error("Unknown tag: " .. p.tag)
	end
end


local function calcTail (g)
  local update = true
	initTail(g)

	while update do
		local tmp = {}
    for k, v in pairs(TAIL) do
      tmp[k] = v
    end
		
		for i, v in ipairs(g.plist) do
			TAIL[v] = union(TAIL[v], calcTailAux(g, g.prules[v], { [empty] = true }), false)
    end
    
		update = false
    for i, v in pairs(g.plist) do
      if not isequal(TAIL[v], tmp[v]) then
			  update = true
      end
    end
	end	

	g.TAIL = TAIL
	return TAIL
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

	g.FOLLOW = FOLLOW
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
	isempty = isempty,
	any = any,
	isequal = isequal,
	issubset = issubset,
	sortset = sortset,
	inter = inter,
	union = union,
	setdiff = setdiff,
	empty = empty,
	calcTkPath = calcTkPath,
	printTkPath = printTkPath,
	matchTkPath = matchTkPath,
	calcPrefix = calcPrefix,
	calcTail = calcTail
}


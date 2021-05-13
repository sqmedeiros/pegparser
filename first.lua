local parser = require'pegparser.parser'
local pretty = require'pegparser.pretty'
local lexKey
local FIRST
local FOLLOW
local TAIL
local PREFIX
local prefixLex = '__'
local empty = prefixLex .. 'empty'
local nothing = prefixLex .. 'nothing'
local any = prefixLex .. 'any'
local calcf
local newString = parser.newString
local newNode = parser.newNode
local newOrd = parser.newOrd
local printfirst, printsymbols, calcfirst, calck


local function isIDBegin (ch)
	return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or ch == '_'
end

local function matchIDBegin (p)
	if p.tag == 'char' then
		return isIDBegin(string.sub(p.p1, 1, 1))
	elseif p.tag == 'set' then
		for k, v in pairs(p.p1) do
			if #v == 1 then
				if isIDBegin(string.sub(v, 1, 1)) then
					return true
				end
			elseif isIDBegin(string.sub(v, 1, 1)) or isIDBegin(string.sub(v, 3, 3)) then
				return true
			end
		end
		return false
	else
		return false
	end
end

function lexKey (p)
	return prefixLex .. p.p1
end


local function getName (p)
	assert(p.tag == 'char' or p.tag == 'var', tostring(p.tag))
	if p.tag == 'char' then
		return '__' .. p.p1
	else
		return p.p1
	end
end


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
	if string.sub(v, 1, 2) == prefixLex then
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
	--returns pattern . when s is empty
	return p or parser.newAny()
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
	if p.tag == 'empty' then
		return { [empty] = true }
	elseif p.tag == 'char' then
    return { [p.p1] = true }
	elseif p.tag == 'any' then
		return { [any] = true }
	elseif p.tag == 'set' then
		return unfoldset(p.p1)
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
			return { [lexKey(p)] = true }
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
	elseif p.tag == 'ord' then
		local k1 = calck(g, p.p1, k)
		local k2 = calck(g, p.p2, k)
		return union(k1, k2, true)
	elseif p.tag == 'con' then
		local k2 = calck(g, p.p2, k)
		return calck(g, p.p1, k2)
	elseif p.tag == 'var' then
		if parser.isLexRule(p.p1) then
			return { [lexKey(p)] = true }
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
			local p = v
			if parser.isLexRule(k) then
				p = parser.newNode('var', k)
			end
			local firstv = calcfirst(g, p)
			if not isequal(FIRST[k], firstv) then
        update = true
	      FIRST[k] = union(FIRST[k], firstv, false)
			end
    end
	end

	return FIRST
end


local function initTail(g)
  TAIL = {}
  for k, v in pairs(g.prules) do
    TAIL[k] = {  }
  end
end


function calcTailAux (g, p, tk, comp)
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
			return { [lexKey(p)] = true }
		else
			if comp then
				return TAIL[p.p1]
			else
				local s = TAIL[p.p1]
				if s[empty] then
					return union(s, tk, false)
				else
					return s
				end
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

	--[=[print("calcTail")
	for i1, v1 in ipairs(g.plist) do
		print(v1 .. ': ', table.concat(sortset(TAIL[v1]), ", "))
	end]=]


	g.TAIL = TAIL
	return TAIL
end


local function initGlobalPrefix (g)
	PREFIX = {}
	for k, v in pairs(g.prules) do
    PREFIX[k] = {  }
  end
	PREFIX[g.init] = { [tostring({})] = true }
end


local function calcGlobalPrefixAux (g, p, pref)
	if p.tag == 'var' then
		PREFIX[p.p1] = union(PREFIX[p.p1], pref)
		return PREFIX[p.p1]
	elseif p.tag == 'ord' then
		calcGlobalPrefixAux(g, p.p1, pref)
		calcGlobalPrefixAux(g, p.p2, pref)
	elseif p.tag == 'con' then
		calcGlobalPrefixAux(g, p.p1, pref)
		local tailp2 = calcTailAux(g, p.p1, pref, true)
		calcGlobalPrefixAux(g, p.p2, tailp2)
	elseif p.tag == 'star' or p.tag == 'plus' then
		local tailp = calcTailAux(g, p, pref, true)
		calcGlobalPrefixAux(g, p.p1, tailp)
	elseif p.tag == 'opt' then
		calcGlobalPrefixAux(g, p.p1, pref)
	end
end


local function calcGlobalPrefix (g)
  local update = true
  initGlobalPrefix(g)

  while update do
    local tmp = {}
    for k, v in pairs(PREFIX) do
      tmp[k] = v
    end

    for k, v in pairs(g.prules) do
      calcGlobalPrefixAux(g, v, PREFIX[k])
    end

    update = false
    for k, v in pairs(g.prules) do
      if not isequal(PREFIX[k], tmp[k]) then
			  update = true
      end
    end
  end

	--[==[print("Global Prefix")
	for i, v in ipairs(g.plist) do
		print(v .. ': ', table.concat(sortset(PREFIX[v]), ", "))
	end]==]


	g.PREFIX = PREFIX
  return PREFIX
end



local function initPrefix (g)
	g.symPref = {}
	g.symPref[g.init] = {}
	g.symRule = {}
end


function updatePref (g, p, tk, v)
	local k = getName(p)
	--print("updatePref", k)
	if not g.symPref[k] then
		g.symPref[k] = {}
	end
	g.symRule[p] = v
	g.symPref[k][p] = tk
end


local function calcPrefixAux (g, p, pref, v)
	--print(tostring(p.p1) .. ':: ', table.concat(sortset(pref), ", "))
	if p.tag == 'var' or p.tag == 'char' then
		updatePref(g, p, pref, v)
	elseif p.tag == 'ord' then
		calcPrefixAux(g, p.p1, pref, v)
		calcPrefixAux(g, p.p2, pref, v)
	elseif p.tag == 'con' then
		calcPrefixAux(g, p.p1, pref, v)
		local tailp2 = calcTailAux(g, p.p1, pref, true)
		calcPrefixAux(g, p.p2, tailp2, v)
	elseif p.tag == 'star' or p.tag == 'plus' then
		local tailp = calcTailAux(g, p, pref, true)
		calcPrefixAux(g, p.p1, tailp, v)
	elseif p.tag == 'opt' then
		calcPrefixAux(g, p.p1, pref, v)
	end
end


local function calcPrefix (g)
	calcGlobalPrefix(g)
  initPrefix(g)

  for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			--calcPrefixAux(g, g.prules[v], { [empty] = true })
			calcPrefixAux(g, g.prules[v], g.PREFIX[v], v)
		end
  end
	--calcPrefixAux(g, g.prules['import'], { [empty] = true })

	--[==[print("calcPrefix")
	for k1, v1 in pairs(g.symPref) do
		print(k1, ' -> ')
		for k2, v2 in pairs(v1) do
			print('\t(' .. k1 .. ', ' .. g.symRule[k2] .. '): ', table.concat(sortset(v2), ", "))
		end
	end]==]
end


local function notDisjointFirstAux (g, t, first1, v, kind)
	local idxFirst = v
	if parser.isLexRule(v) then
		idxFirst = prefixLex .. v
	end
	first2 = FIRST[idxFirst]
	if not first2 then
		first2 = {}
		first2[idxFirst] = true
	end

	if not disjoint(first1, first2) then
		t[v] = kind
	end
end

local function notDisjointFirst (g)
	local res = {}
	for _, var in ipairs(g.plist) do
		if not parser.isLexRule(var) then
			res[var] = {}
			local first1 = FIRST[var]
			for k, _ in pairs(g.tokens) do
				notDisjointFirstAux(g, res[var], first1, k, 'token')
			end
			for _, v in ipairs(g.plist) do
				if var ~= v then
					notDisjointFirstAux(g, res[var], first1, v, 'var')
				end
			end

			--[==[io.write("Not disjoint " .. var .. ": ")
			for k, v in pairs(res[var]) do
				io.write(k .. ", ")
			end
			io.write("\n")]==]
		end
	end
	return res
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
		--print("hei")
    --assert(not k[empty] == not parser.matchEmpty(p.p2), tostring(k[empty]) .. ' ' .. tostring(parser.matchEmpty(p.p2)) .. ' ' .. pretty.printp(p.p2))
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


local function initLocalFollow (g)
	g.symFlw = {}
end


function updateLocalFollow (g, p, tk)
	local k = getName(p)
	--print("updatePref", k)
	if not g.symFlw[k] then
		g.symFlw[k] = {}
	end
	g.symFlw[k][p] = tk
end


local function calcLocalFollowAux (g, p, flw)
	if p.tag == 'var' and not parser.isLexRule(p.p1) then
		updateLocalFollow(g, p, flw)
		return g.FOLLOW[p.p1]
	elseif p.tag == 'var' or p.tag == 'char' then
		updateLocalFollow(g, p, flw)
	elseif p.tag == 'ord' then
		calcLocalFollowAux(g, p.p1, flw)
		calcLocalFollowAux(g, p.p2, flw)
	elseif p.tag == 'con' then
		calcLocalFollowAux(g, p.p1, calck(g, p.p2, flw))
		calcLocalFollowAux(g, p.p2, flw)
	elseif p.tag == 'star' or p.tag == 'plus' then
    calcLocalFollowAux(g, p.p1, union(calcfirst(g, p.p1), flw, true))
	elseif p.tag == 'opt' then
		calcLocalFollowAux(g, p.p1, flw)
	end
end


local function calcLocalFollow (g)
	calcFlw(g)
  initLocalFollow(g)

  for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			calcLocalFollowAux(g, g.prules[v], g.FOLLOW[v])
		end
  end
	--calcPrefixAux(g, g.prules['import'], { [empty] = true })

	--[[print("calcLocalFollow")
	for k1, v1 in pairs(g.symFlw) do
		for k2, v2 in pairs(v1) do
			print(k1 .. ': ', table.concat(sortset(v2), ", "))
		end
	end]]
end



local function getNonDisjRep (g, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' then
		return 0
	elseif p.tag == 'ord' then
		return getNonDisjRep(g, p.p1, flw, rule) + getNonDisjRep(g, p.p2, flw, rule)
	elseif p.tag == 'con' then
		local x = getNonDisjRep(g, p.p1, calck(g, p.p2, flw), rule)
		local y = getNonDisjRep(g, p.p2, flw, rule)
		return x + y
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local first1 = calcfirst(g, p.p1)
		--local flwRep = union(calcfirst(g, p.p1), flw, true)
		local flwRep = flw
		if not disjoint(first1, flwRep) then
			print("Non-disjoint repetition (" .. rule .. "): ", pretty.printp(p))
			io.write("Follow repetition: ")
			for k, v in pairs(flw) do
				io.write(k .. ', ')
			end
			io.write('\n')
			io.write("Intersection with FOLLOW: ")
			local conflict = inter(first1, flwRep)
			for k, v in pairs(conflict) do
				io.write(k .. ', ')
			end
			io.write('\n')
		else
			p.disjoint = true
		end
    return 1 + getNonDisjRep(g, p.p1, flwRep, rule)
	elseif p.tag == 'opt' then
		return 0 + getNonDisjRep(g, p.p1, flw, rule)
	else
		return 0
	end
end


local function getRepReport (g)
	local total = 0
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			total = total + getNonDisjRep(g, g.prules[v], g.FOLLOW[v], v)
		end
  end
  
  print("Total repetitions: " .. total)
end


local function getNonDisjChoice (g, p, flw, rule)
	if p.tag == 'var' or p.tag == 'char' then
		return 0
	elseif p.tag == 'ord' then
		local first1 = calck(g, p.p1, flw)
		local first2 = calck(g, p.p2, flw)
		local isDisj = disjoint(first1, first2)
		local empty1 = parser.matchEmpty(p.p1)
		if not isDisj then
			print("Non-disjoint choice (" .. rule .. "): ", pretty.printp(p))
		end
		if empty1 then
			print("Non-disjoint choice (" .. rule .. "), first alternative matches empty string: ", pretty.printp(p))
		end
		if isDisj and not empty1 then
			p.disjoint = true
		end
		local x = getNonDisjChoice(g, p.p1, flw, rule)
		local y = getNonDisjChoice(g, p.p2, flw, rule)
		return 1 + x + y
	elseif p.tag == 'con' then
		local x = getNonDisjChoice(g, p.p1, calck(g, p.p2, flw), rule)
		local y = getNonDisjChoice(g, p.p2, flw, rule)
		return x + y
	elseif p.tag == 'star' or p.tag == 'plus' then
    return getNonDisjChoice(g, p.p1, union(calcfirst(g, p.p1), flw, true), rule)
	elseif p.tag == 'opt' then
		return getNonDisjChoice(g, p.p1, flw, rule)
	else
		return 0
	end
end


local function getChoiceReport (g)
	local total = 0
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			total = total + getNonDisjChoice(g, g.prules[v], g.FOLLOW[v], v)
		end
  end
  
  print("Total choices: " .. total)
end



return {
	getName = getName,
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
	calcPrefix = calcPrefix,
	calcGlobalPrefix = calcGlobalPrefix,
	calcTail = calcTail,
	calcLocalFollow = calcLocalFollow,
	notDisjointFirst = notDisjointFirst,
	getChoiceReport = getChoiceReport,
	getRepReport = getRepReport,
	matchIDBegin = matchIDBegin
}


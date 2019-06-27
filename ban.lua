local parser = require'parser'
local first = require'first'
local unique = require'unique'
local pretty = require'pretty'
local label = require'label'

local newSeq = parser.newSeq
local newNot = parser.newNot
local newNode = parser.newNode
local newVar = parser.newVar
local calcfirst = first.calcfirst
local disjoint = first.disjoint
local matchEmpty = parser.matchEmpty
local calck = first.calck
local empty = first.empty
local inter = first.inter
local issubset = first.issubset
local union = first.union
local matchUPath = unique.matchUPath
local banned
local memo



-- UPath Deep Algorithm ------------------------------------------------------------
local function upathdeep_ban(g, p, ateTk, notll1, flw, afterU)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		if (ateTk and not afterU) or not disjoint(notll1, calck(g, p, flw)) then
			p.ban = true
		end
	elseif p.tag == 'var' then
		local s = calck(g, p, flw)
		if ateTk then
			if not afterU then
				p.ban = true
			else
				return
			end
			if not issubset(notll1, memo[p.p1]) and not g.uniqueVar[p.p1] then
				memo[p.p1] = union(memo[p.p1], notll1)
				upathdeep_ban(g, g.prules[p.p1], true, notll1, flw, afterU)
			end
		elseif not empty(s) then
			p.ban = true
			if not issubset(s, memo[p.p1]) then
				memo[p.p1] = union(memo[p.p1], s)
				upathdeep_ban(g, g.prules[p.p1], false, s, flw, afterU)
			end
		end
	elseif p.tag == 'ord' then
		if ateTk then
			if not afterU then
				p.ban = true
				upathdeep_ban(g, p.p1, true, notll1, flw, afterU)
				upathdeep_ban(g, p.p2, true, notll1, flw, afterU)
			end
		else
			local s1 = calck(g, p.p1, flw)
			local s2 = calck(g, p.p2, flw)
			if not empty(s1) then
				p.ban = true
				upathdeep_ban(g, p.p1, false, s1, flw, afterU)
			end
			if not empty(s2) then
				p.ban = true
				upathdeep_ban(g, p.p2, false, s2, flw, afterU)
			end
		end
	elseif p.tag == 'con' then
		if not afterU then
			upathdeep_ban(g, p.p1, ateTk, notll1, calck(g, p.p2, flw), afterU)
		end
		if not ateTk then
			ateTk = not disjoint(calcfirst(g, p.p1), notll1)
		end
		if not afterU then
			upathdeep_ban(g, p.p2, ateTk, notll1, flw, afterU or matchUPath(p.p1))
		end
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local s = calck(g, p, flw)
		if ateTk then
			if not afterU then
				p.ban = true
				upathdeep_ban(g, p.p1, true, notll1, flw, afterU)
			end
		elseif not empty(s) then
			p.ban = true
			upathdeep_ban(g, p.p1, false, s, flw, afterU)
		end
	end
end


local function notannotate_upathdeep(g, p, flw)
	if p.tag == 'ord' then
		local s = inter(calcfirst(g, p.p1), calck(g, p.p2, flw))
		if not empty(s) then
			p.ban = true
			upathdeep_ban(g, p.p1, false, s, flw, false)
		end
		notannotate_upathdeep(g, p.p1, flw)
		notannotate_upathdeep(g, p.p2, flw)
	elseif p.tag == 'con' then
		notannotate_upathdeep(g, p.p1, calck(g, p.p2, flw))
		notannotate_upathdeep(g, p.p2, flw)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local s = inter(calcfirst(g, p.p1), flw)
		if not empty(s) then
			p.ban = true
			upathdeep_ban(g, p.p1, false, s, flw, false)
		end
		notannotate_upathdeep(g, p.p1, flw)
	end
end



------------------------------------------------------------------------------


-- Deep Algorithm ------------------------------------------------------------


local function deep_ban(g, p, ateTk, notll1, flw)
	if p.tag == 'char' or (p.tag == 'var' and parser.isLexRule(p.p1)) then
		if ateTk or not disjoint(notll1, calck(g, p, flw)) then
			p.ban = true
		end
	elseif p.tag == 'var' then
		local s = calck(g, p, flw)
		if ateTk then
			p.ban = true
			if not issubset(notll1, memo[p.p1]) then
				memo[p.p1] = union(memo[p.p1], notll1)
				deep_ban(g, g.prules[p.p1], true, notll1, flw)
			end
		elseif not empty(s) then
			p.ban = true
			if not issubset(s, memo[p.p1]) then
				memo[p.p1] = union(memo[p.p1], s)
				deep_ban(g, g.prules[p.p1], false, s, flw)
			end
		end
	elseif p.tag == 'ord' then
		if ateTk then
			p.ban = true
			deep_ban(g, p.p1, true, notll1, flw)
			deep_ban(g, p.p2, true, notll1, flw)
		else
			local s1 = calck(g, p.p1, flw)
			local s2 = calck(g, p.p2, flw)
			if not empty(s1) then
				p.ban = true
				deep_ban(g, p.p1, false, s1, flw)
			end
			if not empty(s2) then
				p.ban = true
				deep_ban(g, p.p2, false, s2, flw)
			end
		end
	elseif p.tag == 'con' then
		deep_ban(g, p.p1, ateTk, notll1, calck(g, p.p2, flw))
		if not ateTk then
			ateTk = not disjoint(calcfirst(g, p.p1), notll1)
		end
		deep_ban(g, p.p2, ateTk, notll1, flw)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local s = calck(g, p, flw)
		if ateTk then
			p.ban = true
			deep_ban(g, p.p1, true, notll1, flw)
		elseif not empty(s) then
			p.ban = true
			deep_ban(g, p.p1, false, s, flw)
		end
	end
end


local function notannotate_deep(g, p, flw)
	if p.tag == 'ord' then
		local s = inter(calcfirst(g, p.p1), calck(g, p.p2, flw))
		if not empty(s) then
			p.ban = true
			deep_ban(g, p.p1, false, s, flw)
		end
		notannotate_deep(g, p.p1, flw)
		notannotate_deep(g, p.p2, flw)
	elseif p.tag == 'con' then
		notannotate_deep(g, p.p1, calck(g, p.p2, flw))
		notannotate_deep(g, p.p2, flw)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local s = inter(calcfirst(g, p.p1), flw)
		if not empty(s) then
			p.ban = true
			deep_ban(g, p.p1, false, s, flw)
		end
		notannotate_deep(g, p.p1, flw)
	end
end
------------------------------------------------------------------------------

local function addlab (g, p, seq, flw)
	if ((p.tag == 'var' and not matchEmpty(p)) or p.tag == 'char' or p.tag == 'any') and seq and not p.ban then
    return label.markerror(p, flw)
	elseif p.tag == 'con' then
		local newseq = seq or not matchEmpty(p.p1)
		--return newSeq(addlab(g, p.p1, seq, calck(g, p.p2, flw)), addlab(g, p.p2, newseq, flw))
		return newNode(p, addlab(g, p.p1, seq, calck(g, p.p2, flw)), addlab(g, p.p2, newseq, flw))
	elseif p.tag == 'ord' then
    local flagDisjoint = disjoint(calcfirst(g, p.p1), calck(g, p.p2, flw))
		local p1 = p.p1
    if flagDisjoint then
      p1 = addlab(g, p.p1, false, flw)
    end
		local p2 = addlab(g, p.p2, false, flw)
		if seq and not matchEmpty(p) and not p.ban then
			return label.markerror(newNode(p, p1, p2), flw)
		else
      return newNode(p, p1, p2)
		end
	elseif (p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus') and disjoint(calcfirst(g, p.p1), flw) then
		local newp = addlab(g, p.p1, false, flw)
    if p.tag == 'star' or p.tag == 'opt' then
			return newNode(p, newp)
    else --plus
      if seq and not p.ban then
				return label.markerror(newNode(p, newp), flw)
			else
				return newNode(p, newp)
			end
		end
	else
		return p
	end
end


local function ban_aux (g, f, flw)
  for i, v in ipairs(g.plist) do
    if not parser.isLexRule(v) then
      f(g, g.prules[v], flw[v])
    end
  end
end


local function ban (g, flagBan)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	
	banned = {}    -- map with non-terminals that we mut not annotate
	memo = {}
	for i, v in ipairs(g.plist) do
		memo[v] = {}
	end
		
	if flagBan == 'deep' then
		ban_aux(g, notannotate_deep, flw)
	elseif flagBan == 'upathdeep' then
		ban_aux(g, notannotate_upathdeep, flw)
	else
		error("ban: Invalid flag " .. tostring(flagBan))
	end

	local s = first.sortset(banned)
	io.write("Banned (" .. #s .. "): ")
	for i, v in ipairs(s) do
		io.write(v .. ', ')
	end
	io.write"\n"
end


local function annotateBan (g)
	local fst = first.calcFst(g)
	local flw = first.calcFlw(g)
	local newg = parser.initgrammar(g)

	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) and not banned[v] then
			newg.prules[v] = addlab(g, g.prules[v], false, flw[v])
		end
	end

	return newg
end


return {
	ban = ban,
	annotateBan = annotateBan
}

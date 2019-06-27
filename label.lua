local first = require'first'
local parser = require'parser'

local newNode = parser.newNode
local set2choice = first.set2choice
	
local ierr

-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+

local function adderror (g, p, rec)
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	if rec then
		local pred = parser.newNot(set2choice(p.flw))
		local seq = newNode('var', 'EatToken')
		table.insert(g.plist, s)
		g.prules[s] = newNode('star', parser.newSeq(pred, seq))
	end
	return parser.newOrd(p, parser.newThrow(s))
end


local function markerror (p, flw)	
	p.throw = true
	p.flw = flw
	return p
end


local function putlabel (g, p, rec)
	if p.throw then
		io.write("Err_" .. ierr .. ", ")
		return adderror(g, p, rec)
	else
		return p
	end
end


local function labelexp (g, p, rec)
	if p.tag == 'char' or p.tag == 'var' or p.tag == 'any' then
		return putlabel(g, p, rec)
	elseif p.tag == 'ord' then
		local p1 = labelexp(g, p.p1, rec)
		local p2 = labelexp(g, p.p2, rec)
		return putlabel(g, newNode(p, p1, p2), rec)
	elseif p.tag == 'con' then
		local p1 = labelexp(g, p.p1, rec)
		local p2 = labelexp(g, p.p2, rec)
		return newNode(p, p1, p2, rec)
	elseif p.tag == 'star' or p.tag == 'plus' or p.tag == 'opt' then
		local p1 = labelexp(g, p.p1, rec)
		return putlabel(g, newNode(p, p1), rec)
	else
		return p	
	end
end


local function getLexRules (g)
	local t = {}
	for i, v in ipairs(g.plist) do
		if parser.isLexRule(v) and v ~= 'SKIP' and v ~= 'SPACE' then
			t['__' .. v] = true
		end
	end
	return t
end


local function addTkRule (g)
	local t = getLexRules(g)
	-- add literal tokens to t
	for k, v in pairs(g.tokens) do
		t[k] = v
	end
	local p = set2choice(t)
	g.prules['Token'] = p
	table.insert(g.plist, 'Token')
end


local function addEatTkRule (g)
	-- (!FOLLOW(p) eatToken space)*
	-- eatToken  <-  token / (!space .)+ skip
	local newSeq = parser.newSeq
	local any = parser.newAny()
	local tk = newNode('var', 'Token')
	local notspace = parser.newNot(newNode('var', 'SPACE'))
	local eatToken = parser.newOrd(tk, newNode('plus', newSeq(notspace, any)))
	g.prules['EatToken'] = newSeq(eatToken, newNode('var', 'SKIP'))
	table.insert(g.plist, 'EatToken')
end


local function labelgrammar (g, rec)
	if rec then
		addTkRule(g)
		addEatTkRule(g)
	end

	io.write("Adding labels: ")
	ierr = 1
	for i, v in ipairs(g.plist) do
		if not parser.isLexRule(v) then
			g.prules[v] = labelexp(g, g.prules[v], rec)
		else
			g.prules[v] = g.prules[v]
		end
		g.plist[i] = v
	end
	io.write("\n\n")
	return g
end

return {
	labelgrammar = labelgrammar,
	markerror = markerror
}

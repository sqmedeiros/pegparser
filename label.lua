local first = require'pegparser.first'
local parser = require'pegparser.parser'

local newNode = parser.newNode
local newSeq = parser.newSeq
local newOrd = parser.newOrd
local newNot = parser.newNot
local newAnd = parser.newAnd
local newThrow = parser.newThrow
local newString = parser.newString
local set2choice = first.set2choice
	
local ierr


local currentRecPolicy = nil

local panicRecPolicy, delPanicRecPolicy

local function getLabelName ()
  local s = 'Err_' .. string.format("%03d", ierr)
	ierr = ierr + 1
	return s
end


-- p SKIP
local function addSkip (p)
	return newSeq(p, newNode('var', 'SKIP'))
end

-- &(eatToken p) eatToken p
local function getTkDeleteRec (g, p)
	local eatTK = newNode('var', 'EatToken')
	local tkDelete = newSeq(eatTk, p)
	return newSeq(newAnd(tkDelete), tkDelete)
end

-- (!FOLLOW(p) eatToken space)*
local function getTkInsertRec (g, p)
	local eatTk = newNode('var', 'EatToken')
	local predFlw = parser.newNot(set2choice(p.flw))
	local insertTk = addSkip(newSeq(predFlw, eatTk))
	return newNode('star', insertTk)
end


-- recovery rule for expression p
-- (!FOLLOW(p) eatToken space)*
-- eatToken  <-  token / (!space .)+
function panicRecPolicy (g, p)
	return getTkInsertRec(g, p)
end


function delPanicRecPolicy (g, p)
	local pred = parser.newNot(set2choice(p.flw))
	local tkInsert = getTkInsertRec(g, p)
	local tkDelete = addSkip(getTkDeleteRec(g, p))
	return newOrd(tkDelete, tkInsert)
end


-- new recovery rule for p
-- tkDelete / (!FOLLOW(p) eatToken space)*
-- tkDelete <- &(eatToken p) eatToken p
local function adderror (g, p, rec)
  local s = getLabelName()
	if currentRecPolicy then
		table.insert(g.plist, s)
		g.prules[s] = currentRecPolicy(g, p)
	end
	return newOrd(p, newThrow(s))	
end

local function getFail (g, p)
	return newSeq(newNot(newAny()), newAny())
end

local function getFlwRepRec (g, p)
  local aux = p.flw['$']
	p.flw['$'] = true
	local predFlw = set2choice(p.flw)
	p.flw['$'] = aux
	return predFlw
end

local function getFstRepRec (g, p)
	return set2choice(first.calcfirst(g, p.p1))
end


-- p*      -> (p / !FOLLOW(p) %{Err} eatTk Err_Rec)*
-- Err     -> ''
-- Err_Rec -> (!FIRST(p) !FOLLOW(p*) eatTk)*
local function recRepPolicy(g, p, s)
	table.insert(g.plist, s)
	g.prules[s] = newString('')
	
	local srec = s .. '_Rec'
	table.insert(g.plist, srec)

	local varRec = newNode('var', srec)
	local eatTk = newNode('var', 'EatToken')
	local predFst = newNot(getFstRepRec(g, p))
	local predFlw = newNot(getFlwRepRec(g, p))
	local seqRec = newSeq(predFst, newSeq(predFlw, eatTk))
	local tag = 'star'
	if p.tag == 'opt' then
		tag = 'opt'
	end
	g.prules[srec] = newNode(tag, seqRec)

	return newSeq(eatTk, varRec)
end

local function adderrorstar (g, p, rec)
  local s = getLabelName()
	local pflw = getFlwRepRec(g, p)
	local seqRec = parser.newAny()
	if rec then
		g.prules[s] = newString('')
		seqRec = recRepPolicy(g, p, s)
	end
	local p2 = newSeq(newNot(pflw), newSeq(newThrow(s), seqRec))
	return newNode(p, newOrd(p.p1, p2))
end



local function markerror (p, flw)	
	p.throw = true
	p.flw = flw
	return p
end


local function putlabel (g, p, rec)
	if p.throw then
		io.write("Err_" .. ierr .. ", ")
		if p.tag == 'star' or p.tag == 'opt' or p.tag == 'plus' then
			return adderrorstar(g, p, rec)
		else
			return adderror(g, p, rec)
		end
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


local function setRecPolicy (rec)
	if rec == 'panic' then
		currentRecPolicy = panicRecPolicy
	elseif rec == 'delpanic' then
		currentRecPolicy = delPanicPolicy
	elseif rec then
		currentRecPolicy = panicRecPolicy
	else
		currentRecPolicy = nil
	end
end


local function labelgrammar (g, rec)
	if rec then
		setRecPolicy(rec)
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

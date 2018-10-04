local m = require 'lpeglabel'
local re = require 'relabel'
local errinfo = require 'syntax_errors'

local tree = {}
local defs = {}
local lvars = {}


local newNode = function (tag, p1, p2)
	return { tag = tag, p1 = p1, p2 = p2 } 
end

defs.newString = function (v)
	return newNode('char', v)
end

defs.newAny = function (v)
	return newNode('any')
end

defs.newVar = function (v)
	lvars[#lvars + 1] = v
	return newNode('var', v)
end

defs.newClass = function (l)
	return newNode('set', l)
end

local function binOpLeft (tag, l)
  --build a left-associateve AST for an operator  
	local p = l[1]
  for i=2, #l do 
		p = newNode(tag, p, l[i]) 
	end

	return p
end

local function binOpRight (tag, l)
  --build a right-associateve AST for an operator  
  local n = #l
  local p = l[n]
  for i = n - 1, 1, -1 do
		p = newNode(tag, l[i], p)
	end
 
	return p
end

defs.newAnd = function (p)
	return newNode('and', p)
end

defs.newNot = function (p)
	return newNode('not', p)
end

defs.newSeq = function (...)
	return binOpLeft('con', {...})
end

-- the algorithm that inserts labels
-- gives  a better result when we consider
-- a right-associative choice
defs.newOrd = function (...)
	return binOpRight('ord', {...})
end

defs.newThrow = function (lab)
	return newNode('throw', lab)
end

defs.newPosCap = function ()
	return newNode('posCap')
end

defs.newSimpCap = function (p)
	return newNode('simpCap', p)
end

defs.newTabCap = function (p)
	return newNode('tabCap', p)
end

defs.newAnonCap = function (p)
	return newNode('anonCap', p)
end

defs.newNameCap = function (p1, p2)
	return newNode('nameCap', p1, p2)
end

defs.newSuffix = function (p, ...)
  local l = { ... }
	local i = 1
	while i <= #l do
		local v = l[i]
		if v == '*' then
			p = newNode('star', p)
			i = i + 1
		elseif v == '+' then
			p = newNode('plus', p)
			i = i + 1
		elseif v == '?' then
			p = newNode('opt', p)
			i = i + 1
		else
			p = newNode('ord', p, defs.newThrow(l[i+1]))
			i = i + 2
		end
	end
	return p
end 

defs.newRule = function (k, v)
	tree[k] = v
	rules[#rules + 1] = k
end

defs.isSimpleExp = function (p)
	local tag = p.tag
	return tag == 'empty' or tag == 'char' or tag == 'any' or
         tag == 'set' or tag == 'var' or tag == 'throw' or
         tag == 'posCap'
end

defs.repSymbol = function (p)
	local tag = p.tag
	assert(tag == 'opt' or tag == 'plus' or tag == 'star', p.tag)
	if p.tag == 'star' then
		return '*'
	elseif p.tag == 'plus' then
		return '+'
	else
		return '?'
	end
end

defs.predSymbol = function (p)
	local tag = p.tag
	assert(tag == 'not' or tag == 'and', p.tag)
	if p.tag == 'not' then
		return '!'
	else
		return '&'
	end
end


defs.matchEmpty = function (p)
	local tag = p.tag
	if tag == 'empty' or tag == 'not' or tag == 'and' or
     tag == 'posCap' or tag == 'star' or tag == 'opt' or
		 tag == 'throw' then
		return true
	elseif tag == 'char' or tag == 'set' or tag == 'any' or
         tag == 'plus' then
		return false
	elseif tag == 'con' then
		return defs.matchEmpty(p.p1) and defs.matchEmpty(p.p2)
	elseif tag == 'ord' then
		return defs.matchEmpty(p.p1) or defs.matchEmpty(p.p2)
	elseif tag == 'var' then
		return defs.matchEmpty(tree[p.p1])
	elseif tag == 'simpCap' or tag == 'tabCap' or
	       tag == 'anonCap' or tag == 'nameCap' then
		return defs.matchEmpty(p.p1)
	else
		print(p)
		error("Unknown tag", p.tag)
	end
end


local peg = [[
	grammar       <-   S rule+^Rule (!.)^Extra

  rule          <-   (name S arrow^Arrow exp^ExpRule)   -> newRule

  exp           <-   (seq ('/' S seq^SeqExp)*) -> newOrd

  seq           <-   (prefix (S prefix)*) -> newSeq

  prefix        <-   '&' S prefix^AndPred -> newAnd  / 
                     '!' S prefix^NotPred -> newNot  /  suffix

  suffix        <-   (primary ({'+'} S /  {'*'} S /  {'?'} S /  {'^'} S name)*) -> newSuffix

  primary       <-   '(' S exp^ExpPri ')'^RParPri S  /  string  /  class  /  any  /  var /  throw /
                     ('{|' S  exp^ExpTabCap '          |}'^RCurTabCap S)   -> newTabCap /
                     ('{:' S  name S ':'  exp         ':}'^RCurNameCap  S) -> newNameCap /
                     ('{:' S  exp^ExpAnonCap          ':}'^RCurNameCap  S) -> newAnonCap /
                     ('{'  S  exp                      '}'^RCurCap  S)     -> newSimpCap /
                      '{'  S                           '}'^RCurCap  S      -> newPosCap


  string        <-   ("'" {(!("'" / %nl) .)*} "'"^SingQuote  S  /
                      '"' {(!('"' / %nl) .)*} '"'^DoubQuote  S) -> newString

	class         <-   '[' {| (({(.'-'.)} / (!']' {.}))+)^EmptyClass |} -> newClass ']'^RBraClass S

  any           <-   '.' -> newAny S

  var           <-    name -> newVar !arrow  

  name          <-   {[a-zA-Z_] [a-zA-Z0-9_]*} S
 
  throw         <-   '%{' S name^NameThrow -> newThrow '}'^RCurThrow S

  arrow         <-   '<-' S

  S             <-   (%s  /  '--' [^%nl]*)*  --spaces and comments
]]

local ppk = re.compile(peg, defs)

defs.match = function (s)
	rules = {}
  tree = {}
	lvars = {}
	local r, lab, pos = ppk:match(s)
  if not r then
		return r, errinfo[lab] or lab, pos
	else
		for i,v in ipairs(lvars) do
			assert(tree[v] ~= nil, "Rule '" .. v .. "' was not defined")
		end
		return tree, rules
	end
end

defs.newNode = newNode
return defs

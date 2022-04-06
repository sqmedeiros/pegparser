local Parser = {}
Parser.__index = Parser

local M = require'lpeglabel'
local Re = require'relabel'
local ErrMsg = require'pegparser.syntax_errors'
local Predef = require'pegparser.predef'
local Node = require"pegparser.node"
local Grammar = require"pegparser.grammar"

local g = nil -- the resulting grammar
local varRef = {} -- variables that appeared in right-hand side of grammar rules
local lasttk = {}


function Parser.newEsqSeq (v1, v2)
	--print ("newEsqSeq = ", v1, #v1, #"\t")
	--return "\t"
	return v1
end


function Parser.newLiteral (v)
	if #v == 2 then
		return Node.empty()
	end

	if g:addToken(v) then
		lasttk[v] = true
	end

	return Node.char(v)
end


function Parser.newSet (l)
	return Node.set(l)
end



function Parser.newVar (v)
	table.insert(varRef, v)
	return Node.var(v)
end


function Parser.binOpLeft (tag, l)
  --build a left-associateve AST for an operator  
	local p = l[1]
  for i=2, #l do 
		p = newNode(tag, p, l[i]) 
	end

	return p
end


function Parser.binOpRight (tag, l)
  --build a right-associateve AST for an operator  
  local n = #l
  local p = l[n]
  for i = n - 1, 1, -1 do
		p = newNode(tag, l[i], p)
	end
 
	return p
end


function Parser.newCon (...)
	return binOpLeft('con', {...})
end


-- the algorithm that inserts labels
-- gives  a better result when we consider
-- a right-associative choice
function Parser.newOrd (...)
	return binOpRight('ord', {...})
end


function Parser.newDef (v)
	if not predef[v] then
		error("undefined name: " .. tostring(v))
	end
	return Node.newDef(v)
end


function Parser.newSuffix (exp, ...)
  local l = { ... }
	local i = 1
	while i <= #l do
		local v = l[i]
		if v == '*' then
			exp = Node.star(exp)
			i = i + 1
		elseif v == '+' then
			exp = Node.plus(exp)
			i = i + 1
		elseif v == '?' then
			exp = Node.opt(exp)
			i = i + 1
		else
			exp = Node.choice{exp, Node.throw(l[i+1])}
			i = i + 2
		end
	end
	return exp
end 


function Parser.newRule (var, rhs)
	g:addRule(var, rhs)
	
	if Grammar.isLexRule(var) then
		for tk, _ in pairs(lasttk) do
			g:removeToken(tk)
		end
	end
	lasttk = {}
end


local pegGrammar = [[
	grammar       <-   S rule+^Rule (!.)^Extra

  rule          <-   (name S arrow^Arrow exp^ExpRule)   -> newRule

  exp           <-   {| (seq ('/' S seq^SeqExp)*) |} -> newChoice

  seq           <-   {| (prefix (S prefix)*) |} -> newCon

  prefix        <-   '&' S prefix^AndPred -> newAnd  /
                     '!' S prefix^NotPred -> newNot  /  suffix

  suffix        <-   (primary ({'+'} S /  {'*'} S /  {'?'} S /  {'^'} S name)*) -> newSuffix

  primary       <-   '(' S exp^ExpPri ')'^RParPri S  /  string  /  class  /  any  /  var / def / throw 

  string        <-   ({"'" (escseq / (!"'"  .))* "'"^SingQuote}  S  /
                      {'"' (escseq / (!'"'  .))* '"'^DoubQuote}  S) -> newLiteral

	class         <-   '[' {| (({(.'-'!']'.)} / (!']' {.}))+)^EmptyClass |} -> newSet ']'^RBraClass S

  any           <-   '.' -> newAny S
  
  esc           <-   [\\]
  
  escseq        <-  '\t' -> newEsqSeq

  var           <-   name -> newVar !arrow  

  name          <-   {[a-zA-Z_] [a-zA-Z0-9_]*} S
 
  def           <-   '%' S name -> newDef

  throw         <-   '%{' S name^NameThrow -> newThrow '}'^RCurThrow S

  arrow         <-   '<-' S

  S             <-   (%s  /  '--' [^%nl]*)*  --spaces and comments
]]


local pegParser = Re.compile(pegGrammar, {
	newRule = Parser.newRule,
  newChoice = Node.choice,
  newCon = Node.con,
  newAnd = Node.andd,
  newNot = Node.nott,
  newSuffix = Parser.newSuffix,
  newLiteral = Parser.newLiteral,
  newSet = Parser.newSet,
  newAny = Node.any,
  newEsqSeq = Parser.newEsqSeq,
  newVar = Parser.newVar,
  newDef = Parser.newDef,
  newThrow = Node.throw
})


function Parser.match (s)
  g = Grammar.new()
  varRef = {}
  lasttk = {}
  local r, lab, pos = pegParser:match(s)

  if not r then
		local line, col = Re.calcline(s, pos)
		local msg = line .. ':' .. col .. ':'
		return r, msg .. (ErrMsg[lab] or lab), pos
	else
		local gRules = g:getRules()
		for _, var in ipairs(varRef) do
			assert(gRules[var] ~= nil, "Rule '" .. var .. "' was not defined")
		end

		return g 
	end

end


return Parser

local Parser = require'parser'
local Grammar = require'grammar'

local Pretty = {
    property = nil,
    propertyStr = ""
}
Pretty.__index = Pretty

function Pretty.new (prop, propStr)
    local self = {}
    setmetatable(self, Pretty)
    self:setProperty(prop, propStr)
    return self
end


function Pretty:setProperty (prop, propStr)
    self.property = prop
    self.propertyStr = propStr or prop
end

function Pretty:printProp (p)
    --if self.property then
      --  print("Property " .. self.property)
      --  assert(false)
    --end
	if self.property and p[self.property] then
		return '_' .. self.propertyStr
	end
	return ''
end

function Pretty:printp (p, flag)
	if p.tag == 'empty' then
		return "''"
	elseif p.tag == 'char' then
		return p.v .. self:printProp(p) 
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'set' then
		return "[" .. table.concat(p.v) .. "]"
	elseif p.tag == 'constCap' then
		return '{:const ' .. p.v .. '}'
	elseif p.tag == 'posCap' then
		return '{}'
	elseif p.tag == 'simpCap' then
		return '{' .. self:printp(p.v, flag) .. '}'
	elseif p.tag == 'tabCap' then
		return '{|' .. self:printp(p.v, flag) .. '|}'
	elseif p.tag == 'nameCap' then
		return '{:' .. p.v .. ': ' .. self:printp(p.v, flag) .. ':}'
	elseif p.tag == 'anonCap' then
		return '{:' .. self:printp(p.v, flag) .. ':}'
	elseif p.tag == 'var' then
		return p.v .. self:printProp(p)
	elseif p.tag == 'choice' then
        local outTab = {}
        local n = #p.v
        for i = 1, n do
            local iExp = p.v[i]
            local s = self:printp(iExp, flag)
            if i == n - 1 and p.v[i+1].tag == 'throw' then
                s = s .. '^' .. p.v[i+1].v
                table.insert(outTab, s)
                break
            else
                table.insert(outTab, s)
            end
            
        end
        return table.concat(outTab, '  /  ')
		--[==[ if p.p2.tag == 'throw' then
			if not flag then
				return '[' .. s1 .. ']^' .. string.sub(s2, 3, #s2 - 1) .. printProp(p)
			else
					if p.p1.tag == 'ord' then
						s1 = '(' .. s1 .. ')'
					end
					return s1 .. '^' .. string.sub(s2, 3, #s2 - 1) .. printProp(p)
			end
		else
			local s = printProp(p)
			if s == '' then
				return  s1 .. '  /  ' .. s2
			else
				return  '(' .. s1 .. '  /  ' .. s2 .. ')' .. printProp(p)
			end
		end]==]
	elseif p.tag == 'con' then
        local outTab = {}
        for i, v in ipairs(p.v) do
            local s = self:printp(v, flag)
            if v.tag == 'choice' and v.v[2].tag ~= 'throw' then
                s = '(' .. s .. ')'
            end        
            table.insert(outTab, s)
        end
        return table.concat(outTab, ' ')
	elseif p.tag == 'and' or p.tag == 'not' then
		local s = self:printp(p.v, flag)
		if p.v:isSimple() then
			return p:getPredOp() .. s
		else
			return  p:getPredOp() .. '(' .. s .. ')'
		end
	elseif p.tag == "star" or p.tag == 'plus' or p.tag == 'opt' then
		local s = self:printp(p.v, flag)
		if p.v:isSimple() then
			return s .. p:getRepOp() .. self:printProp(p)
		else
			return '(' .. s .. ')' .. parser.repSymbol(p) .. self:printProp(p)
		end
  elseif p.tag == 'throw' then
    return '%{' .. p.v .. '}'
	elseif p.tag == 'def' then
		return '%' .. p.v
	else
		print(p, p.tag)
		error("Unknown tag: " .. p.tag)
	end
end


function Pretty:printg (grammar, flagthrow, withLex)
	local t = {}
    
    for i, var in ipairs(grammar:getVars()) do
        if not Grammar.isLexRule(var) or withLex then
			table.insert(t, string.format("%-15s <-  %s",
                                          var, self:printp(grammar:getRHS(var), 
                                          flagthrow)))
		end
    end
    
	return table.concat(t, '\n')
end


local function prefix (p1, p2)
	local s1 = printp(p1)
	local s2 = printp(p2)
	local pre = ""
	local i = 1
	while string.sub(s1, 1, i) == string.sub(s2, 1, i) do
		i = i + 1
	end
	pre = string.sub(s1, 1, i - 1)
	if i > 1 then
		print("s1 = ", s1, "s2 = ", s2, p1.p1, p1.p1.tag)
		print("Prefixo foi ", pre)
	end
	return pre
end


local preDefault = [==[
local m = require 'pegparser.parser'
local coder = require 'pegparser.coder'
local util = require'pegparser.util'

g = [[
]==] 

local posDefault = [==[
]]

local g = m.match(g)
local p = coder.makeg(g, 'ast')

local dir = util.getPath(arg[0])

util.testYes(dir .. '/test/yes/', 'source', p)
]==]

local endDefaultNoRecovery = [==[
util.testNo(dir .. '/test/no/', 'source', p)
]==]

local endDefaultWithRecovery = [==[
util.setVerbose(true)
util.testNoRec(dir .. '/test/no/', 'source', p)
]==]


local function printToFile (g, file, ext, rec, pre, pos)
	file = file or 'out.lua'
	local f = io.open(file, "w")

	pre = pre or preDefault
	local s = preDefault ..  printg(g, true)
	print(f)
	if not pos then
		pos = string.gsub(posDefault, 'source', ext)
		local endPos = endDefaultNoRecovery
		if rec then
			endPos = endDefaultWithRecovery
		end
		pos = pos .. string.gsub(endPos, 'source', ext)
	end

	f:write(s .. '\n' .. pos)

	f:close()
end


return Pretty

local pretty = {}

local parser = require 'parser'

local property

local function printProp (p)
	if property and p[property] then
		--if p.ban then assert(false, p.tag .. ', ' .. tostring(property) .. ', ' .. tostring(p[property])) end
		return '_' .. tostring(property)
	end
	return ''
end

local function printp (p, flag)
	if p.tag == 'empty' then
		return "''"
	elseif p.tag == 'char' then
		return p.p2 .. p.p1 .. p.p2 .. printProp(p) 
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'set' then
		return "[" .. table.concat(p.p1) .. "]"
	elseif p.tag == 'constCap' then
		return '{:const ' .. p.p1 .. '}'
	elseif p.tag == 'posCap' then
		return '{}'
	elseif p.tag == 'simpCap' then
		return '{' .. printp(p.p1, flag) .. '}'
	elseif p.tag == 'tabCap' then
		return '{|' .. printp(p.p1, flag) .. '|}'
	elseif p.tag == 'nameCap' then
		return '{:' .. p.p1 .. ': ' .. printp(p.p2, flag) .. ':}'
	elseif p.tag == 'anonCap' then
		return '{:' .. printp(p.p1, flag) .. ':}'
	elseif p.tag == 'var' then
		return p.p1 .. printProp(p)
	elseif p.tag == 'ord' then
		local s1 = printp(p.p1, flag) 
		local s2 = printp(p.p2, flag) 
		if p.p2.tag == 'throw' then
			if not flag then
				return '[' .. s1 .. ']^' .. string.sub(s2, 2) .. printProp(p) 
			else
					if p.p1.tag == 'ord' then
						s1 = '(' .. s1 .. ')'
					end
					return s1 .. '^' .. string.sub(s2, 2) .. printProp(p)
			end
		else
			local s = printProp(p)
			if s == '' then
				return  s1 .. '  /  ' .. s2
			else
				return  '(' .. s1 .. '  /  ' .. s2 .. ')' .. printProp(p)
			end
		end
	elseif p.tag == 'con' then
		local s1 = printp(p.p1, flag)
		local s2 = printp(p.p2, flag)
		local s = s1
		if p.p1.tag == 'ord' and p.p1.p2.tag ~= 'throw' then
			s = '(' .. s .. ')'
		end
		if p.p2.tag == 'ord' and p.p2.p2.tag ~= 'throw' then
			s = s .. ' (' .. s2 .. ')'
		else
			s = s .. ' ' .. s2
		end
		return s --.. printProp(p)
	elseif p.tag == 'and' or p.tag == 'not' then
		local s = printp(p.p1, flag)
		if parser.isSimpleExp(p.p1) then
			return parser.predSymbol(p) .. s
		else
			return  parser.predSymbol(p) .. '(' .. s .. ')'
		end
	elseif p.tag == 'not' then
		return '!(' .. printp(p.p1, flag)	.. ')'
	elseif p.tag == "star" or p.tag == 'plus' or p.tag == 'opt' then
		local s = printp(p.p1, flag)
		if parser.isSimpleExp(p.p1) then
			return s .. parser.repSymbol(p) .. printProp(p)
		else
			return '(' .. s .. ')' .. parser.repSymbol(p) .. printProp(p)
		end
  elseif p.tag == 'throw' then
    return '^' .. p.p1
	elseif p.tag == 'def' then
		return '%' .. p.p1
	else
		print(p, p.tag)
		error("Unknown tag: " .. p.tag)
	end
end

local function printg (g, flagthrow, k)
	property = k
	print("Property ", k)
	local t = {}
	for i, v in ipairs(g.plist) do
		table.insert(t, string.format("%-15s <-  %s", v, printp(g.prules[v], flagthrow)))
	end
	return table.concat(t, '\n')
end


return {
	printp = printp,
	printg = printg
}

local pretty = {}

local parser = require 'parser'

local function printp (p)
	if p.tag == 'empty' then
		return "''"
	elseif p.tag == 'char' then
		return "'" .. p.p1 .. "'"
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'set' then
		return "[" .. table.concat(p.p1) .. "]"
	elseif p.tag == 'posCap' then
		return '{}'
	elseif p.tag == 'simpCap' then
		return '{' .. printp(p.p1) .. '}'
	elseif p.tag == 'tabCap' then
		return '{|' .. printp(p.p1) .. '|}'
	elseif p.tag == 'var' then
		return p.p1
	elseif p.tag == 'ord' then
		local s1 = printp(p.p1)
		local s2 = printp(p.p2)
		if p.p2.tag == 'throw' then
			return '[' .. s1 .. ']^' .. string.sub(s2, 2)
		else
			return  s1 .. '  /  ' .. s2
		end
	elseif p.tag == 'con' then
		local s1 = printp(p.p1)
		local s2 = printp(p.p2)
		local s = s1
		if p.p1.tag == 'ord' and p.p1.p2.tag ~= 'throw' then
			s = '(' .. s .. ')'
		end
		if p.p2.tag == 'ord' and p.p2.p2.tag ~= 'throw' then
			s = s .. ' (' .. s2 .. ')'
		else
			s = s .. ' ' .. s2
		end
		return s
	elseif p.tag == 'and' then
		return '&(' .. printp(p.p1)	.. ')'
	elseif p.tag == 'not' then
		return '!(' .. printp(p.p1)	.. ')'
	elseif p.tag == "star" or p.tag == 'plus' or p.tag == 'opt' then
		local s = printp(p.p1)
		if parser.isSimpleExp(p.p1) then
			return s .. parser.repSymbol(p)
		else
			return '(' .. s .. ')' .. parser.repSymbol(p)
		end
  elseif p.tag == 'throw' then
    return '^' .. p.p1
	else
		print(p, p.tag)
		error("Unknown tag: " .. p.tag)
	end
end

local function printg (g, l)
	local t = {}
	for i, r in ipairs(l) do
		table.insert(t, string.format("%-15s <-  %s", r, printp(g[r])))
	end
	return table.concat(t, '\n')
end


return {
	printp = printp,
	printg = printg
}

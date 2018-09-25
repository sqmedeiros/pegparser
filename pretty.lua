local pretty = {}

pretty.printp = function (p, iscon)
	if p.tag == 'char' then
		return "'" .. p.p1 .. "'"
	elseif p.tag == 'set' then
		return "[" .. table.concat(p.p1) .. "]"
	elseif p.tag == 'empty' then
		return "''"
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'posCap' then
		return '{}'
	elseif p.tag == 'simpCap' then
		return '{' .. pretty.printp(p.p1) .. '}'
	elseif p.tag == 'tabCap' then
		return '{|' .. pretty.printp(p.p1) .. '|}'
	elseif p.tag == 'var' then
		return p.p1
	elseif p.tag == 'ord' then
		local s1 = pretty.printp(p.p1, false)
		local s2 = pretty.printp(p.p2, false)
		if iscon then
			return '(' .. s1 .. " / " .. s2 .. ')'
		else
			return s1 .. " / " .. s2
		end
	elseif p.tag == 'con' then
		return pretty.printp(p.p1, true) .. " " .. pretty.printp(p.p2, true)
	elseif p.tag == 'and' then
		return '&(' .. pretty.printp(p.p1, false)	.. ')'
	elseif p.tag == 'not' then
		return '!(' .. pretty.printp(p.p1, false)	.. ')'
  elseif p.tag == 'opt' then
    return pretty.printp(p.p1, false) .. '?'
  elseif p.tag == 'star' then
    return pretty.printp(p.p1, false) .. '*'
  elseif p.tag == 'plus' then
    return pretty.printp(p.p1, false) .. '+'
  elseif p.tag == 'throw' then
    return '^' .. p.p1
	else
		error("Unknown tag: " .. p.tag)
	end
end

pretty.printg = function (g)
	local t = {}
	for k, v in pairs(g) do
		table.insert(t, string.format("%-15s <-  %s", k, pretty.printp(v)))
	end
	return table.concat(t, '\n')
end


return pretty

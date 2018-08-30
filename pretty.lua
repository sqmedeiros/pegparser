local pretty = {}

pretty.printg = function (g)
	local t = {}
	for k, v in pairs(g) do
		table.insert(t, k) 
	end	
end 

pretty.print = function (p, iscon)
	if p.tag == 'char' then
		return "'" .. p.p1 .. "'"
	elseif p.tag == 'empty' then
		return "''"
	elseif p.tag == 'any' then
		return "."
	elseif p.tag == 'var' then
		return p.p1
	elseif p.tag == 'ord' then
		local s1 = pretty.print(p.p1, false)
		local s2 = pretty.print(p.p2, false)
		if iscon then
			return '(' .. s1 .. " / " .. s2 .. ')'
		else
			return s1 .. " / " .. s2
		end
	elseif p.tag == 'con' then
		return pretty.print(p.p1, true) .. " " .. pretty.print(p.p2, true)
	elseif p.tag == 'and' then
		return '&(' .. pretty.print(p.p1)	.. ')'
	elseif p.tag == 'not' then
		return '!(' .. pretty.print(p.p1)	.. ')'
  elseif p.tag == 'opt' then
    return pretty.print(p.p1) .. '?'
  elseif p.tag == 'star' then
    return pretty.print(p.p1) .. '*'
  elseif p.tag == 'plus' then
    return pretty.print(p.p1) .. '+'
	else
		error("Unknown tag: " .. p.tag)
	end
end

return pretty

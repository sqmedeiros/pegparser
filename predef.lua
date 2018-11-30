local m = require'lpeglabel'

local predef = {}
m.locale(predef)

return {
	nl = m.P"\n",
	cr = m.P"\r",
	tab = m.P"\t",
	space = predef.space,
}


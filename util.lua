local Util ={}
Util.__index = Util

function Util.new ()
	return setmetatable({}, Util)
end

local verbose = false

local function setVerbose (v)
	verbose = v
end


local function getFileName (s)
	local i = 1
	local j = string.find(s, '/', i)
	while j ~= nil do
		i = j + 1
		j = string.find(s, '/', i)
	end
	return string.sub(s, i)
end


local function getPath (s)
	local i = 1
	local j = string.find(s, '/', i)
	while j ~= nil do
		i = j + 1
		j = string.find(s, '/', i)
	end
	local path = string.sub(s, 1, i - 1)
	if #path == 0 then
		return "."
	else
		return path
	end
end


function Util.removeSpace (s, space)
	space = space or " \t\n\r"
	return s:gsub("[" .. space .. "]", "")
end


local function isSource (file, ext)
	return string.sub(file, 1, 1) ~= '.' and string.sub(file, #file - #ext + 1) == ext
end


local function getFiles (dir, ext)
	local t = {}
	for file in lfs.dir(dir) do
		if isSource(file, ext) then
			table.insert(t, file)
		end
	end
	table.sort(t)
	return t
end


local function getText (file)
	local f = io.open(file)
	local s = f:read('a')
	f:close()
	return s
end


local function testFile (file, p)
	local s = getText(file)
	return p:match(s)
end


local function matchlabel (s1, s2)
	return string.match(string.lower(tostring(s1)), string.lower(tostring(s2)))
end


local function testYes (dir, ext, p)
	for i, file in ipairs(getFiles(dir, ext)) do
		print("Yes: ", file)
		local r, lab, pos = testFile(dir .. file, p)
		local line, col = '', ''
		if not r then
			line, col = re.calcline(getText(dir .. file), pos)
		end
		assert(r ~= nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
	end
end


local function testNo (dir, ext, p, strict, special)
	for i, file in ipairs(getFiles(dir, ext)) do
		print("No: ", file)
		local r, lab, pos = testFile(dir .. file, p)
		if lab ~= nil then
			io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
		end
		local line, col = '', ''
		if not r then
			line, col = re.calcline(getText(dir .. file), pos)
			io.write(' line: ' .. line .. ' col: ' .. col)
		end
		if strict then
			assert(r == nil and (matchlabel(file, lab) or matchlabel(file, special)), file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
		else
			assert(r == nil, file .. ': Label: ' .. tostring(lab) .. '  Line: ' .. line .. ' Col: ' .. col)
		end
		io.write('\n')
	end
end


local function testNoRec (dir, ext, p)
	local irec, ifail = 0, 0
	local tfail = {}

	for i, file in ipairs(getFiles(dir, ext)) do
		print("No: ", file)
		local r, lab, pos = testFile(dir .. file, p)
		if not r then
			local line, col = re.calcline(getText(dir .. file), pos)
			io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
			io.write(' line: ' .. line .. ' col: ' .. col)
			io.write('\n')
     	ifail = ifail + 1
			tfail[ifail] = { file = file, lab = lab, line = line, col = col }
		else
			if verbose then
				io.write(getText(dir .. file))
			end
			irec = irec + 1
			if type(r) == 'table' then
				ast.printAST(r)
				io.write('\n')
				io.write('\n')
			end
		end
	end

	print('irec: ', irec, ' ifail: ', ifail)
	for i, v in ipairs(tfail) do
		print(v.file, v.lab, 'line: ', v.line, 'col: ', v.col)
	end
end


local function testNoRecDist (dir, ext, p)
	local irec, ifail = 0, 0
	local tfail = {}

	for i, file in ipairs(getFiles(dir, ext)) do
		print("No: ", file)
		local r, lab, pos = testFile(dir .. file, p)
		if not r then
			local line, col = re.calcline(getText(dir .. file), pos)
			io.write('r = ' .. tostring(r) .. ' lab = ' .. tostring(lab))
      io.write(' line: ' .. line .. ' col: ' .. col)
			io.write('\n')
			ifail = ifail + 1
			tfail[ifail] = { file = file, lab = lab, line = line, col = col }
		else
			if verbose then
				io.write(getText(dir .. file))
			end
			irec = irec + 1
			if type(r) == 'table' then
				local tokens = ast.getTokens(r)
				print("Tokens")
				for i, v in ipairs(tokens) do
					io.write(v .. ' ')
				end
				io.write('\n')
				io.write('\n')
			end
		end
	end

	print('irec: ', irec, ' ifail: ', ifail)
	for i, v in ipairs(tfail) do
		print(v.file, v.lab, 'line: ', v.line, 'col: ', v.col)
	end
end


return Util
